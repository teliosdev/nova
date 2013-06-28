module Supernova
  module Remote
    module Fake

      # Manage operating system tasks like instlaling packages.
      #
      # @abstract Implement the methods in another remote to create
      #   a working operating system module.
      module OperatingSystem

        # Creates a user with the given name and options.
        #
        # @abstract
        # @note Does nothing.
        # @param name [String, Symbol] the name of the user.
        # @param options [Hash] the options for the user.
        # @option options [Boolean] :system whether or not the user is
        #   a system user.  Defaults to +false+.
        # @option options [Boolean] :nologin whether or not the user
        #   is able to log in.  Defaults to +false+.
        # @option options [String] :password the user's password.
        #   Defaults to nil.
        # @return [Boolean] whether or not the user creation was
        #   successful.
        def create_user(name, options = {})
          true
        end

        # Installs packages for the right operating system.
        #
        # @abstract
        # @note Does nothing.
        # @param packages [Hash{Symbol => Array<String>}] symbol is
        #   the name of the OS, the array is the packages to install
        #   for that OS.
        # @option packages [Array<String>] :ubuntu the packages to
        #   install for debian-based OSs (Ubuntu, Debian, Mint).
        # @option packages [Array<String>] :red_hat the packages to
        #   install for red hat-based OSs (RHEL, Fedora, CentOS).
        # @option packages [Array<String>] :arch the packages to
        #   install for Arch.
        # @return [Boolean] whether or not package installation was
        #   successful.
        def install_packages(packages)
          true
        end
      end
    end
  end
end
