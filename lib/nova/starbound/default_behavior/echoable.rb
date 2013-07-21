module Nova
  module Starbound
    class DefaultBehavior
      module Echoable
        
        # Called when this module is included into another module.
        # Sets up the echo packet management.
        #
        # @param reciever [Module]
        # @return [void]
        def self.included(reciever)
          reciever.handle :packet => :echo
        end

        private

        # Handles the echo packet by responding to it with the same
        # body that was sent.
        #
        # @return [void]
        def handle_packet_echo(packet, protocol)
          protocol.respond_to packet, :echo, packet.body
        end

      end
    end
  end
end