--
-- This piece of code is written by
--    Jianing Yang <jianingy.yang@gmail.com>
-- with love and passion!
--
--        H A P P Y    H A C K I N G !
--              _____               ______
--     ____====  ]OO|_n_n__][.      |    |
--    [________]_|__|________)<     |YANG|
--     oo    oo  'oo OOOO-| oo\\_   ~o~~o~
-- +--+--+--+--+--+--+--+--+--+--+--+--+--+
--                             30 Mar, 2016
--
require 'settings'
require 'wireless'
require 'ntp'
require 'telnetd'
require 'pms5'
require 'ht'

function on_wifi_connected ()
   ntp.update(on_ready)
end

function send_data(text)

   local function on_sent(s)
      s:close()
   end

   local function on_connected (s)
      s:send(text, on_sent)
   end

   socket = net.createConnection(net.TCP, 0)
   socket:on('connection', on_connected)
   socket:connect(settings.hub.port, settings.hub.host)
end

function on_data(d)
   if (d) then
      json = cjson.encode(d)
      if json then
         print('main: receive data ' .. json)
         send_data(json .. '\n')
      end
   end
end

function on_ready ()
   print("app: system is ready")
   local pin_set = require('settings').pin.pms_set
   pms5.init(pin_set)
   pms5.standby()
   telnetd.start(settings.telnetd.port)
   ht.read(settings.pin.dht, on_data)
   pms5.read(on_data)
end


wireless.connect(settings.wifi.ssid, settings.wifi.secret, on_wifi_connected)
