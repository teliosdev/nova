module Supernova

  # Creates a star from a {Supernova.create} call.
  class Constructor

    # Initialize the constructor.
    def initialize(options, &block)
      @options = options
      @block = block
    end

    def create
      star_type = Star.types[@options.keys.first]

      raise NoStarError,
        "Could not find star type #{@options.keys.first}." unless star_type

      new_star = star_type.new
      new_star.name = @options[@options.keys.first]
      new_star.instance_exec &@block
      new_star
    end

  end
end
