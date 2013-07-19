module Nova
  module Starbound

    # An encryptor is used to encrypt the data in the exchange for the
    # starbound protocol.
    #
    # @abstract
    class Encryptor

      # @overload encryptor_name(name)
      #   Sets the encryptor's name.  Used for negotiation of
      #   encryption protocols.
      #
      #   @param name [String] the name of the encryptor.
      #   @return [void]
      # @overload encryptor_name
      #   Gets the encryptor's name.
      #
      #   @return [String]
      def self.encryptor_name(name = nil)
        if name
          @encryptor_name = name
        else
          @encryptor_name
        end
      end

      # Registers a subclass with the Encryptor class for use with the
      # protocol.
      #
      # @param preference [Numeric] a number that is used to sort the
      #   encryptors by preference.
      # @return [void]
      def self.register!(preference)
        @preference = preference
        Encryptor.encryptors.push(self)
      end

      class << self

        # The preference for this encryptor.  Used to sort the
        # encryptors.
        #
        # @return [Numeric]
        attr_reader :preference
      end

      # The encryptors that are defined.
      #
      # @return [Array<Encryptor>]
      def self.encryptors
        @encryptors ||= []
      end

      # The encryptors, sorted by preference.
      #
      # @return [Array<Encryptor>]
      def self.sorted_encryptors
        encryptors.sort do |a, b|
          b.preference <=> a.preference
        end
      end

      # Whether or not this encryptor is available.  Defaults to
      # false.
      #
      # @return [Boolean]
      def self.available?
        false
      end

      # Returns whether or not this is a plaintext encryptor, or one
      # equivalent.  Defaults to false, so most encryptors shouldn't
      # have to overwrite this.
      #
      # @return [Boolean]
      def self.plaintext?
        false
      end

      # The options.  These are mostly use internally.
      #
      # @return [Hash<Symbol, Object>]
      attr_reader :options

      # Initialize the encryptor.
      #
      # @raise [NotImplementedError] if {.available?} returns false.
      def initialize
        @options = {}

        unless self.class.available?
          raise NotImplementedError,
            "#{self.class.encryptor_name} is not avialable!"
        end
      end

      # @!method encrypt(packet)
      #   Encrypts the given packet with the encryptor.
      #
      #   @param packet [Packet] the packet to encrypt.
      #   @return [Packet] the encrypted packet.
      # @!method decrypt(packet)
      #   Decrypts the given packet with the encryptor.
      #
      #   @param packet [Packet] the packet to decrypt.
      #   @return [Packet] the decrypted packet.
      # @!method private_key!
      #   Generates the private key for this encryptor.
      #
      #   @return [void]
      # @!method public_key
      #   Returns the public key to be sent to the other remote.
      #
      #   @return [String]
      # @!method other_public_key=(pub_key)
      #   Sets the public key of the other remote.
      #
      #   @param pub_key [String] the public key of the remote.
      #   @return [void]
      [:encrypt, :decrypt, :private_key!, :public_key,
        :other_public_key=].each do |m|

        define_method(m) do |*args|
          raise NotImplementedError,
            "tried to call #{m} on #{self.class.encryptor_name}"
        end
      end

    end
  end
end

require 'nova/starbound/encryptors'
