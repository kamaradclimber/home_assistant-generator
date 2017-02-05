homeassistant 'home' do
  longitude 2.3267746000000216
  latitude  48.8264967
  elevation 66
  unit_system 'metric'
  time_zone 'Europe/Paris'
  customize('switch.capodimonte_led': { icon: 'mdi:led-variant-on' })
end

media_player 'KoKodi' do
  platform :kodi
  host 'http://192.168.0.13'
  port 8080
end

sun          # Track sun position
discovery    # Discover some devices automatically
frontend     # Enable home-assistant front-end
conversation # Allow to issue voice commands from the frontend
zeroconf     # Expose home-assistant over bonjour

recorder do
  purge_days 14
end

logbook do
  # sun moves too much, useless in the log
  exclude(domains: %w(sun))
end

updater do
  reporting 'no'
end

yr__sensor
# strictly equivalent to:
#sensor do
#  platform :yr
#end


speedtest__sensor do
  monitored_conditions %w(ping)
  #hour [0, 6, 12, 18]
  #minute 5
end

darksky__sensor do
  api_key 'FAKE_KEY'
end

statistics__sensor 'Ping Stats' do
  entity_id 'sensor.speedtest_ping'
end

waqi__sensor do
  locations %w(paris)
  stations ['place victor basch']
end

nmap_tracker__device_tracker do
  hosts '192.168.0.0/24'
  home_interval 10
  interval_seconds 120
  track_new_devices 'yes'
end

zone 'Criteo' do
  longitude 2.331610
  latitude 48.878887
  icon 'mdi:desktop-tower'
end

limitless__light do
  bridges([
            { host: '192.168.0.110', groups: [{ number: 1, type: 'rgbw', name: 'Table à manger' }] }
          ])
end

command_line__switch 'capodimonte_led' do
  command_on 'sudo systemctl start raspberry_led'
  command_off 'sudo systemctl stop raspberry_led'
  command_state 'sudo systemctl is-active raspberry_led > /dev/null 2>&1'
end

command_line__switch 'nzbget_pause' do
  command_on <<~EOH.split("\n").join(' && ')
    curl -XPOST capodimonte/nzbget/jsonrpc -d '{"method": "pausepost"}'
    curl -XPOST capodimonte/nzbget/jsonrpc -d '{"method": "pausedownload"}'
  EOH
  command_off %(curl -XPOST capodimonte/nzbget/jsonrpc -d '{"method": "scheduleresume", "params": [1]}')
  command_state %(curl -s capodimonte/nzbget/jsonrpc -d '{"method": "status"}' |grep -q 'Paused" : true')
end

command_line__cover 'volets_salon' do
  command_open %(curl -s http://192.168.0.20/up)
  command_close %(curl -s http://192.168.0.20/down)
  command_stop %(curl -s http://192.168.0.20/down) # can't do better for now
  # since "volets" are disconnected very often, output of status pollutes the log TODO
  # command_status %(curl -s http://192.168.0.20/status)
end

input_boolean do # TODO: improve this kind of declaration
  light_control_by_kokodi(
    name: 'Kokodi controle lumière du salon',
    initial: 'on',
    icon: 'mdi:toggle-switch'
  )
end

shell_command do
  classical_music_on_kodi '/var/lib/hass/play_random_classical_music_kodi.sh'
  radio_swiss_classic '/var/lib/hass/play_radio_swiss_classic.sh'
end

automation 'Activate movie playing scene' do
  # trigger.when('KoKodi').from(:paused).to(:playing)

  # Other examples
  trigger.when('KoKodi').playing
  # equivalent to:
  # trigger.when('KoKodi').to(:playing)

  # trigger.at('18:00:00')
  # trigger.when('sun').set
  # trigger.on('my_event_name') # using platform 'event'
  #
  # Documentation:
  # trigger.when('a component short name') creates a trigger on the component state. It is possible to call:
  # from('old state') and  to('new state') on it.
  # It is also possible to call any method whose name is the new state, like .playing
end
