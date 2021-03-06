require "sickle/version"
require 'optparse'

module Sickle
  class << self
    def push_desc(desc)
      @__desc = desc
    end

    def pop_desc
      d = @__desc
      @__desc = nil
      d
    end

    def push_option(name, opts)
      @__options ||= {}
      @__options[name] = Option.new(name, opts)
    end

    def pop_options
      o = @__options || {}
      @__options = {}
      o
    end

    def push_namespace(n)
      namespace << n
    end

    def pop_namespace
      namespace.pop
    end

    def namespace
      @__namespace ||= []
    end
  end

  module Runner
    def self.included(base)
      base.extend(Sickle::ClassMethods)

      if base.is_a?(Class)
        base.send(:include, Sickle::Help)
        base.method_added(:help)
      end
    end

    def options
      @__options ||= {}
    end
  end

  class Command
    attr_accessor :meth, :name, :desc, :options

    def initialize(meth, name, desc, options)
      @meth, @name, @desc, @options = meth, name, desc, options
    end
  end

  class Option
    attr_accessor :name, :opts, :default

    def initialize(name, opts)
      @name, @opts = name, opts

      @default = opts.has_key?(:default) ? opts[:default] : nil

      if @default == true || @default == false
        @type = :boolean
      else
        @type = @default.class.to_s.downcase.to_sym
      end
    end

    def register(parser, results)
      if @type == :boolean
        parser.on("--#{cli_name}", opts[:desc]) do
          results[@name] = true
        end
      else
        parser.on("--#{cli_name} #{@name.upcase}") do |v|
          results[@name] = coerce(v)
        end
      end
    end

    def cli_name
      @name.to_s.tr("_", "-")
    end

    def coerce(value)
      case @default
      when Fixnum
        value.to_i
      when Float
        value.to_f
      else
        value
      end
    end

  end

  module Help
    def self.included(base)
      base.class_eval do
        desc "Display help"
        def help(command = nil)
          if command
            __display_help_for_command(command)
          else
            __display_help
          end
        end
      end
    end


    def __display_help_for_command(name)
      if cmd = self.class.__commands[name]
        puts "USAGE:"
        u, _ = __display_command_usage(name, cmd)
        puts "  #{$0} #{u}"
        puts
        puts "DESCRIPTION:"
        puts cmd.desc.split("\n").map {|e| "  #{e}"}.join("\n")
        puts
        unless cmd.options.empty?
          puts "OPTIONS:"
          cmd.options.each do |_, opt|
            puts __display_option(opt)
          end
        end

        __display_global_options
      else
        puts "\e[31mCommand '#{name}' not found\e[0m"
      end
    end

    def __display_command_usage(name, command)
      params = command.meth.parameters.map do |(r, p)|
        r == :req ? p.upcase : "[#{p.upcase}]"
      end

      ["#{name.gsub("_", "-")} #{params.join(" ")}", command]
    end

    def __display_help
      puts "USAGE:"
      puts "  #{$0} COMMAND [ARG1, ARG2, ...] [OPTIONS]"
      puts

      puts "TASKS:"
      cmds = self.class.__commands.sort.map do |name, command|
        __display_command_usage(name, command)
      end
      max = cmds.map {|a| a[0].length }.max
      cmds.each do |(cmd, c)|
        desc = c.desc ? "# #{c.desc}" : ""
        puts "  #{cmd.ljust(max)}  #{desc}"
      end

      __display_global_options
    end

    def __display_global_options
      unless self.class.__global_options.empty?
        puts
        puts "GLOBAL OPTIONS:"
        self.class.__global_options.sort.each do |name, opt|
          puts __display_option(opt)
        end
      end
    end

    def __display_option(opt)
      "  --#{opt.cli_name} (default: #{opt.default})"
    end
  end

  module ClassMethods
    def included(base)
      __commands.each do |name, command|
        name = (Sickle.namespace + [name]).join(":")
        base.__commands[name] = command
      end
    end

    def before(&block)
      @__before_hook = block
    end

    def desc(label)
      Sickle.push_desc(label)
    end

    def global_option(name, opts = {})
      __global_options[name.to_s] = Option.new(name, opts)
    end

    def global_flag(name)
      global_option(name, :default => false)
    end

    def option(name, opts = {})
      Sickle.push_option(name, opts)
    end

    def flag(name)
      option(name, :default => false)
    end

    def include_modules(hash)
      hash.each do |key, value|
        Sickle.push_namespace(key)
        send(:include, value)
        Sickle.pop_namespace
      end
    end

    def __commands
      @__commands ||= {}
    end

    def __global_options
      @__global_options ||= {}
    end

    def run(argv)
      # puts "ARGV: #{argv.inspect}"

      if command_name = argv.shift
        command_name = command_name.gsub("-", "_")

        if command = __commands[command_name]
          all = __global_options.values + command.options.values

          results = {}
          args = OptionParser.new do |parser|
            all.each do |option|
              option.register(parser, results)
            end
          end.parse!(argv)

          all.each do |o|
            results[o.name] ||= o.default
          end

          obj = self.new
          obj.instance_variable_set(:@__options, results)

          if @__before_hook
            obj.instance_exec(&@__before_hook)
          end

          req, opt = command.meth.parameters.partition {|(r,_)| r == :req }
          r,o = req.size, opt.size
          argr = (r..(r+o))

          if argr.include?(args.size)
            command.meth.bind(obj).call(*args)
          else
            puts "\e[31mWrong number of arguments (#{args.size} for #{argr})\e[0m"
            puts
            run(["help", command_name])
            exit 127
          end
        else
          puts "\e[31mCommand '#{command_name}' not found\e[0m"
          puts
          run(["help"])
          exit 127
        end
      else
        run(["help"])
      end
    end



    def method_added(a)
      meth = instance_method(a)
      if desc = Sickle.pop_desc
        __commands[a.to_s] = Command.new(meth, a, desc, Sickle.pop_options)
      end
    end
  end
end

