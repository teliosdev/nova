module Supernova
  module Remote
    module Common
      module Features

        # The information about the feature that was defined.
        class Feature

          # The name of the feature.
          #
          # @return [Symbol]
          attr_accessor :name

          # The options of the feature.
          #
          # @return [Hash]
          attr_accessor :options

          def initialize(name, options)
            @name = name
            @options = options
            @bind = Object.new
            @fake = false
          end

          include EventHandler

          # Enables the feature and runs the :enable event, if it
          # exists.
          #
          # @return [nil, Object]
          def enable!
            run(:enable)
          end

          # Disables the feature and runs the :disable event, if it
          # exists.
          #
          # @return [nil, Object]
          def disable!
            run(:disable)
          end

          # Whether or not this feature is fake.  By fake, it means that
          # it was not created with the defining class as a feature; it
          # does not have any events at all, and its only purpose is to
          # mock the behavior of a real, defined feature.
          #
          # @return [Boolean]
          def fake?
            @fake
          end

          # Marks this feature as fake.  This is not reversable.
          #
          # @see #fake?
          # @return [self]
          def fake!
            @fake = true
            self
          end

        end
      end
    end
  end
end
