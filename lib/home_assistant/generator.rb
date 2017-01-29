require 'yaml'
require 'mash'

require 'home_assistant/generator/version'

module HomeAssistant
  module Generator
    # The basic generator for hass config
    class Generator
      def initialize(file_path)
        @file_path = file_path
      end

      def config!
        DSL.new.tap do |dsl|
          dsl.eval(@file_path)
        end.to_s
      end
    end

    class DSL
      attr_reader :component_list

      def initialize
        @component_list = []
      end

      def eval(file_path)
        instance_eval(File.read(file_path), file_path)
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

      def debug(message)
        $stderr.puts message if ENV['DEBUG']
      end

      def to_s
        component_list.inject(Mash.new) do |mem, component|
          mem[component.component_class] ||= []
          mem[component.component_class] << component.to_h
          mem
        end.to_hash.to_yaml
      end
    end

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
