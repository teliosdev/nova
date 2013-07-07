require 'supernova/common/event_handler'
require 'supernova/common/options_manager'
require 'supernova/common/star_management'
require 'supernova/common/features'

module Supernova

  # This defines the methods that are common to all remotes, as in,
  # platform independent, in the truest sense of the word.
  module Common

    # The possible platforms that can exist.
    POSSIBLE_PLATFORMS = [:posix, :linux, :osx, :windows, :ubuntu,
      :red_hat, :arch].freeze

  end
end
