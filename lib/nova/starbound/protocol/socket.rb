require 'thread'

module Nova
  module Starbound
    class Protocol

      # Handles sending data on the socket.
      module Socket

        # The socket to write data to.
        #
        # @return [#read, #write]
        attr_accessor :socket

        # The queue that holds messages.
        #
        # @return [Queue]
        attr_reader :queue

        # The current packet id.
        #
        # @return [Numeric]
        attr_reader :current_packet_id

        # Sends out a regular packet with the given type and body.
        #
        # @param packet_type [Symbol] the packet type of this packet.
        #   See {Packet::Type} for a list of packet types.
        # @param body [String] the body of the packet.
        # @param others [Hash] other data to pass to the packet.
        # @return [Packet] the sent packet.
        def send(packet_type, body, others = {})
          others = others.merge(:packet_id => current_packet_id)
          @current_packet_id += 1
          write_packet Packet.build(packet_type, body, others)
        end

        # Sends out a response packet with the given type and body.
        #
        # @param packet [Packet] the packet to respond to.
        # @param type [Symbol] the packet tpye of this packet.  See
        #   {Packet::Type} for a list of packet types.
        # @param body [String] the body of this packet.
        # @param others [Hash] the other data to pass to the packet.
        # @return [Packet] the sent packet.
        def respond_to(packet, type, body, others = {})
          write_packet Packet.build_response(type, body, packet,
            others)
        end

        # Writes the given packet to the socket, after handling the
        # encryption of the packet.
        #
        # @return [Packet] the sent packet.
        def write_packet(packet)
          new_packet = encryption_provider.encrypt(packet)

          socket.write new_packet
          socket.flush

          new_packet
        end

        # Waits for a packet and returns it.  If it's threaded, or if
        # there's data in the queue, it
        # waits for a message in the queue and pops off the top one.
        # If it's not, it just reads from the socket.
        #
        # @raise [RemoteClosedError] if it recieves a +:close+ packet.
        # @param read_check [Boolean] whether or not to check the read
        #   list for the packet.
        # @return [Packet]
        def read(read_check = true)
          pack = if @read.length > 0 && read_check
            @read.pop
          elsif threaded?
            queue.pop
          else
            wait_for_socket
          end

          if pack && pack.type == :close
            raise RemoteClosedError
          end

          pack
        end

        # Returns whether or not this instance of the protocol uses
        # threads to handle reading.
        #
        # @return [Boolean]
        def threaded?
          @threaded
        end

        # Whether or not this is actually running.
        #
        # @return [Boolean]
        def run?
          @run
        end

        # Initializes the socket.
        def initialize
          @threaded = @options.fetch(:threaded, true)
          @run = true
          @queue = Queue.new
          @read  = []
          @current_packet_id = 0
        end

        # The thread that is filling the queue with packet data.  If
        # it doesn't exist, it creates one, if this is threaded.
        #
        # @return [nil, Thread] nil if this is not threaded, Thread
        #   otherwise.
        def thread
          return unless threaded?

          @_thread ||= Thread.start do
            while run?
              packet = wait_for_socket

              queue << packet
            end
          end
        end

        # Stores callbacks for when packets arrive.
        #
        # @param data [Hash<(Symbol, Symbol)>] should consist of only
        #   one key-value pair, with the key being the struct that
        #   represents the packet, and the type being the type of
        #   packet.
        # @yieldparam packet [Packet] the packet.
        def on(data, &block)
          struct = data.keys.first
          type   = data.values.first

          callbacks[type].push :struct => struct,
            :type => type, :block => block
        end

        # The callbacks that have been defined on this protocol.
        #
        # @return [Hash<Symbol, Object>] the symbol is the type of
        #   packet.
        def callbacks
          @_callbacks ||= Hash.new { |h, k| h[k] = [] }
        end

        # Runs a callback.
        #
        # @param struct [Symbol] the struct that the callback is for.
        # @param type [Symbol] the type of callback this is for.
        # @return [Array<Object>] all of the results from running the
        #   callbacks.
        def run_callback(struct, type, *args)
          callbacks[type].select { |c|
            c[:struct] == struct }.map do |c|
            c[:block].call(*args)
          end
        end

        # Keep looping until we stop running.  Reads packets
        # continuously until we do stop.
        #
        # @return [void]
        def loop
          while run?
            read
          end
        end

        # Finds the response to the given packet.
        #
        # @param packet [Packet]
        # @return [nil, Packet] nil if it was told to stop running
        #   before it could find a response.
        def response_to(packet)
          response = nil

          while response.nil? && run?
            temp = read(false)

            if temp.struct == :response && temp.response_id == packet.id
              response = temp
            end
          end

          response
        end

        # Closes down the socket.
        #
        # @return [void]
        def close
          @run = false

          socket.close
        end

        private

        # Blocks the thread until data is available, or this is
        # signaled to stop running.
        #
        # @return [nil, Packet] nil when it was told to stop running
        #   before data was given, Packet otherwise.
        def wait_for_socket
          packet = nil

          while packet.nil? && run?

            out = IO.select [socket], nil, nil, 0.1
            next unless out

            packet = encryption_provider.decrypt(
              Packet.from_socket(socket))

            run_callback packet.struct, packet.type, packet
          end

          packet
        end

      end
    end
  end
end
