module Nova
  module Starbound
    module Encryptors

      # The plaintext encryptor.
      class Plaintext < Encryptor

        encryptor_name "plaintext"
        register! 0

        # The random provider for this clas.
        RANDOM = Random.new

        # Whether or not this encryptor is available.  Since it's
        # plaintext, it's always available.
        #
        # @return [true]
        def self.available?
          true
        end

        # Whether or not this encryptor is plaintext.  It is.  This
        # will always return true for this class.
        #
        # @return [true]
        def self.plaintext?
          true
        end

        # (see Encryptor#encrypt)
        def encrypt(packet)
          packet = packet.clone

          packet[:nonce] = RANDOM.bytes(24)
          packet
        end

        # (see Encryptor#decrypt)
        def decrypt(packet)
          packet = packet.clone

          packet
        end

        # Does nothing.
        #
        # @return [nil]
        def private_key!; end

        # Does nothing.
        #
        # @return [String] an empty string.
        def public_key; ""; end

        # Does nothing.
        #
        # @param _ [String] the other "public" key.
        # @return [nil]
        def other_public_key=(_); end

      end
    end
  end
end
