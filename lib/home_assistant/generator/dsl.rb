require 'yaml'

require_relative 'component'
require_relative 'automation'

module CamelCase
  refine String do
    def snake_case
      gsub(/::/, '/')
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr('-', '_')
        .downcase
    end

    def camel_case
      split('_').collect(&:capitalize).join
    end
  end
end

module HomeAssistant
  module Generator
    # dsl class to read config file and evaluate it
    class DSL
      attr_reader :component_list, :automations

      using CamelCase

      def initialize
        @component_list = []
        @automations = []
      end

      def eval(file_path = nil, &block)
        instance_eval(File.read(file_path), file_path) if file_path
        instance_eval(&block) if block_given?
      end

      def method_missing(name, *args, &block)
        super unless args.one? || Component::EMPTY_CONF_ALLOWED.include?(name) || block_given?

        klass_name = name.to_s.camel_case
        unless DSL.const_defined?(klass_name)
          debug("No #{klass_name} class, defining dynamic class")
          DSL.const_set(klass_name, Class.new(Component) {})
        end
        element = DSL.const_get(klass_name).new(*args)
        component_list << element
        element.instance_eval(&block) if block_given?
        element
      end

      def automation(name, &block)
        Automation.new(name, &block).tap { |auto| automations << auto }
      end

      def to_s
        config = component_list.each_with_object({}) do |component, mem|
          component.class.name.split('::').last.snake_case.tap do |name|
            mem[name] ||= []
            mem[name] << component.to_h
          end
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
