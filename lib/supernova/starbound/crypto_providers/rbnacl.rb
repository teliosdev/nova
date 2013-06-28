module Supernova
  module Starbound
    module CryptoProviders
      class RbNaCl < CryptoProvider

        register :rbnacl, 1

        def self.available?
          @_available ||= begin
            require 'rbnacl'
            true
          rescue LoadError => e
            false
          end
        end

        def self.version
          if defined? Crypto
            Crypto::VERSION
          else
            super
          end
        end

        def encrypt(data)
          data[:encrypted] = 1
          data[:nonce] = Crypto::Random.random_bytes(24)
          box = Crypto::Box.new(options[:public_key], options[:private_key])
          enc = box.encrypt(data[:nonce], data[:body])
          data[:size] = enc.bytesize
          data[:body] = enc
        end

        def decrypt(data)
          box = Crypto::Box.new(options[:public_key], options[:private_key])
          box.decrypt(data[:nonce], data[:body])
        end

        def private_key!
          options[:private_key] = Crypto::PrivateKey.generate
        end

        def public_key
          options[:private_key].public_key.to_bytes
        end

        def other_public_key=(public_key)
          options[:public_key] = Crypto::PublicKey.new(public_key)
        end

      end
    end
  end
end
