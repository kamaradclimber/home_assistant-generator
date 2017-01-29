require_relative 'properties'

module HomeAssistant
  module Generator
    # generic home-assistant component
    class Component
      prepend Properties

      attr_accessor :component_class
      def initialize(name)
        send(name_property, name)
      end

      def name_property
        :name
      end

      def method_missing(name, *args)
        super unless args.one?

        properties[name.to_s] = case args.first
                                  when Symbol
                                    args.first.to_s
                                  else
                                    args.first
                                  end
      end
    end
  end
end
