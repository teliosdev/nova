require 'nova/common'
require 'nova/remote/fake'

module Nova

  # This binds together all of our default includes.
  class Star

    include Common::EventHandler
    include Common::Metadata
    include Common::StarManagement
    include Common::Features

    star_type :star

    # @!parse include Common::EventHandler::InstanceMethods
    # @!parse extend Common::EventHandler::ClassMethods
    # @!parse include Common::Metadata::InstanceMethods
    # @!parse extend Common::Metadata::ClassMethods
    # @!parse include Common::StarManagement::InstanceMethods
    # @!parse extend Common::StarManagement::ClassMethods
    # @!parse include Common::Features::InstanceMethods
    # @!parse extend Common::Features::ClassMethods
  end
end
