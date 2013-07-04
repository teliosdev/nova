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

          # When the star is subclassed, add the subclass
          # automatically to the star type list, unless it doesn't
          # have a proper name.
          #
          # @api private
          def inherited(klass)
            return unless klass.name

            type = klass.name.gsub(/([A-Z])/) { |a| "_#{a.downcase}" }.gsub("::", "/")[1..-1].intern
            klass.star_type(type)
          end

          # Adds the Star to the type list.
          #
          # @param name [Symbol] the name of the star.
          # @return [self]
          def star_type(name)
            types.delete_if { |_, v| v == self }
            types[name] = self
            self.type   = name
            stars[name] = {}
            self
          end

          # All of the stars that have been defined.  These are
          # different from star types because they contain information
          # such as events.
          #
          # @return [Hash{Symbol => Class}]
          def stars
            @@stars ||= {}
          end

          # An accessor for {#stars}.
          #
          # @param star_name [Symbol]
          # @return [Hash, Class]
          def [](star_name)
            stars[star_name]
          end

          # Cleans up the inspect a little bit.
          #
          # @return [String]
          def inspect
            @_inspect ||=
              ancestors.take_while { |x| x <= Star }.map(&:name).reverse.join("/").gsub(/\/\z/, "." + as.to_s)
          end

          # Just a way to write it; syntaxic sugar.  It returns what
          # was passed.
          #
          # @example
          #   Supernova::Star/Type.something
          # @param other_class [Class]
          # @return [Class] other_class.
          def /(other_class)
            other_class
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

          # The type of the star.
          #
          # @return [Symbol]
          attr_accessor :type

          # The platforms this star is compatible with.  Empty or nil
          # for all platforms.
          #
          # @return [nil, Array<Symbol>]
          attr_accessor :required_platforms

          # Retrieves the star with the given name.
          #
          # @example
          #   Supernova::Star/Type.klass
          # @return [Class]
          def method_missing(method, *args, &block)
            if (stars.key?(method) || stars[type].key?(method)) && args.length == 0
              stars[method] || stars[type][method]
            else
              super
            end
          end
        end

        # Instance methods.
        module InstanceMethods

          # Checks for the correct platforms in initialization.  If
          # it's not on the right platform, raises an error.
          #
          # @raise [NoPlatformError] if it's not available on the
          #   platform.
          def initialize(remote = nil)
            @remote = remote || self.remote
            diff = (self.class.required_platforms || []) - platform
            p platform
            raise NoPlatformError,
              "Requires any of #{diff.join(', ')} to run on." unless diff.length == 0

            super(remote)
          end

          # Cleans up the inspect a little bit.
          #
          # @return [String]
          def inspect
            @_inspect ||= begin
              "#<" <<
                self.class.inspect <<
                (":0x%014x" % object_id) <<
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
