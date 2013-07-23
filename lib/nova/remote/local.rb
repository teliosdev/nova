require 'nova/remote/local/commands'
require 'nova/remote/local/file_system'
require 'nova/remote/local/operating_system'
require 'nova/remote/local/platform'

module Nova
  module Remote

    # This is the local remote.  It handles running stars on the
    # running computer.
    #
    # @todo Add tests.
    class Local
      
     # Returns a platform instance.  Caches the instance across
      # method calls.
      #
      # @see Platform
      # @return [Platform]
      def platform
        @_platform ||= Remote::Local::Platform.new(self)
      end

      # Returns a command instance.  Caches the instance across method
      # calls.
      #
      # @see Commands
      # @return [Commands]
      def command
        @_command ||= Remote::Local::Commands.new(self)
      end

      # Returns an operating system instance.  Caches the instance
      # across method calls.
      #
      # @see OperatingSystem
      # @return [OperatingSystem]
      def operating_system
        @_operating_system ||= Remote::Local::OperatingSystem.new(self)
      end

      # Returns a file system instance.  Caches the instance across
      # method calls.
      #
      # @see FileSystem
      # @return [FileSystem]
      def file_system
        @_file_system ||= Remote::Local::FileSystem.new(self)
      end

    end
  end
end