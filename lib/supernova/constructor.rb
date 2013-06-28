module Supernova

  # Creates a star from a {Supernova.create} call.
  class Constructor

    # Initialize the constructor.
    #
    # @param options [Hash] the definition of the star.  It should
    #   be a single key-value pair, with the first key being the
    #   type of star, and the first value being the name of the
    #   star.
    # @yield for the construction of the new Star.
    # @example
    #   Constructor.new(some_star: :another_star) do
    #     on :some_event do; end
    #   end.create # => Supernova::Star/SomeStar.another_star
    def initialize(options, &block)
      @options = options
      @block = block
    end

    # Creates a star.  If it cannot find the correct star type, raises
    # {NoStarError}.  Returns the new star class.
    #
    # @raise [NoStarError] when the star type couldn't be found.
    # @return [Class] a subclass of the star type.
    def create

      star_type = Star.types[@options.keys.first]

      raise NoStarError,
        "Could not find star type #{@options.keys.first}." unless star_type

      new_star = Class.new(star_type)
      new_star.as   = @options.values.first
      new_star.type = @options.keys.first
      new_star.class_exec &@block
      new_star.required_platforms = [@options[:requires]].flatten.compact
      new_star
    end

  end
end
