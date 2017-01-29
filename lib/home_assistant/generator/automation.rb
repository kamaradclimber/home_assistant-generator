module HomeAssistant
  module Generator
    # describe an automation from home-assistant
    class Automation
      attr_reader :properties

      def initialize(name, &block)
        @properties = {}
        properties[:alias] = name
        instance_eval(&block)
      end

      def trigger
        properties[:trigger] ||= Trigger.new
        properties[:trigger]
      end

      class Trigger
        attr_reader :properties
        def initialize
          @properties = {}
        end

        def when(component_short_name)
          # TODO: search for real entity_id
          properties[:entity_id] = component_short_name
          properties[:platform] = 'state'
          self
        end

        def method_missing(name, *args)
          case args.size
          when 1 
            properties[name] = args.first
          when 0
            properties[:to] = name
          else
            super
          end
          self
        end

      end
    end
  end
end
