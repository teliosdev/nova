require 'supernova/remote/common/options_manager/options'
require 'supernova/remote/common/options_manager/options_validator'

module Supernova
  module Remote
    module Common
      # Handles the options when they're passed to the star.  Uses a
      # definition to do this.
      module OptionsManager

        # Class methods.
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
          # @see Options
          # @return [Options]
          def with_options
            @options_validator = OptionsValidator.new(&Proc.new)
          end
        end

        # Instance methods.
        module InstanceMethods

          # Sets the options.  Raises an error unless the options are valid.
          #
          # @raise [InvalidOptionsError] unless the options match the definition.
          # @param options [Hash] the options for use in the Star.
          # @return [Options]
          def options=(options)
            raise InvalidOptionsError unless self.class.options_validator.valid?(options)

            @options = Options.new(options, self.class.options_validator)
          end

          # @!method options=(options)
          #  Hello, world.


          # Gives the options.
          #
          # @return [Options]
          attr_reader :options
        end

        # Called when {OptionsManager} is included.  Extends what included
        # it by {ClassMethods}, and includes {InstanceMethods}.
        #
        # @param receiver [Object]
        # @return [void]
        # @api private
        def self.included(receiver)
          receiver.extend         ClassMethods
          receiver.send :include, InstanceMethods
        end
      end
    end
  end
end
