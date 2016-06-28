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
--                             29 Mar, 2016
--

require 'settings'
require 'led'

local M = {
   name = ...,
   callback = nil,
   state = nil,
   ip = nil,
   netmask = nil,
   gateway = nil
}

local state_map = {
   [0] = 'STATION_IDLE',
   [1] = 'STATION_CONNECTING',
   [2] = 'STATION_WRONG_PASSWORD',
   [3] = 'STATION_NO_AP_FOUND',
   [4] = 'STATION_CONNECT_FAIL',
   [5] = 'STATION_GOT_IP'
}

_G[M.name] = M

local function on_connected()
   M.state = state_map[wifi.sta.status()]
   tmr.alarm(1, 1000, 0, M.callback)
end

local function wait_for_wifi()
   M.state = state_map[wifi.sta.status()]
   print('wireless: ' .. M.state)
   if M.state == 'STATION_GOT_IP' then
      led.flash(0)
      M.ip, M.netmask, M.gateway = wifi.sta.getip()
      tmr.stop(1)
      print('wireless: ip is ' .. M.ip)
      on_connected()
   elseif  M.state == 'STATION_CONNECT_FAIL' then
      led.flash(500)
      tmr.stop(1)
   end
end

function M.connect(ssid, secret, callback)
   M.ssid, M.secret, M.callback = ssid, secret, callback
   M.state = state_map[wifi.sta.status()]
   wifi.setmode(wifi.STATION)
   print('wireless: connecting to ' .. ssid .. ' with secret ' .. secret)
   wifi.sta.config(ssid, secret)
   led.flash(1000)
   tmr.alarm(1, 2000, 1, wait_for_wifi)
   M.state = state_map[wifi.sta.status()]
end

return M
