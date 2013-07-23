require 'command/runner'

module Nova
  module Remote
    class Local

      # Manages running commands.
      class Commands < Part

        # Creates a CommandLine with its default runner.
        #
        # @see https://github.com/redjazz96/command-runner
        # @param command [String] the command to run.
        # @param arguments [String] the arguments to be passed to the
        #   command.
        # @return [Command::Runner] the runner.
        def line(command, arguments = "", options = {})
          options.merge! :logger => Nova.logger
          Command::Runner.new(command, arguments, options)
        end

        # Checks to see if the command exists.
        #
        # @note Does nothing.  Always returns false since this is the
        #   fake remote.
        # @param command [String] the command to check the existance
        #   of.
        # @return [Boolean]
        def exists?(command)
          not line("which", "{command}").run(command: command).nonzero_exit?
        end

      end
    end
  end
end
