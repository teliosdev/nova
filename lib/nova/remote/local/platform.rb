module Nova
  module Remote
    class Local

      # The platform information.
      #
      # @abstract
      class Platform

        # The list of platforms that this platform matches.
        #
        # @abstract
        # @note Since this is a Fake remote, it defaults to none.
        # @return [Array<Symbol>] the platform list.
        def types
          []
        end

        # Tries to determine the platform version, but if it can't, it
        # defaults to nil.
        #
        # @abstract
        # @note Since this is a Fake remote, it defaults to nil.
        # @return [nil, String]
        def version
          nil
        end

        # True for linux? or osx?
        # @api public
        # @see OS#posix?
        # @return [Boolean]
        def posix?; false; end

        # True if the OS is based on the linux kernel, false for
        # windows, OSX, or cygwin.
        # @api public
        # @see OS#linux?
        # @return [Boolean]
        def linux?; false; end

        # True if the OS is OSX, false for linux, windows, or cygwin.
        # @see OS#osx?
        # @api public
        # @return [Boolean]
        def osx?; false; end

        # True if the OS is Windows or jruby?, false for linux or
        # windows.
        # @api public
        # @see OS#windows?
        # @return [Boolean]
        def windows?; false; end

        # True if the ruby is based on the JRuby implementation.
        # @api public
        # @see OS#jruby?
        # @return [Boolean]
        def jruby?; false; end

        # True if the ruby is based on the Iron Ruby implementation.
        # @api public
        # @see OS#iron_ruby?
        # @return [Boolean]
        def iron_ruby?; false; end

        # True if ruby is running with cygwin.
        # @api public
        # @see OS#cygwin?
        # @return [Boolean]
        def cygwin?; false; end

        # The number of bits the processor can handle.
        # @api public
        # @see OS#bits
        # @return [Numeric]
        def bits; 32; end

        # Where /dev/null is located on the computer (/dev/null for
        # anything but Windows, NUL for Windows).
        # @api public
        # @see OS#dev_null
        # @return [String]
        def dev_null; "/dev/null"; end

      end
    end
  end
end
