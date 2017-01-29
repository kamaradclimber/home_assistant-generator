require 'yaml'

require_relative 'component'
require_relative 'automation'

module HomeAssistant
  module Generator
    # dsl class to read config file and evaluate it
    class DSL
      attr_reader :component_list, :automations

      def initialize
        @component_list = []
        @automations = []
      end

      def eval(file_path = nil, &block)
        instance_eval(File.read(file_path), file_path) if file_path
        instance_eval(&block) if block_given?
      end

      def method_missing(name, *args, &block)
        super unless args.one?

        klass_name = name.to_s.split('_').collect(&:capitalize).join
        element = if DSL.const_defined?(klass_name) && DSL.const_get(klass_name)
                    debug("Defining #{klass_name} instance")
                    DSL.const_get(klass_name).new(*args)
                  else
                    debug("No #{klass_name} class, fallback on basic component")
                    Component.new(*args).tap { |c| c.component_class = name }
                  end
        component_list << element
        element.instance_eval(&block) if block_given?
        element
      end

      def automation(name, &block)
        Automation.new(name, &block).tap { |auto| automations << auto }
      end

      def to_s
        config = component_list.inject({}) do |mem, component|
          mem[component.component_class.to_s] ||= []
          mem[component.component_class.to_s] << component.to_h
          mem
        end

        config = config.merge('automation' => automations.map(&:to_h))
        config.to_h.to_yaml
      end

      private

      def debug(message)
        $stderr.puts message if ENV['DEBUG']
      end
    end
  end
end