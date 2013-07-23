require 'os'

module Nova
  module Remote
    class Local

      # The platform information.
      #
      # @abstract
      class Platform < Part

        # The list of platforms that this platform matches.
        #
        # @return [Array<Symbol>] the platform list.
        def types
          @_types ||= begin
            out = []
            out << :posix if posix?
            out << :linux if linux?
            out << :windows if windows?
            out << :osx if osx?

            if linux?
              out << :ubuntu  if remote.command.exists?("apt-get")
              out << :red_hat if remote.command.exists?("yum")
              out << :arch    if remote.command.exists?("pacman")
            end

            [out, out.map { |x| x.to_s.gsub(/\z/, bits).intern }].flatten
          end
        end

        # Tries to determine the platform version, but if it can't, it
        # defaults to nil.
        #
        # @return [nil, String]
        def version
          nil
        end

        # True for linux? or osx?
        # @api public
        # @see OS#posix?
        # @return [Boolean]
        def posix?
          OS.posix?
        end

        # True if the OS is based on the linux kernel, false for
        # windows, OSX, or cygwin.
        # @api public
        # @see OS#linux?
        # @return [Boolean]
        def linux?
          OS.linux?
        end

        # True if the OS is OSX, false for linux, windows, or cygwin.
        # @see OS#osx?
        # @api public
        # @return [Boolean]
        def osx?
          OS.osx?
        end

        # True if the OS is Windows or jruby?, false for linux or
        # windows.
        # @api public
        # @see OS#windows?
        # @return [Boolean]
        def windows?
          OS.windows?
        end

        # True if the ruby is based on the JRuby implementation.
        # @api public
        # @see OS#jruby?
        # @return [Boolean]
        def jruby?
          OS.jruby?
        end

        # True if the ruby is based on the Iron Ruby implementation.
        # @api public
        # @see OS#iron_ruby?
        # @return [Boolean]
        def iron_ruby?
          OS.iron_ruby?
        end

        # True if ruby is running with cygwin.
        # @api public
        # @see OS#cygwin?
        # @return [Boolean]
        def cygwin?
          OS.cygwin?
        end

        # The number of bits the processor can handle.
        # @api public
        # @see OS#bits
        # @return [Numeric]
        def bits
          OS.bits
        end

        # Where /dev/null is located on the computer (/dev/null for
        # anything but Windows, NUL for Windows).
        # @api public
        # @see OS#dev_null
        # @return [String]
        def dev_null
          OS.dev_null
        end

      end
    end
  end
end
