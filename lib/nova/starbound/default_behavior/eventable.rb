module Nova
  module Starbound
    class DefaultBehavior

      # Handles events such as packets.
      module Eventable

        # Class methods.
        module ClassMethods
          
          # Defines how to handle a specific type of packet.  The
          # method of handling a packet can be defined in 3 ways:
          # first, if a method name (second argument) is given, 
          # that method is used to handle the packet.  Second, if
          # a block is given, that block is used.  And last, if
          # neither of them are provided, the method name is assumed
          # from the struct type and packet type in the format
          # +handle_<struct>_<packet>+.  The given method can and
          # should be private.
          #
          # @note If a block isn't used, the method should accept two
          #   arguments (see yield params for the arguments).
          # @param type [Hash<Symbol, Symbol>] a single key-value pair,
          #   with the key being the struct type and the value being
          #   the packet type.
          # @param meth [nil, Symbol] the method name to use when
          #   calling a block.
          # @yieldparam packet [Packet] the packet.
          # @yieldparam protocol [Protocol] the protocol.
          # @return [void]
          def handle(type, meth = nil, &block)
            struct = type.keys.first
            packet = type.values.first

            proc = nil

            if meth
              proc = meth
            elsif block_given?
              proc = block
            else
              proc = :"handle_#{struct}_#{packet}"
            end

            handles[{struct => packet}] = proc
          end

          # The handles for events that are defined on this class.
          #
          # @return [Hash]
          def handles
            @handles ||= {}
          end

        end
        
        # Instance methods.
        module InstanceMethods

          # Attaches the specified events to the protocol.
          #
          # @return [void]
          def attach_events(protocol)
            self.class.handles.each do |k, v|
              if v.is_a? Symbol
                protocol.on(k, &method(v))
              else
                protocol.on(k, &v)
              end
            end
          end
          
        end
        
        # Called when this module is included by a module or class.
        # Extends that module or class by {ClassMethods}, and includes
        # {InstanceMethods} into that class.
        #
        # @return [void]
        def self.included(receiver)
          receiver.extend         ClassMethods
          receiver.send :include, InstanceMethods
        end
      end
    end
  end
end