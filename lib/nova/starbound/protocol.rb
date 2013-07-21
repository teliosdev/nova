require 'nova/starbound/protocol/exceptions'
require 'nova/starbound/protocol/encryption'
require 'nova/starbound/protocol/messages'
require 'nova/starbound/protocol/packet'
require 'nova/starbound/protocol/socket'
require 'nova/starbound/default_behavior'

module Nova
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
          message  = send :protocol_version, Nova::VERSION
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

        if code
          send :close, Packet::CloseReasons[code].to_s
        end

        super()

        @state = :offline
      end

      # Sets up default behaviors within this protocol.
      #
      # @return [DefaultBehavior]
      def default_behavior
        @_default_behavior ||= DefaultBehavior.new(self)
      end

    end
  end
end
