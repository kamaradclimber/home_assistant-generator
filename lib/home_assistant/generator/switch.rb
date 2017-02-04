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
    class DSL
      class Switch < Component
        def name(value)
          @switch_name = value
        end
        def platform(value)
          @platform = value
        end

        def to_h
          { 'platform' => @platform, 'switches' => { @switch_name => super } }
        end
      end
    end
  end
end
