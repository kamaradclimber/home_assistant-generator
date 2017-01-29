require 'home_assistant/generator/version'
require 'home_assistant/generator/component'
require 'home_assistant/generator/dsl'

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
  end
end
