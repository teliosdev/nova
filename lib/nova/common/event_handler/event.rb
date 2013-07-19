module Nova
  module Common
    module EventHandler

      # This represents an event that can be run.  It may also represent
      # an event that will be run, and is being used to match the events
      # in the set.
      # Basically, an event is defined when +:on+ is called on a Star,
      # and an {Event} is created.
      # It is added to an event list, which is a set.  Later, when that
      # class is instantized, and an event is ran, an {Event} is created
      # and the set is searched for a match to that {Event}.
      class Event

        include Comparable

        # The name of the event.
        #
        # @return [Symbol]
        attr_reader :name

        # The options defined at compile time for the event.
        #
        # @return [Hash]
        attr_reader :options

        # The block defined for the event.  Should be able to accept one
        # parameter, or less.
        #
        # @return [Proc]
        attr_reader :block

        # The type of {Event} this is.  By default, this value is
        # +:definition+, but when using this event to find another event,
        # its value should be +:search+.
        #
        # @return [Symbol]
        attr_accessor :type

        # Initialize the event.
        #
        # @param name [Symbol] the name of the event to respond to.
        # @param options [Hash] the options of the event.
        # @param block [Proc] the defining block of the event.
        # @option options [Symbol] :on the platform the event
        #   is written for.  If this doesn't match the current
        #   platform, the event is never run.  Must be in the
        #   results of {Remote::Fake::Platforms#platform} (or
        #   remote's definition of platform).  Can also be +:for+.
        # @option options [Symbol, Array<Symbol>] :requires
        #   what options the event requires when being run.  The
        #   value will be matched against the keys of the hash
        #   passed, and if the hash doesn't contain all of the
        #   values, the event doesn't match.  Can also be
        #   +:require+.
        # @option options [Hash] :defaults the default values to be
        #   used when running the event.  Merged into the given
        #   options such that the given options overwrite the
        #   defaults.
        def initialize(name, options, block = nil)
          @name = name
          @options = options
          @block = block
          @type = :definition
        end

        # Compares this event to another event.  If the argument isn't
        # an {Event}, it is compared to the name of the event.  If it
        # is, the event's names and options are compared.
        #
        # @param other [Event, Object] the event to compare to.
        # @return [Numeric] the comparison result.
        def <=>(other)
          return @name == other unless Event === other

          (@name <=> other.name) + (@options <=> other.options)
        end

        # Runs the event, calling the block with the given options.
        #
        # @param context [Object] the context to run it in.
        # @param options [Hash] the options.
        # @return [Object, nil]
        def run(context, options = {})
          #@block.call(options)

          if @options[:defaults]
            options = @options[:defaults].merge(options)
          end

          context.instance_exec(options, &@block)
        end

        # Whether or not this event is a search event.
        #
        # @return [Boolean]
        def search?
          type == :search
        end

        # Whether or not this event matches another event, to see if it
        # can be ran using this event definition.
        #
        # @param star [Class, #platform]
        # @param event [Symbol]
        # @return [Boolean]
        def match?(star, event)
          event.name == name &&
          check_platform_requirement(star) && check_options_requirements(event.options)
        end

        private

        # Checks the +:for+ option to see if it matches the current
        # platform.  If it's +nil+, or a false value, this returns true.
        # If it's anything else, it'll try to compare it to the
        # current platform, as returned by {Platforms#platform}.
        #
        # @api private
        # @return [Boolean]
        def check_platform_requirement(star)
          if options[:for] || options[:on]
            star.platform.include?(options[:for] || options[:on])
          else
            true
          end
        end

        # Checks the given runtime options for required options.  If no
        # required options exist, returns true.  Otherwise, checks the
        # keys of the runtime options to see if they contain all of the
        # required options.
        #
        # @api private
        # @return [Boolean]
        def check_options_requirements(runtime_options)
          required_options = options[:requires] || options[:require]
          return true unless required_options

          ([required_options].flatten - runtime_options.keys).size == 0
        end


      end
    end
  end
end
