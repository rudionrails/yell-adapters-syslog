# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    class Syslog < Yell::Adapters::Base

      # Syslog severities
      #
      # `man syslog` to see the severities
      Severities = [7, 6, 4, 3, 2, 1]

      # Map Syslog severities to internal represenation
      #   'DEBUG'   => 7
      #   'INFO'    => 6
      #   'WARN'    => 4
      #   'ERROR'   => 3
      #   'FATAL'   => 2
      #   'UNKNOWN' => 1
      SeverityMap = Hash[ *(Yell::Severities.zip(Severities).flatten) ]

      # Map Syslog options to internal representation
      OptionMap = {
        :cons   => ::Syslog::LOG_CONS,
        :ndelay => ::Syslog::LOG_NDELAY,
        :nowait => ::Syslog::LOG_NOWAIT,
        :odelay => ::Syslog::LOG_ODELAY,
        :perror => ::Syslog::LOG_PERROR,
        :pid    => ::Syslog::LOG_PID
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

      def initialize( options = {}, &block )
        ident options[:ident] || $0
        options options[:options] || [:pid, :cons]
        facility options[:facility]

        super( options, &block )
      end

      def stream
        @stream ||= _new_stream
      end

      def close
        @stream.close if @stream.respond_to? :close
      rescue
        # do nothing
      ensure
        @stream = nil
      end

      # Identify the calling program
      def ident( val = nil )
        @ident = val
      end

      # Set the log facility for Syslog
      #
      # See {Yell::Adapters::Syslog::OptionMap OptionMap} for allowed values.
      #
      # @example Direct or Symbol
      #   facility( Syslog::LOG_NDELAY )
      #   facility( :ndelay )
      #
      # @example Multiple
      #   facility( :ndelay, Syslog::LOG_NDELAY ):
      def options( *values )
        @syslog_options = values.flatten.map do |v|
          v.is_a?(Symbol) ? OptionMap[v] : v
        end.inject { |a, b| a | b }
      end

      # Set the log facility for Syslog
      #
      # See {Yell::Adapters::Syslog::FacilityMap FacilityMap} for allowed values.
      # @example Direct or Symbol
      #  facility( :user  )
      #  facility( Syslog::LOG_CONSOLE )
      #
      # @example Multiple
      #   facility( :user, Syslog::LOG_CONSOLE )
      def facility( *values )
        @facility = values.flatten.map do |v|
          v.is_a?(Symbol) ? FacilityMap[v] : v
        end.inject { |a, b| a | b }
      end


      private

      def write!( event )
        stream.log( SeverityMap[event.level], clean(event.message) )
      rescue Exception => e
        close

        # re-raise the exception
        raise( e )
      end

      def _new_stream
        return ::Syslog if ::Syslog.opened?

        ::Syslog.open( @ident, @syslog_options, @facility )
      end

      # Borrowed from [SyslogLogger](https://github.com/seattlerb/sysloglogger)
      def clean( message )
        message = message.to_s.dup
        message.strip!
        message.gsub!(/%/, '%%') # syslog(3) freaks on % (printf)
        message.gsub!(/\e\[[^m]*m/, '') # remove useless ansi color codes

        message
      end

    end

    register( :syslog, Yell::Adapters::Syslog )

  end
end
