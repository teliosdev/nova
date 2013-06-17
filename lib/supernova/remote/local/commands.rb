require 'cocaine'

module Supernova
  module Remote
    module Local

      # Handles running commands on the local machine.
      module Commands

        # Creates a CommandLine with its default Runner (most likely
        # the POSIX spawner).
        #
        # @see Fake::Commands#line
        # @param (see Fake::Commands#line)
        # @return (see Fake::Commands#line)
        def line(command, arguments, options = {})
          options.merge! logger: Supernova.logger
          Cocaine::CommandLine.new(command, arguments, options)
        end


        # Executes a command with the given arguments.
        #
        # @see Fake::Commands#exec
        # @param (see Fake::Commands#exec)
        # @return (see Fake::Commands#exec)
        def exec(command, arguments, interops = {}, options = {})
          line(command, arguments, options).run(interops)
        end

      end
    end
  end
end
