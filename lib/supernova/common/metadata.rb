module Supernova
  module Remote
    module Common

      # Manages the metadata, such as required options, ruby versions,
      # required platforms/versions, etc.
      module Metadata

        # Class methods.
        module ClassMethods

          # @overload metadata(&block)
          #   Runs the metadata block in a metadata instance, and then
          #   sets the metadata information for this star.
          #
          #   @yield [Data]
          #   @return [Data]
          # @overload metadata
          #   Returns the metadata for this star.
          #
          #   @return [Data]
          def metadata
            if block_given?
              data = Data.new
              yield data
              @metadata = data
            else
              @metadata ||= Data.new
            end
          end

        end

        # Instance methods.
        module InstanceMethods

          # Handles validation for the metadata.
          def initialize(*)
            @data = self.class.metadata
            @data.validate! remote
          end

          # Sets the options, validating them.
          def options=(options)
            @data.validate_options! options
            @options = options
          end

        end

        # Called when {Metadata} is included.  Extends what included
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
