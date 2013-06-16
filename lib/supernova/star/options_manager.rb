require 'supernova/star/options_manager/options'
require 'supernova/star/options_manager/options_validator'

module Supernova
  class Star
    # Handles the options when they're passed to the star.  Uses a
    # definition to do this.
    module OptionsManager
      module ClassMethods

        # The options validator class used to define the options.  If it
        # doesn't exist, returns a blank validator.
        #
        # @return [OptionsValidator]
        def options_validator
          @options_validator ||= OptionsValidator.new {}
        end

        # Define how options are set up.  Requires a block.
        #
        # @see [Options]
        # @returns [Options]
        def with_options
          @options = OptionsValidator.new(&Proc.new)
        end
      end

      module InstanceMethods

        # Sets the options.  Raises an error unless the options are valid.
        #
        # @raises [InvalidOptionsError] unless the options match the definition.
        # @param options [Hash] the options for use in the Star.
        # @return [Options]
        def options=(options)
          raise InvalidOptionsError unless self.class.options_validator.valid?(options)

          @options = Options.new(options, self.class.options_validator)
        end

        attr_reader :options
      end

      class InvalidOptionsError < StandardError; end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end
