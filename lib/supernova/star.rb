require 'supernova/remote/common'
require 'supernova/remote/fake'

module Supernova

  # This binds together all of our default includes.
  class Star

    include Remote::Common::EventHandler
    include Remote::Common::OptionsManager
    include Remote::Common::StarManagement
    include Remote::Common::Features

    star_type :star

    # @!parse include Remote::Common::EventHandler::InstanceMethods
    # @!parse extend Remote::Common::EventHandler::ClassMethods
    # @!parse include Remote::Common::OptionsManager::InstanceMethods
    # @!parse extend Remote::Common::OptionsManager::ClassMethods
    # @!parse include Remote::Common::StarManagement::InstanceMethods
    # @!parse extend Remote::Common::StarManagement::ClassMethods
    # @!parse include Remote::Common::Features::InstanceMethods
    # @!parse extend Remote::Common::Features::ClassMethods
  end
end
