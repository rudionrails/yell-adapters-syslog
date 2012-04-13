Syslog Adapter for Yell - Your Extensible Logging Library

If you are not yet familiar with **Yell - Your Extensible Logging Library** 
check out the githup project under https://github.com/rudionrails/yell or jump 
directly into the Yell wiki at https://github.com/rudionrails/yell/wiki.

[![Build Status](https://secure.travis-ci.org/rudionrails/yell-adapters-syslog.png?branch=master)](http://travis-ci.org/rudionrails/yell-adapters-syslog)

The Syslog adapter for Yell works and is tested with ruby 1.8.7, 1.9.x, jruby 1.8 and 1.9 mode, rubinius 1.8 and 1.9 as well as ree.

## Installation

System wide:

```console
gem install yell-adapters-syslog
```

Or in your Gemfile:

```ruby
gem "yell-adapters-syslog"
```

## Usage

```ruby
logger = Yell.new :syslog

logger.info "Hello World"
# Check your syslog for the received message.
```

Or alternatively with the block syntax:

```ruby
logger = Yell.new do
  adapter :syslog
end

logger.info 'Hello World!'
```

You can pass set `options` and the `facility`:

```ruby
logger = Yell.new do
  adapter :syslog, :facility => :user, :options => [:pid, :cons]
end

logger.info 'Hello World!'
```


Copyright &copy; 2012 Rudolf Schmidt, released under the MIT license

