require 'set'

require 'supernova/star/event_handler/event'

module Supernova
  class Star
    # Handles events sent to the receiver to be processed.
    module EventHandler

      module InstanceMethods

        # A list of all of the events defined in the class.
        #
        # @return [Set<EventHandler::Event>]
        def events
          @_events ||= Set.new
        end

        # Creates an event, adds it to the list, and returns it.
        #
        # @param event [Symbol] the name of the event.
        # @param options [Hash] the options for the event, when creating
        #   it.
        # @yieldparam options [Hash] the options for the event when ran.
        #   The contents of the options hash is defined at the time when
        #   ran.
        # @return [Event] the event.
        def on(event, options = {})
          events << Event.new(event, options, Proc.new)
        end

        alias_method :to, :on

        # Runs an event, with the given name and options.
        #
        # @raises [NoEventError] when it can't find the event.
        # @param context [Object] the context to run it in.
        # @param name [Symbol] the name of the event.
        # @param options [Hash] the options to pass to the
        #   event.
        # @return [Object] the result of the event.
        def run!(context, name, options = {})
          event = Event.new(name, options)
          event.type = :search

          matched = events.dup.keep_if { |e| e.match? event }.to_a.first

          if matched
            matched.run(options)
          else
            raise NoEventError, "Could not find event #{name}."
          end
        end

        # Calls {#run!}, but if it raises a [NoEventError] it returns it
        # instead of raising it.
        #
        # @see {#run!}
        # @param context [Object]
        # @param name [Symbol]
        # @param options [Hash]
        # @return [Object, NoEventError] the result of the event, or the
        # exception.
        def run(context, name, options = {})
          run! context, name, options

        rescue NoEventError => e
          e
        end
      end

      class NoEventError < StandardError; end

      def self.included(receiver)
        receiver.send :include, InstanceMethods
      end
    end
  end
end
