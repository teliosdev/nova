module Supernova
  module Starbound
    class Protocol

      # Handles messages.
      module Messages

        # Checks the versions of the remote and us.  If the major
        # versions don't match, raise an error.
        #
        # @raise [IncompatibleRemoteError] if the major versions don't
        #   match.
        # @return [void]
        def check_versions(other_packet)
          other_packet.expect(:protocol_version)
          our_major = Supernova::VERSION.split('.').first
          their_major = other_packet.body.split('.').first

          if our_major != their_major
            raise IncompatibleRemoteError,
              "Major versions do not match (our: #{our_major}, " +
              "theirs: #{their_major})"
          end
        end

        # Waits for the remote to send their protocol version, and
        # then checks their version against ours, making sure the
        # versions match.
        #
        # @raise [IncompatibleRemoteError] if the major versions don't
        #   match.
        # @return [void]
        def wait_for_protocol_version
          pack = read

          check_versions(pack)

          respond_to pack, :protocol_version, Supernova::VERSION
        end

        # Handles setting up encryption with the server.  Sends the
        # server the list of options we have, and waits for a
        # response.  The first 4 bytes of the public key correspond
        # to the index of the encryptor, and the rest is the actual
        # public key.  It then sends our public key back, but doesn't
        # wait for a response.
        #
        # @return [void]
        def handle_encryption
          sent = send :encryption_options,
            Encryptor.sorted_encryptors.map(&:encryptor_name).join("\n")

          response = response_to sent
          response.expect(:public_key)

          encryptor = matching_encryptor *response.body.split("\n", 2)

          respond_to response, :public_key, encryptor.public_key
          self.encryption_provider = encryptor
        end

        # Handles the server encryption.  Reads a packet, splits the
        # body by new lines, and searches our encryptors for a
        # matching encryptor.  Initializes it, and sends back data
        # to the client containing which encryptor was used and our
        # public key; waits for a response containing the client's
        # public key, and then sets the encryption provider.
        #
        # @return [void]
        def handle_server_encryption
          enc_options = read
          enc_options.expect(:encryption_options)
          lines = enc_options.body.split("\n")

          encs = Encryptor.sorted_encryptors.select do |e|
            lines.include?(e.encryptor_name)
          end

          preferred = encs.first
          index = lines.index(preferred.encryptor_name)
          encryptor = preferred.new
          encryptor.private_key!

          data = preferred.encryptor_name + "\n"

          out = respond_to enc_options, :public_key, data +
            encryptor.public_key

          pub_key = response_to out
          pub_key.expect(:public_key)

          encryptor.other_public_key = pub_key.body

          self.encryption_provider = encryptor
        end

        private

        # Handles selecting and setting up the encryption for this
        # protocol, given the name from the remote.
        #
        # @return [Encryptor]
        def matching_encryptor(name, body)
          enc = Encryptor.encryptors.select { |e|
            e.encryptor_name == name
          }.first.new
          enc.private_key!
          enc.other_public_key = body

          enc
        end
      end

    end
  end
end
