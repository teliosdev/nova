require 'command/runner'

module Supernova
  module Remote
    module Fake

      # Handles running commands on the fake remote.  (No commands
      # are ever actually excuted here.)
      module Commands

        # Creates a CommandLine with its default Runner (most likely
        # the POSIX spawner).
        #
        # @see Fake::Commands#line
        # @param (see Fake::Commands#line)
        # @return (see Fake::Commands#line)
        def line(command, arguments, options = {})
          options.merge! logger: Supernova.logger
          c = Command::Runner.new(command, arguments, options)
          c.backend = Command::Runner::Backends::Fake.new
          c
        end


        # Executes a command with the given arguments.
        #
        # @see Fake::Commands#exec
        # @param (see Fake::Commands#exec)
        # @return (see Fake::Commands#exec)
        def exec(command, arguments, interops = {}, options = {})
          line(command, arguments, options).pass(interops)
        end


        # Checks to see if the command exists.
        #
        # @param command [String] the command to check the existance
        #   of.
        # @return [Boolean]
        def command_exists?(command)
          line("which", "{command}").pass(command: command) != ""
        end

      end
    end
  end
end
