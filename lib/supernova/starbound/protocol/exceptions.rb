module Supernova
  module Starbound
    # Any error that is related to the protocol should inherit this
    # class.
    class ProtocolError < StandardError; end

    # When the protocol needs to exit from a connection, this is
    # raised.  Meant to be raised by a third party; not raised by this
    # library.
    class ExitError < StandardError; end

    # Raised when the socket isn't using encryption, and we've
    # already finished with the handshake, and if the
    # +:allow_plaintext+ option isn't true.  Used in
    # {Protocol::Socket}.
    class NoEncryptionError < ProtocolError; end

    # Raised when the major version of the remote does not match the
    # major version of this library.  Used in {Protocol::Messages}.
    class IncompatibleRemoteError < ProtocolError; end

    # The remote closed the connection.  Used in {Protocol::Socket}.
    class RemoteClosedError < ProtocolError; end

    # Raised when a string is unpacked but it doesn't match any
    # struct defined here.  Used in {Protocol::Packet}.
    class NoStructError < ProtocolError; end

    # Raised when a packet is sent when another packet was
    # expected.  Used in {Protocol::Packet}.
    class UnacceptablePacketError < ProtocolError; end

    # Raised if the encryptor runs into an error with encrypting
    # or decrypting the packet.  Used in {Encryptors::OpenSSL} and
    # {Encryptors::RbNaCl}.
    class EncryptorError < StandardError; end
  end
end
