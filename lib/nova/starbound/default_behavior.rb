require "nova/starbound/default_behavior/eventable"
require "nova/starbound/default_behavior/passwordable"
require "nova/starbound/default_behavior/star_runnable"
require "nova/starbound/default_behavior/echoable"
require "multi_json"

module Nova
  module Starbound
    class DefaultBehavior

      include Eventable
      include Passwordable
      include StarRunnable
      include Echoable

      # @!parse include Eventable::InstanceMethods
      # @!parse extend Eventable::ClassMethods

      # Initialize the class.
      def initialize(protocol)
        attach_events protocol
      end

    end
  end
end