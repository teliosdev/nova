require 'nova/remote/fake/commands'
require 'nova/remote/fake/file_system'
require 'nova/remote/fake/operating_system'
require 'nova/remote/fake/platform'

module Nova
  module Remote

    # This is a fake remote.  It does nothing.  Really.  You can trust
    # me.
    class Fake

      # Returns a platform instance.  Caches the instance across
      # method calls.
      #
      # @see Platform
      # @return [Platform]
      def platform
        @_platform ||= Platform.new
      end

      # Returns a command instance.  Caches the instance across method
      # calls.
      #
      # @see Commands
      # @return [Commands]
      def command
        @_command ||= Commands.new
      end

      # Returns an operating system instance.  Caches the instance
      # across method calls.
      #
      # @see OperatingSystem
      # @return [OperatingSystem]
      def operating_system
        @_operating_system ||= OperatingSystem.new
      end

      # Returns a file system instance.  Caches the instance across
      # method calls.
      #
      # @see FileSystem
      # @return [FileSystem]
      def file_system
        @_file_system ||= FileSystem.new
      end

    end
  end
end
