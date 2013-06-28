require 'fast_open_struct'

require 'supernova/starbound/client/context'

module Supernova
  module Starbound
    class BasicClient
      def self.handlers
        @handlers ||= Hash.new { |hash, key| hash[key] = Hash.new { |h, k| h[k] = [] } }
      end

      def self.handle(thing, &block)
        if thing.is_a? Hash
          packet = thing.keys.first
          type   = thing.values.first
        else
          packet = thing
          type   = nil
        end

        handlers[packet][type] << block
      end

      attr_accessor :tcp_socket

      attr_accessor :packet_number

      attr_accessor :crypto_provider

      attr_accessor :run

      attr_accessor :data

      def initialize(socket = nil)
        @tcp_socket = socket
        @packet_number = 0
        @run = true
        @data = {}
        @context = Context.new
        @context.bind! self
        @crypto_provider = CryptoProvider[:plain].new
      end

      def connect(to_ip = "127.0.0.1", to_port = 2010)
        @tcp_socket = TCPSocket.new(to_ip, to_port)

        handle_packet(:connect, {})
      end

      def listen_data(other = nil)
        while @run do
          read_packet other
        end
      end

      def send_packet(data, type = :packet)
        out_data = Packets.structs[type].pack(data)

        outer = { :encrypted => 0, :nonce => "", :body => out_data,
          :size => out_data.bytesize, :struct => Packets::STRUCT_MAPS[type] }


        @crypto_provider.encrypt(outer)

        outer[:digest] = Digest::SHA1.digest(outer[:body])

        Supernova.logger.debug { "Sending packet #{outer}" }

        out = Packets.structs[:basic_packet].pack(outer)

        @tcp_socket.write out
        @tcp_socket.flush
      end

      def read_packet(other = nil)
          tcp, = IO.select [@tcp_socket], nil, nil, 0.1

          return unless tcp && tcp.first && !closed_socket?

          pack = Packets.structs[:basic_packet].unpack_from_socket(@tcp_socket)
          type = Packets::STRUCT_MAPS.key(pack[:struct])
          Supernova.logger.debug { "Recieved packet #{pack}" }

          if pack[:encrypted] != @crypto_provider.class.crypto_type
            raise StandardError, "Packet does not match current crypto provider."
          end

          digest = Digest::SHA1.digest pack[:body]

          if pack[:digest] != digest
            Supernova.logger.error { "The packet's digest does not match the data!" }
          end


          data = @crypto_provider.decrypt(pack)
          complete_packet = FastOpenStruct.new Packets.structs[type].unpack(data)

          handle_packet type, complete_packet, other
      end

      private

      def handle_packet(type, packet, other = nil)
        packet_type = Packets::Type.key(packet[:packet_type])
        Supernova.logger.debug { "Handing packet #{type} (#{packet_type})" }
        self.class.handlers[type][packet_type].map do |b|
          @context.instance_exec packet, other, &b
        end
      end

      def closed_socket?
        peek = @tcp_socket.recvmsg(2, Socket::MSG_PEEK)

        if peek[0].length == 0
          @run = false
          @tcp_socket.close
          handle_packet(:close, {})
          true
        end

        false
      end
    end

    class ServerClient < BasicClient; end
  end
end
