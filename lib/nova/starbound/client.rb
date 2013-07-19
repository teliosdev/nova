require 'socket'

module Nova
  module Starbound

    # A client for Nova.
    class Client

      # The options that were passed to the client on initialization.
      #
      # @return [Hash]
      attr_reader :options

      # The underlying protocol that powers this client.
      #
      # @return [Protocol]
      attr_reader :protocol

      # The default options when dealing with this class.
      DEFAULT_OPTIONS = {
        :type => :tcp,
        :host => "127.0.0.1",
        :port => 2010
      }

      # Initialize with the given options.
      #
      # @param options [Hash]
      def initialize(options = {})
        @options = DEFAULT_OPTIONS.merge(options)
        @protocol_options = (@options.delete(:protocol) || {}).dup
        @protocol = Protocol.new @protocol_options.merge(:type => :client)
      end

      # Do the handshake with the server.
      #
      # @return [void]
      def handshake
        @protocol.socket = socket
        @protocol.handshake
      end

      # Create the socket.
      #
      # @return [Object]
      def socket
        @_socket ||= case options[:type]
        when :tcp
          TCPSocket.new(options[:host], options[:port])
        when :unix
          UNIXSocket.new(options[:path])
        when :pipe
          options[:pipe]
        end
      end

    end
  end
end
