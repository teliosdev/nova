module Supernova
  module Starbound
    module Encryptors

      # Provides encryption using RbNaCl.
      class RbNaCl < Encryptor

        encryptor_name "rbnacl/1.0.0"
        register! 2

        # (see Encryptor.available?)
        def self.available?
          @_available ||= begin
            require 'rbnacl'
            true
          rescue LoadError
            false
          end
        end

        # (see Encryptor#encrypt)
        def encrypt(packet)
          packet = packet.clone
          packet[:nonce] = Crypto::Random.random_bytes(24)
          box = Crypto::Box.new(options[:public_key], options[:private_key])
          enc = box.encrypt(packet[:nonce], packet[:body])

          packet.body = enc
          packet
        end

        # (see Encryptor#decrypt)
        def decrypt(packet)
          packet = packet.clone
          box = Crypto::Box.new(options[:public_key], options[:private_key])
          packet.body = box.decrypt(packet[:nonce], packet[:body])

          packet
        rescue Crypto::CryptoError => e
          raise EncryptorError, e
        end

        # Generates a private key.
        #
        # @return [void]
        def private_key!
          options[:private_key] = Crypto::PrivateKey.generate
        end

        # Returns the public key for this remote.
        #
        # @return [String]
        def public_key
          options[:private_key].public_key.to_bytes
        end

        # Sets the other public key to the given value.
        #
        # @return [void]
        def other_public_key=(public_key)
          options[:public_key] = Crypto::PublicKey.new(public_key)
        end

      end
    end
  end
end
