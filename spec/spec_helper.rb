require 'coveralls'

Coveralls.wear!

module SupernovaHelper

  def self.build_packet
    Supernova::Starbound::Protocol::Packet.build(0, "hello world")
  end

end
