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
local M = {
   name=...,
   pin = nil,
   callback = nil
}
_G[M.name] = M

local function read_dht()
   tmr.stop(5)
   assert(type(M.pin) == 'number', 'pms set pin must be a number')
   status, temp, humi, temp_dec, humi_dec = dht.readxx(M.pin)
   print('dht: DHT22 status: ' .. status)
   if status == dht.OK then
      local d = {}
      d['temp'] = math.floor(temp) .. '.' .. temp_dec
      d['humi'] = math.floor(humi) .. '.' .. humi_dec
      M.callback(d)
   end
   tmr.start(5)
end

function M.read (pin, callback)
   print('dht: start reading from DHT22')
   M.callback = callback
   M.pin = pin
   tmr.alarm(5, 5000, 1, read_dht)
end

return M
