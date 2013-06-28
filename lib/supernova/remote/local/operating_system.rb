module Supernova
  module Remote
    module Local

      # Manage operating system tasks like instlaling packages.
      module OperatingSystem

        # Creates a user with the given name and options.
        #
        # @todo Implement.
        # @see Fake::OperatingSystem#create_user
        # @param (see Fake::OperatingSystem#create_user)
        # @option (see Fake::OperatingSystem#create_user)
        # @return (see Fake::OperatingSystem#create_user)
        def create_user(name, options = {})

        end

        # Installs packages for the right operating system.
        #
        # @see Fake::OperatingSystem#install_packages
        # @param (see Fake::OperatingSystem#install_packages)
        # @option (see Fake::OperatingSystem#install_packages)
        # @return (see Fake::OperatingSystem#install_packages)
        def install_packages(packages)
          return if windows?

          needed_packages = []

          packages.each do |k, v|
            if platform.include?(k)
              needed_packages.push(*v)
            end
          end

          update_package_manager do
            line(package_manager[0], package_manager[1] + " " +
              needed_packages.each_with_index.map { |e, i| "{#{i}} " }).pass(Hash.new { |h, k|
                h[k] = needed_packages[k]
            })
          end
        end

        private

        # Determines the package manager to use for this platform.
        # Doesn't apply to windows.
        #
        # @return [Array<(String, String)>] the package manager
        #   command, and the option used to install, respectively.
        def package_manager
          case true
          when platform.include?(:ubuntu)
            ["apt-get", "install"]
          when platform.include?(:red_hat)
            ["yum", "install"]
          when platform.include?(:arch)
            ["pacman", "-S"]
          else
            ["", ""]
          end
        end

        # Runs a command for updating the package manager.
        #
        # @yield [Message] when the command finishes.
        # @return [void]
        def update_package_manager(&block)
          case true

          when platforms.include?(:ubuntu)
            line("apt-get", "update").pass(&block)
          when platforms.include?(:red_hat)
            line("yum", "update").pass(&block)
          when platforms.include?(:pacman)
            line("pacman", "-S").pass(&block)
          else
            block.call(nil)
          end
        end
      end
    end
  end
end
