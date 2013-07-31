module Nova
  module Common
    module Metadata

      # Handles options that are passed to the module.
      #
      # @note This stores everything in a hash, and all keys within
      #   hash are Strings, no matter what.
      class Options < Hash

        # Initialize the options class.
        #
        # @param data [Hash] the data to represent with this
        #   class.
        def initialize(data)
          merge! data
          _clean_data
          freeze
        end

        # Accessor for this class.  Returns the default value if the
        # key does not exist.
        #
        # @param key [#to_s] the key to look up.
        # @return [Object] the value.
        def [](key)
          self.fetch(key) { default(key.to_s) }
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
          coerce_to_options super(key.to_s, *args, &block)
        end

        private

        # Cleans the data hash by forcing all keys to strings, and then
        # freezes the newly created hash.
        #
        # @return [Hash]
        def _clean_data
          new_data = {}

          each do |k, v|
            new_data[k.to_s] = v
          end

          replace(new_data)
        end

        # Coerces the given argument into an {Options} class.  Used for
        # fetches.
        #
        # @param value [Object] the value to coerce.
        # @return [Object] the coerced value (or the value itself if
        #   it could not be coerced).
        def coerce_to_options(value)
          if value.is_a?(Hash)
            Options.new(value)
          elsif value.is_a?(Array)
            value.map { |v| coerce_to_options(v) }
          else
            value
          end
        end

      end
    end
  end
end