module Supernova
  module Starbound
    class Server
      module Listen

        attr_accessor :thread_list

        attr_accessor :run

        attr_accessor :server

        def listen(on_ip = "127.0.0.1", on_port = 2010)
          @thread_list = []
          @run = true

          @server = TCPServer.new on_ip, on_port
          Supernova.logger.info { "Initializing server on #{on_ip}:#{on_port}..." }

          @thread_list << Thread.start(@server) do |server|
            while @run do
              server.listen(5)
              @thread_list << Thread.start(server.accept) { |client|
                Supernova.logger.info { "Client accepted from #{client.addr[2]}" }
                handle_client(ServerClient.new(client))
              }

              @thread_list.select { |t| t[:close] }.each do |t|
                t.join
                @thread_list.delete(t)
              end
            end
          end
        end

        def handle_client(client)
          client.listen_data
        end

      end
    end
  end
end
