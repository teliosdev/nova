require 'digest/sha2'

module Supernova
  module Starbound
    module Encryptors

      # Handles encryption using the OpenSSL library.  Shares the
      # shared secret using RSA public key encryption, creates a
      # HMAC digest of the body using the shared secret as a key, and
      # encrypts the body using AES-256-CBC encryption.
      class OpenSSL < Encryptor

        # The RSA key size for the key exchange.
        RSA_KEY_SIZE = 4096

        # The shared secret size, in bytes.  If RSA_KEY_SIZE is 4096,
        # this is 256.
        SECRET_SIZE = RSA_KEY_SIZE / 16

        encryptor_name "openssl/rsa-#{RSA_KEY_SIZE}/aes-256-cbc"
        register! 1

        # see Encryptor.available?
        def self.available?
          begin
            require 'openssl'
            true
          rescue LoadError
            false
          end
        end

        # (see Encryptor#encrypt)
        def encrypt(packet)
          packet = packet.clone
          cipher = ::OpenSSL::Cipher::AES256.new(:CBC)
          cipher.encrypt
          cipher.key = options[:shared_secret]

          # we have to fit the packet's nonce size.
          packet[:nonce] = cipher.iv = ::OpenSSL::Random.random_bytes(24)

          packet.body = hmac_digest(packet[:body]) +
            cipher.update(packet[:body]) + cipher.final
          packet
        end

        # (see Encryptor#decrypt)
        def decrypt(packet)
          packet = packet.clone
          decipher = ::OpenSSL::Cipher::AES256.new(:CBC)
          decipher.decrypt
          decipher.key = options[:shared_secret]
          decipher.iv  = packet[:nonce]

          digest = packet[:body][0..63]
          actual_body = packet[:body][64..-1]

          if hmac_digest(actual_body) != digest
            raise InvalidDigestError
          end

          packet.body = decipher.update(actual_body) + decipher.final
          packet
        end

        # (see Encryptor#private_key!)
        def private_key!
          options[:private] = ::OpenSSL::PKey::RSA.new(KEY_SIZE)
        end

        # If we have already recieved the other public key, we'll
        # generate the secret here, and return the encrypted version
        # of that secret here.  Otherwise, we'll generate our private
        # key and return that in DER format.
        #
        # @return [String]
        def public_key
          if options[:other_public]
            options[:shared_secret] =
              ::OpenSSL::Random.random_bytes(SECRET_SIZE)
            options[:other_public].public_encrypt(
              options[:shared_secret])
          else
            options[:public] ||= options[:private].public_key.to_der
          end
        end

        # If we already have a public key, that means that the value
        # that's passed to this method is the shared secret.
        # Otherwise, it really is the public key of the other remote.
        # If the passed value is a shared secret, it's decrypted with
        # our private key and stored.  If it's the other public key,
        # it's instantized to a openssl RSA key, and stored.
        #
        # @return [void]
        def other_public_key=(public_key)
          if options[:public]
            options[:shared_secret] =
              options[:private].private_decrypt(public_key)
          else
            options[:other_public] =
              ::OpenSSL::PKey::RSA.new(public_key)
          end
        end

        private

        # Provides a digest of the data, using HMAC.
        #
        # @return [String]
        def hmac_digest(body)
          ::OpenSSL::HMAC.digest(Digest::SHA2.new(512),
            options[:shared_secret], body)
        end

        # Raised if the given digest does not match the packet.
        class InvalidDigestError < StandardError; end

      end
    end
  end
end
