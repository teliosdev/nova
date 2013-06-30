module Supernova
  module Starbound
    module CryptoProviders

      class OpenSSL < CryptoProvider

        KEY_SIZE = 4096
        SECRET_SIZE = KEY_SIZE / 16

        register :openssl, 2

        def self.available?
          @_available||= begin
            require 'openssl'
            true
          rescue LoadError => e
            false
          end
        end

        def self.version
          if defined? ::OpenSSL
            ::OpenSSL::VERSION
          else
            super
          end
        end

        def self.encrypt_agreement
          "openssl/AES-256-CBC"
        end

        def encrypt(data)
          data[:encrypted] = 2
          data[:nonce] = ::OpenSSL::Random.random_bytes(24)
          cipher = ::OpenSSL::Cipher::AES256.new(:CBC)
          cipher.encrypt
          cipher.key  = options[:shared_secret]
          cipher.iv   = data[:nonce]
          encrypted   = cipher.update(data[:body]) + cipher.final
          data[:body] = digest(encrypted) << encrypted
          data[:size] = data[:body].bytesize
        end

        def decrypt(data)
          decipher = ::OpenSSL::Cipher::AES256.new(:CBC)
          decipher.decrypt
          decipher.key = options[:shared_secret]
          decipher.iv  = data[:nonce]
          message_digest = data[:body][0..19]
          raise IncorrectDigestError if message_digest != digest(data[:body][20..-1])

          decipher.update(data[:body][20..-1]) + decipher.final
        end

        def private_key!
          options[:private] = ::OpenSSL::PKey::RSA.new(KEY_SIZE)
        end

        def public_key
          if options[:other_public]
            options[:shared_secret] = ::OpenSSL::Random.random_bytes(SECRET_SIZE)
            options[:other_public].public_encrypt(options[:shared_secret])
          else
            options[:public] ||= options[:private].public_key.to_der
          end
        end

        def other_public_key=(public_key)
          if options[:public]
            options[:shared_secret] = options[:private].private_decrypt(public_key)
          else
            options[:other_public] = ::OpenSSL::PKey::RSA.new(public_key)
          end
        end

        private

        def digest(data)
          ::OpenSSL::HMAC.digest(::OpenSSL::Digest::SHA1.new, options[:shared_secret],
            data)
        end

        class IncorrectDigestError < StandardError; end
      end
    end
  end
end
