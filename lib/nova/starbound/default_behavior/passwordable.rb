module Nova
  module Starbound
    class DefaultBehavior

      # Handles passwords with the default behavior.
      module Passwordable
        
        # The current password.  If it's nil, any password works; if
        # it's an empty string, no password works; and if it's a
        # string, only passwords matching that string works.
        #
        # @return [nil, String]
        attr_writer :password

        # Checks to see if the given password is valid.  Returns
        # false if it isn't, true if it is.
        #
        # @param pass [String] the password to check.
        # @return [Boolean]
        def valid_password?(pass)
          if password.nil? || (pass == password && password != "")
            true
          else
            false
          end
        end

        # Checks to see if the given password is valid.  If it is, it
        # sets authenticated to true.  Otherwise, sets it to false.
        #
        # @param pass [String] the password to check.
        # @return [Boolean]
        def check_password(pass)
          @authenticated = valid_password? pass
        end

        # Whether or not it was authenticated.
        #
        # @return [Boolean]
        def authenticated?
          @authenticated
        end

        private

        # Handles the password packet, by checking the password.  If it
        # matches, it returns an "OK" packet.  Otherwise, it returns a
        # "FAIL" packet.
        #
        # @param packet [Packet] the packet that the client sent.
        # @param proto [Protocol] the protocol used to communicate
        #   with the client.
        # @return [void]
        def handle_packet_password(packet, proto)
          if reciever.check_password packet.body
            proto.respond_to packet, :password, "OK"
          else
            proto.respond_to packet, :password, "FAIL"
          end
        end

        public

        # When this is included by {DefaultBehavior}, define the
        # packets nessicary for password management.
        #
        # @return [void]
        def self.included(reciever)
          reciever.handle :packet => :password
        end

      end
    end
  end
end