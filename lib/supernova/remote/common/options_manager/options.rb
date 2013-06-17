module Supernova
  module Remote
    module Common
      module OptionsManager

        # The options, as given and defined.  This will contain
        # more in a future update.
        class Options

          # Initialize the options.
          #
          # @param options [Hash] the options.
          # @param validator [OptionsValidator]
          def initialize(options, validator)
            @options = options
            @validator = validator
          end

          # nothing here.
          def method_missing(method, *args, &block)
            @options.public_send(method, *args, &block)
          end

          # Nothing here either.
          def respond_to_missing?(method, include_private = false)
            @options.respond_to?(method, include_private)
          end

        end
      end
    end
  end
end
