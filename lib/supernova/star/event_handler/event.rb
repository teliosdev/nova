module Supernova
  class Star
    module EventHandler

      # This represents an event that can be run.  It may also represent
      # an event that will be run, and is being used to match the events
      # in the set.
      # Basically, an event is defined when +:on+ is called on a Star,
      # and an [Event] is created.
      # It is added to an event list, which is a set.  Later, when that
      # class is instantized, and an event is ran, an [Event] is created
      # and the set is searched for a match to that [Event].
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

        # The type of [Event] this is.  By default, this value is
        # +:definition+, but when using this event to find another event,
        # its value should be +:search+.
        attr_accessor :type

        # Initialize the event.
        #
        # @param name [Symbol] the name of the event to respond to.
        # @param options [Hash] the options of the event.
        # @param block [Proc] the defining block of the event.
        def initialize(name, options, block = nil)
          @name = name
          @options = options
          @block = block
          @type = :definition
        end

        # Compares this event to another event.  If the argument isn't
        # an [Event], it is compared to the name of the event.  If it
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
        # @return [Boolean]
        def match?(event)
          event.name == name &&
          check_platform_requirement && check_options_requirements(event.options)
        end

        private

        # Checks the +:for+ option to see if it matches the current
        # platform.  If it's +nil+, or a false value, this returns true.
        # If it's anything else, it'll try to compare it to the
        # current platform, as returned by {Supernova#platform}.
        #
        # @return [Boolean]
        def check_platform_requirement
          if options[:for]
            Star.platform.include? options[:for]
          else
            true
          end
        end

        # Checks the given runtime options for required options.  If no
        # required options exist, returns true.  Otherwise, checks the
        # keys of the runtime options to see if they contain all of the
        # required options.
        #
        # @return [Boolean]
        def check_options_requirements(runtime_options)
          return true unless options[:requires] || options[:require]
          required_options = options[:requires] || options[:require]

          (required_options - runtime_options.keys).size == 0
        end


      end
    end
  end
end
