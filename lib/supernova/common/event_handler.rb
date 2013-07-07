require 'set'

require 'supernova/remote/common/event_handler/event'

module Supernova
  module Remote
    module Common
      # Handles events sent to the receiver to be processed.
      module EventHandler

        # Class methods.
        module ClassMethods

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
          # @option (see Event#initialize)
          # @return [Event] the event.
          def on(event, options = {})
            events << Event.new(event, options, Proc.new)
          end

          alias_method :to, :on

          # Checks to see if an event with the given name exists.
          #
          # @note Even if the event with the given name may exist,
          #   the event may still not exist if the options don't match.
          #   If you want to make sure that the event will respond to
          #   the name and options, check {#has_event_with_options?}.
          # @param name [Symbol] the name of the event.
          # @return [nil, Event]
          def has_event?(name)
            events.dup.keep_if { |e| e.name == name }.to_a.first
          end

          # Checks to see if an event can respond to the given name and
          # options.
          #
          # @param name [Symbol] the name of the event.
          # @param options [Hash] the options for the event.
          # @return [nil, Event]
          def has_event_with_options?(name, options = {})
            event = Event.new(name, options)
            event.type = :search
            events.dup.keep_if { |e| e.match? Star.new, event }.to_a.first
          end
        end

        # Instance methods.
        module InstanceMethods

          include ClassMethods

          # Automatically binds the {Star} to itself on initialization.
          def initialize(*)
            # This invalidates the method cache... there has to be a
            # better way to do this...
            bind.include remote
            super()
          end

          # Returns the event list.
          #
          # @see ClassMethods#events
          # @return [Set<EventHandler::Event>]
          def events
            @_events ||= self.class.events.dup
          end

          # Checks to see if an event can respond to the given name and
          # options.
          #
          # @param (see ClassMethods#has_event_with_options?)
          # @return (see ClassMethods#has_event_with_options?)
          def has_event_with_options?(name, options = {})
            event = Event.new(name, options)
            event.type = :search
            events.dup.keep_if { |e| e.match? self, event }.to_a.first
          end

          # Runs an event, with the given name and options.
          #
          # @raise [NoEventError] when it can't find the event.
          # @param name [Symbol] the name of the event.
          # @param options [Hash] the options to pass to the
          #   event.
          # @return [Object] the result of the event.
          def run!(name, options = {})
            matched = has_event_with_options? name, options

            if matched
              matched.run(bind, options)
            else
              raise NoEventError, "Could not find event #{name}."
            end
          end

          # Calls {#run!}, but if it raises a [NoEventError] it returns it
          # instead of raising it.
          #
          # @see #run!
          # @param (see #run!)
          # @return [Object, NoEventError] the result of the event, or the
          # exception.
          def run(name, options = {})
            run! name, options

          rescue NoEventError => e
            e
          end


          # Binds this event handler to a given object, running all events in
          # the context of that object.
          #
          # @param bind [Object] the object to bind to.
          # @return [self]
          def bind!(bind)
            @bind = bind
            self
          end

          # @overload bind(bind)
          #   Binds a copy of this object to a given object, running
          #   all events in the context of that object.
          #
          #   @param bind [Object] the object to bind to.
          #   @return [Feature]
          # @overload bind
          #   Returns the current bind.  Creates an empty object if
          #   it doesn't exist.
          #
          #   @return [Object]
          def bind(bind = nil)
            if bind
              dup.bind!(bind)
            else
              @bind ||= Object.new
            end
          end
        end

        # Called when {EventHandler} is included.  Extends what included
        # it by {ClassMethods}, and includes {InstanceMethods}.
        #
        # @param receiver [Object]
        # @return [void]
        # @api private
        def self.included(receiver)
          receiver.extend         ClassMethods
          receiver.send :include, InstanceMethods
        end
      end
    end
  end
end
