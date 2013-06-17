require 'cocaine'

module Supernova
  module Remote
    module Fake

      # Handles running commands on the fake remote.  (No commands
      # are ever actually excuted here.)
      module Commands

        # Creates a {Cocaine::CommandLine} with the Supernova logger,
        # and the FakeRunner.  Returns it.
        #
        # @param command [String] the command to run.
        # @param arguments [String] the arguments to accompany the
        #   command.  If it contains +:symbols+ in the text, they
        #   can be interpolated when executed.
        # @param options [Hash] options to be passed to the CommandLine.
        # @example
        #   line("echo", "hello :world").command(world: "foo") # => "echo hello foo"
        # @return {Cocaine::CommandLine}
        def line(command, arguments, options = {})
          options.merge! logger: Supernova.logger, runner: Cocaine::CommandLine::FakeRunner.new
          Cocaine::CommandLine.new(command, arguments, options)
        end

        # Executes a line with the given command and arguments.
        #
        # @param (see #line)
        # @param interops [Hash] the interpolations to be made to the
        #   command by Cocaine.
        def exec(command, arguments, interops = {}, options = {})
          line(command, arguments, options).run(interops)
        end

      end
    end
  end
end
