require 'home_assistant/generator/version'

module HomeAssistant
  module Generator
    # The basic generator for hass config
    class Generator
      def initialize(file_path)
        @file_path = file_path
      end

      def config!
        DSL.new.eval(@file_path)
      end
    end

    class DSL
      def eval(file_path)
        instance_eval(File.read(file_path))
      end
    end
  end
end
