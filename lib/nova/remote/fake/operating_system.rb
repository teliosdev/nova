module Nova
  module Remote
    class Fake

      # Handles operating system tasks like installing packages or
      # creating users.
      #
      # @abstract
      class OperatingSystem

        # Creates a user with the given name and options.
        #
        # @abstract
        # @note Does nothing.  As such, it always returns false.
        # @param name [String, Symbol] the name of the user.
        # @param options [Hash<Symbol, Object>] the options for the
        #   user.
        # @option options [Boolean] :system whether or not the user is
        #   a system user.  Defaults to +false+.
        # @option options [Boolean] :nologin whether or not the user
        #   is able to log in.  Defaults to +false+.
        # @option options [String] :password the user's password.
        #   Defaults to +nil+.
        # @return [Boolean] whether or not the user creation was
        #   successful.
        def create_user(name, options = {})
          false
        end

        # Installs packages for the corresponding operating system.
        #
        # @abstract
        # @note Does nothing.  As such, it always returns false.
        # @param packages [Hash<Symbol, Array<String>>] the symbol is
        #   the name of the OS, the array is the packages to install
        #   for that OS.
        # @option packages [Array<String>] :ubuntu the packages to
        #   install for debian-based OSs (Ubuntu, Debian, Mint).
        # @option packages [Array<String>] :red_hat the packages to
        #   install for red hat-based OSs (REHL, Fedora, CentOS).
        # @option packages [Array<String>] :arch the packages to
        #   install for arch.
        # @return [Boolean] whether or not the package installation
        #   was successful.
        def install_packages(packages)
          false
        end

      end
    end
  end
end
