# Requires at bottom.

module Supernova
  module Starbound
    class CryptoProvider

      def self.providers
        @@providers ||= {}
      end

      def self.register(name, id)
        @crypto_type = id
        providers[name] = self
      end

      def self.[](name)
        providers[name]
      end

      def self.available?
        true
      end

      def self.version
        ""
      end

      def self.crypto_type
        @crypto_type
      end

      def initialize
        @options = {}

        raise NotAvailableCryptoError unless self.class.available?
      end


      attr_accessor :options

      def encrypt(_); raise NotImplementedError; end

      def decrypt(_); raise NotImplementedError; end

      def private_key!; raise NotImplementedError; end

      def public_key; raise NotImplementedError; end

      def other_public_key=(_); raise NotImplementedError; end

    end

    class NotAvailableCryptoError < StandardError; end
  end
end

require 'supernova/starbound/crypto_providers/openssl'
require 'supernova/starbound/crypto_providers/plaintext'
require 'supernova/starbound/crypto_providers/rbnacl'
