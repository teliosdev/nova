module Supernova
  module Starbound
    class EncryptionAgreement

      def encrypt_options
        providers = CryptoProvider.providers.values.select(&:available?)

        providers.sort { |a, b|
          a.crypto_type <=> b.crypto_type
        }.map(&:encrypt_agreement).join(":")
      end

      def server_encryption(encrypt)
        e = encrypt.split(":")

        providers = CryptoProvider.providers.values.select do |prov|
          e.include? prov.encrypt_agreement
        end

        provider = nil

        while provider == nil && e.length > 0 do
          providers.select { |x| x.encrypt_agreement == e.shift }.first
        end

        if provider.encrypt_agreement =~ /plaintext/
          Supernova.logger.warn { "A plaintext encrption agreement was selected for communication." }
        end

        provider.new
      end

    end
  end
end
