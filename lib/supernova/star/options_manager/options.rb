#require 'date'

module Supernova
  class Star
    module OptionsManager

      # The options, as given and defined.  This will contain
      # more in a future update.
      class Options

        # Initialize the options.
        def initialize(options, validator)
          @options = options
          @validator = validator
        end

        # nothing here.
        def method_missing(method, *args, &block)
          @options.public_send(method, *args, &block)
        end

      end
    end
  end
end
