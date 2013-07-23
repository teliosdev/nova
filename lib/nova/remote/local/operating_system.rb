module Nova
  module Remote
    class Local

      # Handles operating system tasks like installing packages or
      # creating users.
      #
      # @abstract
      class OperatingSystem < Part

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
        #   Defaults to +nil+, which gives it no password.  On
        #   windows, this can be a security issue as anyone can log in
        #   to an account with no password.
        # @return [Boolean] whether or not the user creation was
        #   successful.
        def create_user(name, options = {})
          if remote.platform.windows?
            windows_create_user(name, options)
          else
            linux_create_user(name, options)
          end
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
          out = true
          packages.each do |platform, to_install|
            if remote.platform.types.include?(platform)
              out = out && install_command(platform).run(
                packages: to_install.join(' ')).nonzero_exit?
            end
          end

          out
        end

        private

        # Create a user using the windows command line.  Unable to
        # handle the +:system+ option from {#create_user}.
        #
        # @param name [String] the name of the user.
        # @param options [Hash] see {#create_user}
        # @return [Message] from running the command.
        def windows_create_user(name, options)
          line = remote.command.line("net", "user {username} {password} /add /Y {options}")

          line.run(
            username: name,
            password: options[:password].to_s,
            options: (if options[:nologin] then "/times: " else "" end)
          )
        end

        # Create a user using the linux terminal.  If +:nologin+ is
        # specified, the user has a shell of +/bin/false+.
        #
        # @todo more options, like home path.
        # @param name [String] the name of the user.
        # @param options [Hash] see {#create_user}
        # @return [Message] from running the command.
        def linux_create_user(name, options)
          line = remote.command.line("useradd", "{username} --password {password} {options}")

          opts = ""
          opts << "--system " if options[:system]
          opts << "--shell /bin/false" if options[:nologin]

          line.run(
            username: name,
            password: options[:password],
            options: opts
          )
        end

        # Returns the relevant install command for the given platform.
        # Returns a Command::Runner, which takes 1 argument parameter:
        # +:packages+, which is a list of space-seperated package
        # names to install.
        # 
        # @param platform [Symbol] the platform this is on.
        # @return [Command::Runner]
        def install_command(platform)
          case platform
          when :ubuntu
            remote.command.line("apt-get", "install {packages}")
          when :red_hat
            remote.command.line("yum", "install {packages}")
          when :arch
            remote.command.line("pacman", "-S {packages}")
          else
            remote.command.line("false", "") # so we return a non-zero exit code
          end
        end

      end
    end
  end
end
