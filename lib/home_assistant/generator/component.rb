require 'mash'

module HomeAssistant
  module Generator
    # generic home-assistant component
    class Component
      attr_reader :properties
      attr_accessor :component_class
      def initialize(name)
        @properties = Mash.new
        send(name_property, name)
      end

      def name_property
        :name
      end

      def to_h
        properties.to_hash
      end

      def method_missing(name, *args)
        super unless args.one?

        properties[name.to_sym] = case args.first
                                  when Symbol
                                    args.first.to_s
                                  else
                                    args.first
                                  end
      end
    end
  end
end
