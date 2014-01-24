[![Code Climate](https://codeclimate.com/github/teamon/sickle.png)](https://codeclimate.com/github/teamon/sickle)
[![Build Status](https://travis-ci.org/teamon/sickle.png?branch=master)](https://travis-ci.org/teamon/sickle)
[![Gem Version](https://badge.fury.io/rb/sickle.png)](https://rubygems.org/gems/sickle)
[![Coverage Status](https://coveralls.io/repos/teamon/sickle/badge.png?branch=master)](https://coveralls.io/r/teamon/sickle)

# Sickle

## Description

Sickle is dead simple library for building complex command line tools. A lot of ideas and examples were inspired by [thor](https://github.com/wycats/thor).

#### Features:

* Based on classes and modules
* Support for commands
* Support for namespaces
* Support for command options and global options
* Usage and help for free
* No external dependencies (only stdlib optparse)

#### Requirements

* Ruby: 1.9.x, 2.0.x, jruby (1.9), rbx (1.9)


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

  global_flag :verbose                        # global flag, defaults to false
  global_option :with_prefix                  # global option, defaults to nil

  # optional before hook with access to global options
  before do
    $verbose = options[:verbose]
  end

  desc "install one of the available apps"    # command description
  flag :force                                 # flag for `install` command
  option :host, :default => "localhost"       # option
  def install(name)
    if options[:force]                         # access options
      do_smth_with options[:host]
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
