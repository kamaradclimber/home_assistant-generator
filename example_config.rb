media_player 'KoKodi' do
  platform :kodi
  host 'http://192.168.0.13'
  port 8080
end

#
#automation 'Activate movie playing scene' do
#  trigger.when('KoKodi').state(to: 'playing')
#end
