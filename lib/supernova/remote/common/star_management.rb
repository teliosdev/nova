module Supernova
  module Remote
    module Common

      # Manages types of stars.  Adds a +star_type+ method to subclasses
      # to add it to the type list.
      module StarManagement

        # Class methods.
        module ClassMethods

          # All of the types of stars.  Should be a key-value pair, with
          # the key being the name, and the value being the class.
          #
          # @return [Hash{Symbol => Class}]
          def types
            @@types ||= {}
          end

          # Adds the Star to the type list.
          #
          # @param name [Symbol] the name of the star.
          # @return [self]
          def star_type(name)
            types[name] = self
          end

          # All of the stars that have been defined.  These are
          # different from star types because they contain information
          # such as events.
          #
          # @return [Hash{Symbol => Class}]
          def stars
            @@stars ||= {}
          end

          # Cleans up the inspect a little bit.
          #
          # @return [String]
          def inspect
            @_inspect ||=
              ancestors.take_while { |x| x <= Star }.map(&:name).reverse.join("/").gsub(/\/\z/, "." + as.to_s)
          end

          # The remote to use, by default, for stars.
          #
          # @!parse attr_reader :remote
          # @return [Module]
          def remote
            @remote ||= Remote::Fake
          end

          attr_writer :remote

          # The name of the star.
          #
          # @return [Symbol]
          attr_accessor :as
        end

        # Instance methods.
        module InstanceMethods

          # Cleans up the inspect a little bit.
          #
          # @return [String]
          def inspect
            @_inspect ||= begin
              "#<" <<
                self.class.inspect <<
                (":0x%015x" % object_id) <<
              ">"
            end
          end

          # The remote this star is using.  Can be set locally, but
          # uses the global remote by default.
          #
          # @see ClassMethods#remote
          # @!parse attr_reader :remote
          # @return [Module]
          def remote
            @remote || self.class.remote
          end

          attr_writer :remote

          # Forwards any unkown methods to the remote.
          #
          # @return [Object]
          def method_missing(method, *arguments, &block)
            if remote.respond_to?(method)
              remote.send(method, *arguments, &block)
            else
              super
            end
          end

          # Makes sure ruby knows we're forwarding unknown methods.
          #
          # @return [Boolean]
          def respond_to_missing?(method, include_private = false)
            remote.respond_to?(method, include_private)
          end

        end

        # Called when {StarManagement} is included.  Extends what included
        # it by {ClassMethods}, and includes {InstanceMethods}.
        #
        # @param receiver [Object]
        # @return [void]
        # @api private
        def self.included(receiver)
          receiver.send :include, InstanceMethods
          receiver.extend         ClassMethods
        end
      end
    end
  end
end
