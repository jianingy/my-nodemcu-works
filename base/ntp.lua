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
local M = {
   name=...,
   callback = nil,
   state = nil,
   sec = nil,
   usec = nil,
}

_G[M.name] = M

local function on_done(sec, usec, server)
   tmr.stop(2)
   M.state  = 'NTP_UPDATE_DONE'
   rtctime.set(sec)
   local sec, usec = rtctime.get()
   M.sec, M.usec, M.server = sec, usec, server
   print('ntp: ' .. M.state .. '. time is ' .. M.sec .. '.' .. M.usec)
   M.callback()
end

local function on_error()
   M.state  = 'NTP_UPDATE_ERROR'
   print('ntp: ' .. M.state)
   tmr.alarm(2, 1000, 0, M.update)
end

function M.update(callback)
   M.state = 'NTP_UPDATE_START'
   M.callback = callback
   print('ntp: ' .. M.state .. '. server is ' .. settings.ntp.server)
   sntp.sync(settings.ntp.server, on_done, on_error)
end

return M
