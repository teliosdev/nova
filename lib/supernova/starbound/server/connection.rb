module Supernova
  module Starbound
    class Server
      module Connection

        #ServerClient.handle_packet Packets::PUBLIC_KEY do |packet, client|

        #  client.private_key = Crypto::PrivateKey.generate
        #  public_key = Crypto::Encoder[:base64].encode(client.private_key.public_key.to_bytes)

        #  client.send_packet :packet_type => Packets::PUBLIC_KEY, :packet_id => packet[:packet_id],
        #    :size => public_key.size, :body => public_key

        #  client.public_key = Crypto::PublicKey.new(packet[:body], :base64)
        #end

        #ServerClient.handle_packet Packets::ECHO do |packet, client|
        #  client.send_packet :packet_type => Packets::ECHO, :packet_id => packet[:packet_id],
        #    :size => packet[:body].bytesize, :body => packet[:body]
        #end

        #ServerClient.handle_packet Packets::PASSWORD_AUTH do |packet, client, serv|
        #  result = if srv.try_auth(packet[:body])
        #    "success"
        #  else
        #    "fail"
        #  end

        #  client.send_packet :packet_type => Packets::PASSWORD_AUTH,
        #    :packet_id => packet[:packet_id],
        #    :size => result.bytesize,
        #    :body => result
        #end

        ServerClient.handle :close do |packet|
          Supernova.logger.info { "Client closed connection (reason: #{packet[:body]})" }

          client.run = false
          Thread.current[:close] = true
        end

        ServerClient.handle :packet => :encrypt_options do |packet|
          client_encrypts = packet[:body].split("\n")
          server_encrypts = available_providers.each.map { |x| "#{x[0]} #{x[1]}" }
          common = client_encrypts & server_encrypts

          encrypt = common.first.split(' ').first.to_sym
          provider = CryptoProvider[encrypt].new
          provider.private_key!
          client.send_packet({
            :crypt_type => provider.class.crypto_type,
            :size => provider.public_key.bytesize,
            :public_key => provider.public_key
          }, :encrypt_agreement)

          @temp_provider = provider
        end

        ServerClient.handle :encrypt_agreement do |packet|
          @temp_provider.other_public_key = packet.public_key
          client.crypto_provider = @temp_provider

          respond :ok, packet
        end

      end
    end
  end
end
