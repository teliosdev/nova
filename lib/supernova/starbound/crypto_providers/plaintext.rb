module Supernova
  module Starbound
    module CryptoProviders
      class Plaintext < CryptoProvider
        register :plain, 3

        def self.available?
          true
        end

        def self.version
          "1.0.0"
        end

        def self.encrypt_agreement
          "plaintext"
        end

        def encrypt(data)
          data[:encrypted] = 3
          data
        end

        def decrypt(data)
          data[:body]
        end
      end
    end
  end
end
