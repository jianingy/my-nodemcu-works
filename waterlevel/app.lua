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
-- require 'telnetd'

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function on_wifi_connected ()
   ntp.update(on_ready)
end

function send_data(text)

   local function on_sent(s)
      s:close()
      s = nil
   end

   local function on_connected (s)
      s:send(text, on_sent)
   end

   socket = net.createConnection(net.TCP, 0)
   socket:on('connection', on_connected)
   socket:connect(settings.hub.port, settings.hub.host)
   socket = nil
end

function on_ready ()
   print("app: system is ready")
   print("app: configuring adc mode")
   local pin_pump = require('settings').pin.pump
   gpio.mode(pin_pump, gpio.OUTPUT)
   gpio.write(pin_pump, gpio.HIGH)
   print("ctrld: pump deactivated")
   -- telnetd.start(settings.telnetd.port)
   start_controller_server()
   tmr.alarm(4, settings.interval, 1, read_waterlevel)
end

function start_controller_server()
   srv = net.createServer(net.TCP, 180)
   print("ctrld: controller server started")
   srv:listen(settings.controller.port, on_controller_server_connected)
end

function on_controller_server_connected (s)
   s:on("receive", on_controller_server_command)
end

function on_controller_server_command (s, payload)
   cmd = trim(payload)
   print("ctrld: got payload '" .. cmd .. "'")
   s:send("GOT\n")
   s:close()
   s = nil

   local pin_pump = require('settings').pin.pump
   if cmd == "pump on" then
      gpio.write(pin_pump, gpio.LOW)
   elseif cmd == "pump off" then
      gpio.write(pin_pump, gpio.HIGH)
   end

end

function read_waterlevel ()
   tmr.stop(4)
   val = adc.read(0)
   print('waterlevel: ' .. val)
   local pin_pump = require('settings').pin.pump
   if val > 360 then
      gpio.write(pin_pump, gpio.LOW)
   elseif val < 200 then
      gpio.write(pin_pump, gpio.HIGH)
   end
   sec, usec = rtctime.get()
   send_data('daling.environment.ac.waterlevel ' .. val .. ' ' .. sec .. '\r\n')
   tmr.alarm(4, settings.interval, 1, read_waterlevel)
end


wireless.connect(settings.wifi.ssid, settings.wifi.secret, on_wifi_connected)
