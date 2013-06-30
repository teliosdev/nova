module Supernova
  module Starbound
    class BasicClient
      class Context

        attr_accessor :client

        def bind!(to_client)
          @client = to_client
        end

        def send_message(type, body, opts = {})
          contents = { :packet_type => Packets::Type[type],
            :packet_id => @client.packet_number += 1,
            :size => body.bytesize, :body => body }

          contents.merge! opts
          @client.send_packet contents
        end

        def respond(type, to, body = "", opts = {})
          contents = { :packet_type => Packets::Type[type],
            :packet_id => @client.packet_number += 1,
            :size => body.bytesize, :body => body,
            :packet_response_type => to[:packet_type] || 0,
            :packet_response_id   => to[:packet_id] || 0 }

          contents.merge! opts
          @client.send_packet contents, :response
        end

      end
    end
  end
end
