require 'packed_struct'

module Supernova
  module Starbound
    class Protocol
      class Packet

        extend PackedStruct

        struct_layout :packet do
          little uint32 size
          little uint32 packet_id
          little int packet_type
          little string nonce[24]

          string body[size]
          null
        end

        struct_layout :response do
          little uint32 size
          little uint32 packet_response_id
          little int packet_response_type
          little int packet_type
          little string nonce[24]

          string body[size]
          null
        end

        struct_layout :enc_type do
          little int index
        end

        # A list of the types of packets in existance, and their
        # packet_type codes.
        Type = {
          :nul => 0x00,

          # handshake
          :protocol_version   => 0x01,
          :encryption_options => 0x02,
          :public_key         => 0x03,

          # other stuff
          :standard_error     => 0x04,
          :close              => 0x05,

          # content
          :echo               => 0x06
        }.freeze

        # Used internally to check the types of packets when
        # unpacking.
        Structs = {
          :packet   => 0x00,
          :response => 0x01
        }.freeze

        # For checking why the protocol was closed.
        CloseReasons = {
          :none     => 0x00,
          :shutdown => 0x01
        }.freeze

        # Provides access to the {Type} constant.
        #
        # @return [Hash]
        def self.types
          Type
        end

        # Builds a packet from a given body.  Keeps track of
        # the packet number, incrementing it if the third argument is
        # true.
        #
        # @param type [Symbol] the type of packet it is.  See {Type}.
        # @param body [String] the body of the packet.
        # @param others [Hash] the data to pass to the struct.  See
        #   the packet struct definition to see what keys are allowed.
        # @param increment_id [Boolean] whether or not to increment
        #   packet id.  Defaults to true.
        # @return [Packet] the packet data.
        def self.build(type, body, others = {})
          packet_data = {
            :packet_type => Packet.types[type],
            :body        => body,
            :size        => body.bytesize
          }.merge(others)

          # Packet.struct[:packet].pack(packet_data)
          Packet.new(:packet, packet_data)
        end

        # Builds a response from a given body.  Doesn't increment the
        # packet id, as a response doesn't have a packet id.
        #
        # @param type [Symbol] the type of packet.  See {Type}.
        # @param body [String] the body of the packet.
        # @param packet_data [Hash<Symbol, Numeric>] the packet data
        #   that this is a response to.
        # @param others [Hash] the data to pass to the struct.  See
        #   the response struct definition to see what keys are
        #   allowed.
        # @option packet_data [Numeric] :packet_id the packet id this
        #   response is a response to.
        # @option packet_data [Numeric] :packet_type the packet type
        #   this response is a response to.
        # @return [Packet] the packet data.
        def self.build_response(type, body, packet_data = {}, others = {})
          response_data = {
            :packet_response_id   => packet_data[:packet_id] ||
              packet_data[:packet_response_id],
            :packet_response_type => packet_data[:packet_type],
            :packet_type          => Packet.types[type],
            :body                 => body,
            :size                 => body.bytesize
          }.merge(others)

          # Packet.struct[:response].pack(response_data)
          Packet.new(:response, response_data)
        end

        # Unpacks a struct from a socket.
        #
        # @param sock [#read, #seek] the socket to read from.
        # @raise [NoStructError] if it can't determine the struct
        #   type.
        # @return [Packet]
        def self.from_socket(sock)
          # we're gonna read one byte to see what type of packet it
          # is, a response or a regular packet.
          struct_type_num = sock.read(4)

          struct_type = Structs.key(
            struct_type_num.unpack("i<").first)

          unless struct_type
            raise NoStructError,
              "Undefined struct type #{struct_type_num.inspect}"
          end

          data = Packet.struct[struct_type].unpack_from_socket(sock)
          Packet.new(struct_type, data)
        end

        # The type of struct this packet is.  See {Structs}.
        #
        # @return [Symbol]
        attr_reader :struct

        # The data in this packet.
        #
        # @see []
        # @return [Hash]
        attr_reader :data

        # Initialize the packet.
        #
        # @param struct [Symbol] the type of struct.
        # @param data [Hash] the packet data.
        def initialize(struct, data)
          @struct = struct
          @data = data
        end

        # Turn this packet into a string.
        #
        # @return [String]
        def to_s
          @_cache ||= [Structs[@struct]].pack("i<") +
            Packet.struct[@struct].pack(@data)
        end

        alias_method :to_str, :to_s

        # Pretty inspect.
        #
        # @return [String]
        def inspect
          "#<#{self.class.name}:#{@struct}:#{@data.hash}>"
        end

        # Forwards to the data key :packet_id, or if that doesn't
        # exist, +:packet_response_id+.
        #
        # @return [Numeric]
        def id
          @data[:packet_id] || @data[:packet_response_id]
        end

        # The type of packet this is.  Checks {Packet.types} before
        # returning just the number.
        #
        # @return [Symbol, Numeric]
        def type
          Packet.types.key(@data[:packet_type]) || @data[:packet_type]
        end

        # Sets the body and the size for this packet.
        #
        # @param body [String] the new body.
        # @return [void]
        def body=(body)
          data[:body] = body
          data[:size] = body.bytesize
        end

        # Checks this packet for the expected type.
        #
        # @raise [UnacceptablePacketError] if the type doesn't match.
        def expect(type)
          if self.type != type
            raise UnacceptablePacketError,
              "Expected packet to be of type #{type}, " +
              "got #{self.type} instead"
          end
        end

        # Forwards requests on this packet of unkown methds to the
        # data hash.
        #
        # @return [Object]
        def method_missing(method, *args, &block)
          if @data.respond_to?(method)
            @data.public_send(method, *args, &block)
          elsif @data.key?(method)
            @data[method]
          elsif @data.key?(key = :"packet_#{method}")
            @data[key]
          else
            super
          end
        end

        # Defined so ruby knows we're doing #method_missing magic.
        #
        # @param method [Symbol] the method to check for.
        # @param include_all [Boolean] whether or not to include
        #   private and protected methods.
        # @return [Boolean]
        def respond_to_missing?(method, include_all = false)
          @data.respond_to?(method, include_all) || @data.key?(method)
        end

        # Raised when a string is unpacked but it doesn't match any
        # struct defined here.
        class NoStructError < ProtocolError; end

        # Raised when a packet is sent when another packet was
        # expected.
        class UnacceptablePacketError < ProtocolError; end

      end
    end
  end
end
