require 'supernova/starbound/protocol/encryption'
require 'supernova/starbound/protocol/messages'
require 'supernova/starbound/protocol/packet'
require 'supernova/starbound/protocol/socket'

module Supernova
  module Starbound

    # The basic Starbound protocol.
    #
    # @todo More testing.
    class Protocol

      include Protocol::Socket
      include Protocol::Encryption
      include Protocol::Messages

      # The options that was passed to this protocol on
      # initialization.
      #
      # @return [Hash<Symbol, Object>]
      attr_reader :options

      # The current state of the protocol.  Known values:
      # +:offline+ (default), +:handshake+, +:online+, +:closing+.
      #
      # @return [Symbol]
      attr_reader :state

      # Perform a handshake with the server.  First sets the state to
      # +:handshake+.
      #
      # @return [void]
      def handshake
        @state = :handshake
        thread

        if options[:type] == :client
          message  = send :protocol_version, Supernova::VERSION
          response = response_to message
          check_versions response
          handle_encryption
        else

          wait_for_protocol_version
          handle_server_encryption
        end

        @state = :online
      end

      # Initialize the protocol.
      #
      # @param options [Hash] the options to initialize the protocol
      #   with.
      def initialize(options = {})
        @options = options
        @state   = :offline

        super()
      end

      # Closes the connection.
      #
      # @return [void]
      def close(code = :none)
        @state = :closing
        send :close, Packet::CloseReasons[code]

        super()
      end

    end
  end
end
