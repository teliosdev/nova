module Supernova
  module Starbound
    class Client
      module Connect

        #Client.handle_packet :connect do |_, client|
        #  client.private_key = Crypto::PrivateKey.generate
        #  client_public_key = Crypto::Encoder[:base64].encode(client.private_key.public_key.to_bytes)

        #  client.send_packet :packet_type => Packets::RBNACL_PUBLIC_KEY, :packet_id => client.packet_number+= 1,
        #    :size => client_public_key.bytesize, :body => client_public_key
        #end

        #Client.handle_packet Packets::PUBLIC_KEY do |packet, client|
        #  client.public_key = Crypto::PublicKey.new(packet[:body], :base64)
        #end

        #Client.handle_packet Packets::ECHO do |packet, client|
        #  Supernova.logger.info { "Server echoed #{packet.inspect}" }
        #end

        Client.handle :connect do
          send_message :encrypt_options, available_providers.map { |x|
            "#{x[0]} #{x[1]}" }.join("\n")
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
