require 'nova/common/event_handler'
require 'nova/common/star_management'
require 'nova/common/metadata'
require 'nova/common/features'

module Nova

  # This defines the methods that are common to all remotes, as in,
  # platform independent, in the truest sense of the word.
  module Common

    # The possible platforms that can exist.
    POSSIBLE_PLATFORMS = [:posix, :linux, :osx, :windows, :ubuntu,
      :red_hat, :arch].freeze

  end
end
