module Supernova
  module Starbound
    # Any error that is related to the protocol should inherit this
    # class.
    class ProtocolError < StandardError; end

    # When the protocol needs to exit from a connection, this is
    # raised.
    class ExitError < StandardError; end
  end
end
