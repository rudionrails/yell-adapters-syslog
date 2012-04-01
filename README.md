Yell Adapters Syslog - Syslog Adapter for Your Extensible Logging Library

If you are not yet familiar with **Yell - Your Extensible Logging Library** 
check out the githup project under https://github.com/rudionrails/yell or jump 
directly into the Yell wiki at https://github.com/rudionrails/yell/wiki.

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
  adapter :syslog, :facility => :user, :syslog_options => [:pid, :cons]
end

logger.info 'Hello World!'
```


Copyright &copy; 2012 Rudolf Schmidt, released under the MIT license

