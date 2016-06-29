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

local pump_auto = 1
local pump_status = 0

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
   local pin_pump = settings.pin.pump
   gpio.mode(pin_pump, gpio.OUTPUT)
   set_pump_power(0)
   print("ctrld: pump deactivated")
   -- telnetd.start(settings.telnetd.port)
   start_controller_server()
   tmr.alarm(4, settings.interval.waterlevel, 1, read_waterlevel)
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
   local pin_pump = settings.pin.pump
   if cmd == "pump on" then
      pump_auto = 0
      set_pump_power(1)
      print("pump: switched on manually")
      s:send("pump: switched on manually\r\n")
      tmr.alarm(6, settings.interval.pump_auto, 1, set_pump_auto)
   elseif cmd == "pump off" then
      pump_auto = 0
      set_pump_power(0)
      print("pump: switched off manually")
      s:send("pump: switched off manually\r\n")
      tmr.alarm(6, settings.interval.pump_auto, 1, set_pump_auto)
   elseif cmd == "pump auto" then
      pump_auto = 1
      print("pump: set pump power mode to auto")
      s:send("pump: set pump power mode to auto\r\n")
   elseif cmd == "pump status" then
      s:send("pump: status = " .. pump_status .. "\r\n")
   end
   s:close()
   s = nil
end

function read_waterlevel ()
   tmr.stop(4)
   val = adc.read(0)
   print('waterlevel: ' .. val)
   if pump_auto > 0 then
      if val > 360 then
         print("pump: switch on automatically")
         set_pump_power(1)
      elseif val < 200 then
         set_pump_power(0)
         print("pump: switch off automatically")
      end
   end
   sec, usec = rtctime.get()
   send_data('daling.environment.ac.waterlevel ' .. val .. ' ' .. sec .. '\r\n')
   tmr.alarm(4, settings.interval.waterlevel, 1, read_waterlevel)
end

function set_pump_power(status)
   local pin_pump = settings.pin.pump
   if status == 1 then
      gpio.write(pin_pump, gpio.LOW)
   else
      gpio.write(pin_pump, gpio.HIGH)
   end
   pump_status = status
end

function set_pump_auto()
   tmr.stop(6)
   pump_auto = 1
end


wireless.connect(settings.wifi.ssid, settings.wifi.secret, on_wifi_connected)
