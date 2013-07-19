require 'forwardable'

require 'nova/common/features/feature'

module Nova
  module Common

    # The features that the star has.  These are optional
    # behaviors that are defined on the stars, but if they are
    # implemented they should follow around the same behaviours of
    # other features implemented on other stars with the same name.
    module Features

      # Class methods.
      module ClassMethods

        # The list of features the star supports.
        #
        # @return [Hash] the features.
        def features
          @features ||= {}
        end

        # Whether or not this star supports a feature.
        #
        # @return [Boolean]
        def supports?(feature_name)
          features.key? feature_name
        end

        # Define a feature, with the given name and block.
        #
        # @param name [Symbol] the name of the feature.
        # @param options [Hash] the options for the feature.
        # @yield to create the feature.
        # @return [Feature] the feature that was defined.
        def feature(name, options = {}, &block)
          new_feature = Feature.new(name, options)
          new_feature.instance_exec &block
          features[name] = new_feature
        end

      end

      # Instance methods.
      module InstanceMethods

        extend Forwardable

        # A hash of features.  Any features are bound to this class,
        # after their first access.  If a feature is accessed without
        # existing, a fake feature is created and bound to self.
        # All features are cached in the hash after being bound.
        #
        # @see Features::ClassMethods#features
        # @return [Hash]
        def features
          @_features ||= Hash.new do |hash, key|
            class_feature = self.class.features[key]

            if class_feature
              hash[key] = class_feature.bind(self)
            else
              hash[key] = Feature.new(key, {}).bind(self).fake!
            end
          end
        end

        # Returns a feature that matches the given name.  If it
        # doesn't exist, a fake one is created, and bound to self.
        #
        # @param name [Symbol] the name of the feature.
        # @return [Feature]
        def feature(name)
          features[name]
        end

        def_delegators "self.class", :supports?
      end

      # Called when {Features} is included.  Extends what included
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
