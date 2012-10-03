# encoding: utf-8

require 'syslog'

module Yell #:nodoc:
  module Adapters #:nodoc:

    class Syslog < Yell::Adapters::Base

      # Syslog severities
      #
      # `man syslog` to see the severities
      Severities = [7, 6, 4, 3, 2, 1]

      # Map Syslog options to internal representation
      OptionMap = {
        :cons   => ::Syslog::LOG_CONS,    # If there is an error while sending to the system logger, write directly to the console instead.
        :ndelay => ::Syslog::LOG_NDELAY,  # Open the connection now, rather than waiting for the first message to be written.
        :nowait => ::Syslog::LOG_NOWAIT,  # Don’t wait for any child processes created while logging messages. (Has no effect on Linux.)
        :odelay => ::Syslog::LOG_ODELAY,  # Opposite of LOG_NDELAY; wait until a message is sent before opening the connection. (This is the default.)
        :perror => ::Syslog::LOG_PERROR,  # Print the message to stderr as well as sending it to syslog. (Not in POSIX.1-2001.)
        :pid    => ::Syslog::LOG_PID      # Include the current process ID with each message.
      }

      # Map Syslog facilities to internal represenation
      FacilityMap = {
        :auth     => ::Syslog::LOG_AUTH,
        :authpriv => ::Syslog::LOG_AUTHPRIV,
        # :console  => ::Syslog::LOG_CONSOLE, # described in 1.9.3 docu, but not defined
        :cron     => ::Syslog::LOG_CRON,
        :daemon   => ::Syslog::LOG_DAEMON,
        :ftp      => ::Syslog::LOG_FTP,
        :kern     => ::Syslog::LOG_KERN,
        # :lrp      => ::Syslog::LOG_LRP, # described in 1.9.3 docu, but not defined
        :mail     => ::Syslog::LOG_MAIL,
        :news     => ::Syslog::LOG_NEWS,
        # :ntp      => ::Syslog::LOG_NTP, # described in 1.9.3 docu, but not defined
        # :security => ::Syslog::LOG_SECURITY, # described in 1.9.3 docu, but not defined
        :syslog   => ::Syslog::LOG_SYSLOG,
        :user     => ::Syslog::LOG_USER,
        :uucp     => ::Syslog::LOG_UUCP,
        :local0   => ::Syslog::LOG_LOCAL0,
        :local1   => ::Syslog::LOG_LOCAL1,
        :local2   => ::Syslog::LOG_LOCAL2,
        :local3   => ::Syslog::LOG_LOCAL3,
        :local4   => ::Syslog::LOG_LOCAL4,
        :local5   => ::Syslog::LOG_LOCAL5,
        :local6   => ::Syslog::LOG_LOCAL6,
        :local7   => ::Syslog::LOG_LOCAL7
      }

      setup do |options|
        self.ident    = options[:ident] || $0
        self.options  = options[:options] || [:pid, :cons]
        self.facility = options[:facility]
      end

      write do |event|
        stream.log( Severities[event.level], format(*event.messages) )
      end

      close do
        begin
          @stream.close if @stream.respond_to? :close
        rescue Exception
          # do nothing
        ensure
          @stream = nil
        end
      end


      # Access the Syslog ident
      attr_accessor :ident

      # Access the Syslog options
      attr_reader :options

      # Access the Syslog facility
      attr_reader :facility


      # Deprecated: use :ident= in future
      def ident( val = nil )
        if val.nil?
          @ident
        else
          # deprecate, but should still work
          Yell._deprecate( "0.6.0", "Use :ident= for setting the Syslog ident" )

          self.ident = val
        end
      end

      # Set the log facility for Syslog
      #
      # See {Yell::Adapters::Syslog::OptionMap OptionMap} for allowed values.
      #
      # @example Direct or Symbol
      #   options = Syslog::LOG_CONS
      #   options = :cons
      #
      # @example Multiple
      #   options = [:ndelay, Syslog::LOG_NDELAY]
      def options=( *values )
        @options = values.flatten.map do |v|
          v.is_a?(Symbol) ? OptionMap[v] : v
        end.inject { |a, b| a | b }
      end

      # Deprecated: use options= in future
      def options( *values )
        if values.empty?
          @options
        else
          # deprecate, but should still work
          Yell._deprecate( "0.6.0", "Use :options= for setting the Syslog options" )

          self.options = values
        end
      end


      # Set the log facility for Syslog
      #
      # See {Yell::Adapters::Syslog::FacilityMap FacilityMap} for allowed values.
      #
      # @example Direct or Symbol
      #  facility = :user
      #  facility = Syslog::LOG_CONSOLE
      #
      # @example Multiple
      #   facility = [:user, Syslog::LOG_CONSOLE]
      def facility=( *values )
        @facility = values.flatten.map do |v|
          v.is_a?(Symbol) ? FacilityMap[v] : v
        end.inject { |a, b| a | b }
      end

      # Deprecated, use facility= in future
      def facility( *values )
        if values.empty?
          @facility
        else
          # deprecate, but should still work
          Yell._deprecate( "0.6.0", "Use :facility= for setting the Syslog facility" )

          self.facility = values
        end
      end


      private

      def stream
        @stream ||= _new_stream
      end

      def _new_stream
        return ::Syslog if ::Syslog.opened?

        ::Syslog.open( @ident, @options, @facility )
      end

      # Borrowed from [SyslogLogger](https://github.com/seattlerb/sysloglogger)
      def format( *messages )
        messages.map { |m| to_message(m) }.join( ' ' )
      end

      def to_message( m )
        message = m.to_s

        message.strip!
        message.gsub!(/%/, '%%') # syslog(3) freaks on % (printf)
        message.gsub!(/\e\[[^m]*m/, '') # remove useless ansi color codes

        message
      end

    end

    register( :syslog, Yell::Adapters::Syslog )

  end
end
