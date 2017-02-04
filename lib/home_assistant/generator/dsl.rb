require 'yaml'

require_relative 'component'
require_relative 'plural'
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

module IfEmpty
  refine Hash do
    def if_empty(default)
      if empty?
        default
      else
        self
      end
    end
  end
end

module HomeAssistant
  module Generator
    # dsl class to read config file and evaluate it
    class DSL
      attr_reader :component_list, :automations

      using CamelCase
      using IfEmpty

      def initialize
        @component_list = []
        @automations = []
      end

      def eval(file_path = nil, &block)
        instance_eval(File.read(file_path), file_path) if file_path
        instance_eval(&block) if block_given?
      end

      def method_missing(name, *args, &block)
        klass_parts = name.to_s.split('__')
        klass_name = klass_parts.pop.camel_case

        platform = klass_parts.pop

        super unless args.one? || # one arg means it's the name
                     Component::EMPTY_CONF_ALLOWED.include?(name) || # some components don't have configuration
                     block_given? || # some component don't have a name
                     platform # some component simply have a platform and no additional conf

        if DSL.const_defined?(klass_name)
          debug("Found #{klass_name} in DSL namespace, will use it")
        else
          debug("No #{klass_name} class, defining dynamic class")
          DSL.const_set(klass_name, Class.new(Component) {})
        end
        element = DSL.const_get(klass_name).new(*args)
        element.send(:platform, platform) if platform
        component_list << element
        element.instance_eval(&block) if block_given?
        element
      end

      def automation(name, &block)
        Automation.new(name, &block).tap { |auto| automations << auto }
      end

      def to_s
        config = component_list.group_by { |component| component.class.name.split('::').last.snake_case }
                      .transform_values do |components|
          if components.one?
            components.first.to_h.if_empty(nil)
          else
            components.map(&:to_h)
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
