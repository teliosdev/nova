require 'coveralls'

Coveralls.wear!

module SupernovaHelper

  def self.build_packet
    Supernova::Starbound::Protocol::Packet.build(0, "hello world")
  end

  def self.packet_from_socket(sock)
    Supernova::Starbound::Protocol::Packet.from_socket(sock)
  end

  def self.build_response(type, body, pack)
    Supernova::Starbound::Protocol::Packet.build_response(type, body, pack, :nonce => "")
  end

end
