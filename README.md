# Sickle

## Description

Sickle is dead simple library for building complex command line tools.

#### Features:

* Based on classes and modules
* Support for commands
* Support for namespaces
* Support for command options and global options
* Usage and help for free
* No external dependencies (only stdlib optparse)


## Installation

You are probably building command line tool that will be released as gem, just add that line to you gemspec.

```ruby
spec.add_dependency 'sickle'
```

## Usage

### Basic usage

Simple create a class with methods and some options

```ruby
require "sickle"

class App
  include Sickle::Runner

  global_option :verbose                      # global flag

  desc "install one of the available apps"    # command description
  option :force                               # flag for `install` command
  option :host, :default => "localhost"       # option
  def install(name)
    if options[:host]                         # access options
      # do something
    end
    # the rest
  end

  desc "list all apps, search is possible"
  def list(search = "")
    # ...
  end

end

App.run(ARGV) # start parsing ARGV
```

This will allow for execution command like:

```bash
$ mytool install foo
$ mytool install foo --force --verbose --host 127.0.0.1
$ mytool list
$ mytool list rails --verbose
```

Help is for free:

```
$ mytool help
USAGE:
  mytool COMMAND [ARG1, ARG2, ...] [OPTIONS]

TASKS:
  help [COMMAND]  
  install NAME    # install one of the available apps
  list [SEARCH]   # list all apps, search is possible

GLOBAL OPTIONS:
  --verbose (default: false)
```

There is also detailed help for command:

```bash
$ mytool help install
USAGE:
  mytool install NAME

DESCRIPTION:
  install one of the available apps

OPTIONS:
  --force (default: false)
  --host (default: localhost)
```


### Advanced usage - multiple modules

```ruby
module Users
  include Sickle::Runner

  desc "list all users"
  def list
    # ...
  end

  desc "create new user"
  def create(name)
    # ...
  end
end

module Projects
  include Sickle::Runner

  desc "list all projects"
  def list
    # ...
  end
end

module Global
  include Sickle::Runner

  desc "have some fun at top level"
  def fun
    # ...
  end
end

class App
  include Sickle::Runner

  desc "top level command"
  def main
    # ...
  end

  include_modules :users => Users,      # bind commands from Users module under "users" namespace
                  :p     => Projects    # bind commands from Projects module under "p" namespace

  include Global                        # bind command from Global module at top level namespace
end

App.run(ARGV)

```

Run `$ mytool help` to see how commands are namespaced:

```bash
$ mytool help
USAGE:
  mytool COMMAND [ARG1, ARG2, ...] [OPTIONS]

TASKS:
  fun                # have some fun at top level
  help [COMMAND]     
  main               # top level command
  p:list             # list all projects
  users:create NAME  # create new user
  users:list         # list all users
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
