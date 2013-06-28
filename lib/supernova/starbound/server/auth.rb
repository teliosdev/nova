module Supernova
  module Starbound
    class Server
      module Auth

        attr_reader :options

        def initialize(options = {})
          @options = { :password => "" }.merge(options)
        end

        def try_auth(pass)
          pass == @options[:password]
        end

      end
    end
  end
end
