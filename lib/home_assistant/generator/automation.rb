require_relative 'properties'

module HomeAssistant
  module Generator
    # describe an automation from home-assistant
    class Automation
      prepend Properties

      def initialize(name, &block)
        properties['alias'] = name
        instance_eval(&block)
      end

      def trigger
        properties['trigger'] ||= Trigger.new
        properties['trigger']
      end

      class Trigger
        prepend Properties
        attr_reader :sub
        def initialize
          @sub = nil
        end

        def when(component_short_name)
          # TODO: search for real entity_id
          properties['entity_id'] = component_short_name
          properties['platform'] = 'state'
          @sub = State.new(properties)
          @sub
        end

        class State
          def initialize(properties)
            @properties = properties
          end

          def method_missing(name, *args)
            case args.size
            when 1
              @properties[name.to_s] = args.first
            when 0
              @properties['to'] = name
            else
              super
            end
            self
          end
        end
      end
    end
  end
end
