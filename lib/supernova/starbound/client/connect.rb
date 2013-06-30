module Supernova
  module Starbound
    class Client
      module Connect

        Client.handle :connect do
          send_message :encrypt_options, EncryptAgreement.new.encrypt_options
        end

        Client.handle :encrypt_agreement do |packet|
          crypto = CryptoProvider.providers.values.select { |x|
            x.crypto_type == packet.crypt_type }.first

          respond :unsupported, packet unless crypto && crypto.available?

          new_crypto = crypto.new
          new_crypto.private_key!
          new_crypto.other_public_key = packet.public_key

          client.send_packet({
            :crypt_type => new_crypto.class.crypto_type,
            :size => new_crypto.public_key.bytesize,
            :public_key => new_crypto.public_key
          }, :encrypt_agreement)

         client.crypto_provider = new_crypto
        end

        Client.handle :response => :ok do |packet|
          Supernova.logger.info { packet.to_s }
        end

      end
    end
  end
end
