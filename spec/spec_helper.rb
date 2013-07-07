require 'coveralls'

Coveralls.wear!

module SupernovaHelper

  def self.build_packet(type = 0, body = "hello world", data = { :packet_id => 1, :nonce => "" })
    Supernova::Starbound::Protocol::Packet.build(type, body, data)
  end

  def self.packet_from_socket(sock)
    Supernova::Starbound::Protocol::Packet.from_socket(sock)
  end

  def self.build_response(type, body, pack)
    Supernova::Starbound::Protocol::Packet.build_response(type, body, pack, :nonce => "")
  end



end
