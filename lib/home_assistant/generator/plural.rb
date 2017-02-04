require 'active_support/inflector'

module HomeAssistant
  module Generator
    # using default Component class behavior would lead to write:
    # command_line__switch do
    #   switches(capodimonte_led: {
    #       command_on: ...,
    #       commond_off: ...
    #     },
    #     nzbget_pause: {
    #       command_on: ...,
    #       commond_off: ...
    #     })
    # end
    #
    # which is not very convenient
    # it is easier to read the following code:
    #
    # command_line__switch 'capodimonte_led' do
    #   command_on '...'
    #   command_off '...'
    # end
    # command_line__switch 'nzbget' do
    #   command_on '...'
    #   command_off '...'
    # end
    class PluralComponent < Component
      def name(value)
        @element_name = value
      end

      def platform(value)
        @platform = value
      end

      def to_h
        plural = self.class.name.downcase.split('::').last.pluralize
        if properties.key?(plural)
          # support "dumb" syntax
          { 'platform' => @platform }.merge(super)
        else
          { 'platform' => @platform, plural => { @element_name => super } }
        end
      end
    end
    class DSL
      class Switch < PluralComponent; end
      class Cover < PluralComponent; end
    end
  end
end
