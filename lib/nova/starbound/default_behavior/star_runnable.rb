module Nova
  module Starbound
    class DefaultBehavior

      # Handles running stars.
      module StarRunnable
        
        # Runs the star with the given information.
        #
        # @param target [String] the target to originate the star to
        #   run from.
        # @param data [Hash] the data to pass to the event.
        # @return [Boolean] if it was successful.
        def run_star(target, data)
          return false unless authenticated?
          star = Star.from_target target

          return false unless star
          inst = star.new Remote::Local
          inst.options = data["options"]
          out = inst.run(target.split('.').last, data["arguments"])

          if out.is_a? NoEventError
            return false
          else
            return true
          end
        end

        private

        # Handles an incoming packet request for handling stars.
        #
        # @param packet [Packet] the packet to handle.
        # @param protocol [Protocol] the protocol.
        # @return [void]
        def handle_packet_star_run(packet, protocol)
          raw = MultiJson.load packet.body

          if raw["target"] && run_star(raw["target"], raw)
          else
            protocol.respond_to packet, :standard_error, "Unable to run #{raw["target"]}"
          end

        rescue MultiJson::LoadError => e
          protocol.respond_to packet, :standard_error, e.message
        end

        public

        # When this is included by {DefaultBehavior}, define the
        # packets nessicary for star running.
        #
        # @return [void]
        def self.included(reciever)
          reciever.handle :packet => :star_run
        end
      end
    end
  end
end