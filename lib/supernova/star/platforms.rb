require 'forwardable'

module Supernova
  class Star
    module Platforms

      extend Forwardable

      def platform
        @_platform ||= begin
          os = []
          os << :windows if OS.windows?
          os << :linux if OS.linux?
          os << :osx if OS.osx?
          os << :posix if OS.posix?

          [
            *os,
            *os.map { |x| (x.to_s + OS.bits.to_sym).to_i }
          ]
        end
      end

      def_delegators :OS, :unix?, :linux?, :osx?, :windows?,
        :jruby?, :iron_ruby?, :cygwin?, :bits, :dev_null

      def self.included(receiver)
        receiver.extend self
      end
    end
  end
end
