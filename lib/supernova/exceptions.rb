module Supernova

  # Raised when an Event cannot be found.
  class NoEventError < StandardError; end

  # Raised when options were passed that were not valid.
  class InvalidOptionsError < StandardError; end

  # Raised when a Star is tried to be created from a non-existant
  # star type.
  class NoStarError < StandardError; end

  # Raised when a Star is tried to be instantized on a non-compliant
  # platform.
  class NoPlatformError < StandardError; end
end
