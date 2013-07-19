require 'command/runner'

module Nova
  module Remote
    class Fake

      # Manages running commands.
      #
      # @abstract
      class Commands

        # Creates a CommandLine with its default runner.
        #
        # @abstract
        # @note Does nothing.  Since we're a fake remote, we'll
        #   overwrite the backend with a fake one.
        # @see https://github.com/redjazz96/command-runner
        # @param command [String] the command to run.
        # @param arguments [String] the arguments to be passed to the
        #   command.
        # @return [Command::Runner] the runner.
        def line(command, arguments = "", options = {})
          options.merge! :logger => Nova.logger
          c = Command::Runner.new(command, arguments, options)
          c.backend = Command::Runner::Backends::Fake.new
          c
        end

        # Checks to see if the command exists.
        #
        # @abstract
        # @note Does nothing.  Always returns false since this is the
        #   fake remote.
        # @param command [String] the command to check the existance
        #   of.
        # @return [Boolean]
        def command_exists?(command)
          false
        end

      end
    end
  end
end
