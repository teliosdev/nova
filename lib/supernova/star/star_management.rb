module Supernova
  class Star
    module StarManagement
      module ClassMethods
        def types
          @@types ||= {}
        end

        def star_type(name)
          types[name] = self
        end
      end

      module InstanceMethods

        attr_accessor :name

      end

      def self.included(receiver)
        receiver.send :include, InstanceMethods
        receiver.extend         ClassMethods
      end
    end
  end
end
