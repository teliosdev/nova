module Supernova
  module Remote
    module Common
      module Metadata

        # The data from the definition of the metadata in the star.
        # This is what the block is run in an instance of.
        class Data

          # The data contained in this class.
          #
          # @return [Hash<Symbol, Object>]
          attr_reader :data

          # Initialize the data class.
          def initialize
            @data = {
              :rubys => [],
              :platforms => [],
              :stars => [],
              :required_options => [],
              :version => Gem::Version.new("0.0.0") }
          end

          alias_method :require_star, :requires_star

          # @!method requires_platform(name, *versions)
          #   The platform version requirement.  Each call to this
          #   method adds a platform that can be used, and the
          #   versions that are required for that platform. +:all+
          #   represents all platforms.
          #
          #   @see Gem::Requirement
          #   @param name [Symbol] the name of the platform.
          #   @param versions [String] the versions of that platform
          #     this star is compatible with.
          #   @return [void]
          # @!method requires_ruby(name, *versions)
          #   The ruby version requirement.  Each call to this method
          #   adds a platform that can be used, and the versions that
          #   are required for that platform.  +:all+ represents all
          #   platforms.
          #
          #   @see Gem::Requirement
          #   @param name [Symbol] the name of the platform, such as
          #     +:jruby+ or +:mri+.
          #   @param versions [String] the versions of that platform
          #     that this star is compatible with.
          # @!method requires_star(name, *versions)
          #   Requires stars.  Uses the given name as the star name.
          #
          #   @see Gem::Requirement
          #   @param name [Symbol] the name of the star.
          #   @param versions [String] the versions of that star that
          #     are compatible with this star.
          #
          # @!parse alias_method :require_ruby, :requires_ruby
          # @!parse alias_method :requires_rubys, :requires_ruby
          # @!parse alias_method :require_rubys, :requires_ruby
          # @!parse alias_method :require_platform, :requires_platform
          # @!parse alias_method :requires_platforms, :requires_platform
          # @!parse alias_method :require_platforms, :requires_platform
          # @!parse alias_method :require_star, :requires_star
          # @!parse alias_method :requires_stars, :requires_star
          # @!parse alias_method :require_stars, :requires_star
          [:ruby, :platform, :star].each do |type|
            define_method(:"requires_#{type}") do |p, *versions|
              data[:"#{type}s"].push(:name => p, :version =>
                Gem::Requirement.new(*[versions].flatten))
            end

            alias_method :"require_#{type}", :"requires_#{type}"
            alias_method :"requires_#{type}s", :"requires_#{type}"
            alias_method :"require_#{type}s", :"requires_#{type}"
          end

          # The options that are required by this star.
          #
          # @param options [Symbol] the option that is required.
          # @return [void]
          def requires_option(*options)
            data[:required_options].push(*[options].flatten)
          end

          alias_method :requires_options, :requires_option
          alias_method :require_option, :requires_option
          alias_method :require_options, :requires_options

          # Sets the version of the current star.
          #
          # @see Gem::Version
          # @param version [String] the version of the star.
          # @return [void]
          def version=(version)
            data[:version] = Gem::Version.new(version)
          end

          # Validates the current platform, to make sure that the
          # running ruby version and the platform name and version
          # match those required by this star.
          #
          # @return [void]
          def validate!(remote)
            check_against :ruby do |ruby|
              if [:all, :any].include? ruby[:name]
                ruby[:version].satisfied_by?(
                  Gem::Version.new(RUBY_VERSION))
              else
                ruby[:name] == RUBY_ENGINE.downcase.intern &&
                  ruby[:version] == ruby_version
              end
            end

            version = Gem::Version.new remote.platform_version || "0.0.0"

            check_against :platform do |platform|
              remote.platforms.include?(platform[:name]) &&
                platform[:version] == version
            end
          end

          # Validates the given options, making sure that the options
          # contain the required options for the star.
          #
          # @return [void]
          def validate_options!(options)
            keys = options.keys

            unless (data[:required_options] - keys).empty?
              raise InvalidOptionsError, "Missing options " +
                "#{(data[:required_options] - keys).join(', ')}"
            end
          end

          private

          # Checks the given type against the block.  Injects the
          # type's array with false, and calls the block, trying to
          # see if any element in the type's array makes the block
          # return true.  If none of them do, it raises an error,
          # unless there's no element in the type's array.
          #
          # @param what [Symbol] the type.  Normally +:ruby+ or
          #   +:platform+.
          # @yield [Hash] the object to check.
          # @raise [NoPlatformError] if none of the yields give true.
          # @return [void]
          def check_against(what, &block)
            result = data[:"#{what}s"].inject(false) do |v, obj|
              v || block.call(obj)
            end

            unless result || data[:"#{what}s"].empty?
              raise NoPlatformError, "Could not match any version " +
              "of #{what}s."
            end
          end

          # Returns the most relevant ruby version there is.
          #
          # @return [Gem::Version]
          def ruby_version
            Gem::Version.new case RUBY_ENGINE
            when "jruby"
              JRUBY_VERSION
            else
              RUBY_VERSION
            end
          end

        end
      end
    end
  end
end
