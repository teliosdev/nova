module Nova
  module Starbound
    class Protocol

      # The encryption used in the protocol.
      module Encryption

        # The provider used to encrypt the body.
        #
        # @return [Encryptor]
        attr_writer :encryption_provider

        # Initialize the encryption.
        def initialize
          @encryption_provider = Encryptors::Plaintext.new

          super()
        end

        # Gets the encryption provider.
        #
        # @raise [NoEncryptionError] if {#state} isn't handshake,
        #   the encryption provider returns true on
        #   {Encryptor.plaintext?}, and +:allow_plaintext+ is false.
        # @return [Encryptor]
        def encryption_provider
          raise NoEncryptionError if
            @encryption_provider.class.plaintext? &&
            !should_allow_plaintext?

          @encryption_provider
        end

        private

        # Whether or not plaintext is acceptable.  Checks the state to
        # see if it's +:handshake+ and the +:allow_plaintext+ option
        # to return true or false.
        #
        # @return [Boolean]
        def should_allow_plaintext?
          state == :handshake || options.fetch(:allow_plaintext, false)
        end

      end
    end
  end
end
