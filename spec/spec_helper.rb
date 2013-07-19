require 'coveralls'

Coveralls.wear!

module NovaHelper

  def self.build_packet(type = 0, body = "hello world", data = { :packet_id => 1, :nonce => "" })
    Nova::Starbound::Protocol::Packet.build(type, body, data)
  end

  def self.packet_from_socket(sock)
    Nova::Starbound::Protocol::Packet.from_socket(sock)
  end

  def self.build_response(type, body, pack)
    Nova::Starbound::Protocol::Packet.build_response(type, body, pack, :nonce => "")
  end

end
