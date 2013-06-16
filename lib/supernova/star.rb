require 'supernova/star/event_handler'
require 'supernova/star/options_manager'
require 'supernova/star/star_management'
require 'supernova/star/platforms'

module Supernova

  # This binds together all of our default includes.
  class Star

    include EventHandler
    include OptionsManager
    include StarManagement
    include Platforms

  end
end
