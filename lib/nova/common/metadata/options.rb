module Nova
  module Common
    module Metadata

      # Handles options that are passed to the module.
      #
      # @note This stores everything in a hash, and all keys within
      #   hash are Strings, no matter what.
      class Options < BasicObject

        # Initialize the options class.
        #
        # @param data [Hash] the data to represent with this
        #   class.
        def initialize(data)
          @_data = data
          _clean_data
        end

        # Accessor for this class.  Returns the default value if the
        # key does not exist.
        #
        # @param key [#to_s] the key to look up.
        # @return [Object] the value.
        def [](key)
          fetch(key) { default(key.to_s) }
        end

        # Fetches the given key.  If it doesn't exist, uses the given
        # default value or calls the block.
        #
        # @param key [#to_s] the key to look up.
        # @param default_value [Object] the default object to return,
        #   if the key doesn't exist in the table.
        # @yieldparam key [String] the key that was looked up.
        # @yieldreturn [Object] the value to use.
        # @return [Object] the value of the key.
        def fetch(key, *args, &block)
          @_data.fetch(key.to_s, *args, &block)
        end

        # Forwards all methods to the hash. 
        #
        # @param method [Symbol] the method to forward.
        # @param arguments [Array<Object>] the arguments for the
        #   method.
        # @return [Object]
        def method_missing(method, *arguments, &block)
          @_data.public_send(method, *arguments, &block)
        end

        private

        # Cleans the data hash by forcing all keys to strings, and then
        # freezes the newly created hash.
        #
        # @return [Hash]
        def _clean_data
          new_data = {}

          @_data.each do |k, v|
            new_data[k.to_s] = v
          end

          @_data = new_data.freeze
        end

      end
    end
  end
end