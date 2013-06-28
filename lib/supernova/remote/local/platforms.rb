require 'forwardable'

require 'os'

module Supernova
  module Remote
    module Local

      # Methods that handle displaying what platform the star is running
      # on.
      module Platforms

        extend Forwardable

        # Returns an array containing information about the platform the
        # Star is being run on.  Possible values include:
        #  :windows, :windows32, :windows64, :linux, :linux32, :linux64,
        #  :osx, :osx32, :osx64, :posix, :posix32, :posix64, :ubuntu,
        #  :arch, :red_hat
        #
        # @return [Array<Symbol>]
        def platform
          @_platform ||= begin
            os = []
            os << :windows if OS.windows?
            os << :linux   if OS.linux?
            os << :osx     if OS.osx?
            os << :posix   if OS.posix?
            unless OS.windows? || OS.osx?
              os << :ubuntu  if command_exists?("apt-get")
              os << :arch    if command_exists?("pacman")
              os << :red_hat if command_exists?("yum")
            end

            [
              *os,
              *os.map { |x| (x.to_s + OS.bits.to_s).to_sym }
            ]
          end
        end

        # @!method posix?
        #  True for linux? or osx?
        #  @api public
        #  @see OS#posix?
        #  @return [Boolean]
        # @!method linux?
        #  True if the OS is based on the linux kernel, false for
        #  windows, OSX, or cygwin.
        #  @api public
        #  @see OS#linux?
        #  @return [Boolean]
        # @!method osx?
        #  True if the OS is OSX, false for linux, windows, or cygwin.
        #  @see OS#osx?
        #  @api public
        #  @return [Boolean]
        # @!method windows?
        #  True if the OS is Windows or jruby?, false for linux or
        #  windows.
        #  @api public
        #  @see OS#windows?
        #  @return [Boolean]
        # @!method jruby?
        #  True if the ruby is based on the JRuby implementation.
        #  @api public
        #  @see OS#jruby?
        #  @return [Boolean]
        # @!method iron_ruby?
        #  True if the ruby is based on the Iron Ruby implementation.
        #  @api public
        #  @see OS#iron_ruby?
        #  @return [Boolean]
        # @!method cygwin?
        #  True if ruby is running with cygwin.
        #  @api public
        #  @see OS#cygwin?
        #  @return [Boolean]
        # @!method bits
        #  The number of bits the processor can handle.
        #  @api public
        #  @see OS#bits
        #  @return [Numeric]
        # @!method dev_null
        #  Where /dev/null is located on the computer (/dev/null for
        #  anything but Windows, NUL for Windows).
        #  @api public
        #  @see OS#dev_null
        #  @return [String]
        def_delegators :OS, :posix?, :linux?, :osx?, :windows?,
          :jruby?, :iron_ruby?, :cygwin?, :bits, :dev_null

        # Called when {Platforms} is included.  Extends what included
        # it by self.
        #
        # @param receiver [Object]
        # @return [void]
        # @api private
        def self.included(receiver)
          receiver.extend self
        end
      end
    end
  end
end
