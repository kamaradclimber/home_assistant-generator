media_player 'KoKodi' do
  platform :kodi
  host 'http://192.168.0.13'
  port 8080
end


automation 'Activate movie playing scene' do
  trigger.when('KoKodi').from(:paused).to(:playing)

  # Other examples
  # trigger.when('KoKodi').playing
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
