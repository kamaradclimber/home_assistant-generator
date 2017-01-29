require 'home_assistant/generator/version'

module HomeAssistant
  module Generator
    # The basic generator for hass config
    class Generator
      def initialize(file_path)
        @file_path = file_path
      end

      def config!
      end
    end
  end
end
