require 'multi_json'

module Nova
  module Starbound
    class Cluster

      # The server list.
      #
      # @see #initialize
      # @return [Array<Hash{Symbol => String}>]
      attr_reader :servers

      # @return [Array<Starbound::Client>]
      attr_reader :clients

      # Initialize the cluster.
      #
      # @param servers [Array<Hash{Symbol => String}>] a list of 
      #   servers that this cluster represents.
      # @option servers [Symbol] :type the type of server it is.
      #   Should be either +:tcp+, +:udp+ (not implemented), or 
      #   +:unix+.
      # @option servers [String] :host the IP address of the server to
      #   connect to.  Only applicable for types +:tcp+ and +:udp+.
      # @option servers [Numeric] :port the Port of the server to
      #   connect to.  Only applicable for types +:tcp+ and +:udp+.
      # @option servers [String] :path the path to the unix socket.
      #   Only applicable for +:unix+.
      # @option servers [nil, String] :password if it's nil, no
      #   password is assumed; if it's a string, it's sent as the
      #   password.
      def initialize(servers)
        @servers = servers
        @clients = []
      end

      # Connect to the cluster.
      #
      # @return [void]
      def connect
        servers.each do |data|
          @clients << Starbound::Client.new(data)
        end

        @clients.map do |cl|
          Thread.start(cl) do |client|
            client.handshake
            if client.options[:password]
              client.protocol.send(:password, client.options[:password])
            end
          end
        end.map(&:join)
      end

      # Runs a star on the cluster, with the given options.  The star
      # must be present on the cluster; and it must be running the 
      # default behavior.
      #
      # @see Star.from_target
      # @param star [String] the star to run.  Should be in the format
      #   +"[<star type>.]<star_name>.<action>".
      # @param options [Hash<Symbol, Object>] the options to pass t
      #   the servers.
      # @option options [Hash<String, Object>] :remote options for the
      #   instance of the star on the server.
      # @option options [Hash<String, Object>] :arguments arguments for
      #   the event itself.
      # @return [void]
      def run(star, options)
        data = {"target" => star, "options" => options[:remote],
          "arguments" => options[:arguments] }
        payload = MultiJson.dump(data)

        @clients.map do |client|
          pack = client.send(:star_run, payload)

          Thread.start(client, pack) do |cl, pack|
            cl.protocol.response_to pack
          end
        end.map(&:join)
      end

    end
  end
end