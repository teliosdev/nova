require 'supernova/starbound/basic_client'
class Supernova::Starbound::Client < Supernova::Starbound::BasicClient; end

require 'supernova/starbound/packets'
require 'supernova/starbound/client/connect'

module Supernova
  module Starbound
    class Client

      include Client::Connect

    end
  end
end

