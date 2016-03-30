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
}

_G[M.name] = M

function M.flash(freq)
   local pin = settings.pin.led
   if freq == 0 then
      tmr.stop(0)
      gpio.write(pin, gpio.HIGH)   -- pin.led OFF

   else
      tmr.alarm(0, freq, 1,
                function()
                   -- do not assume HIGH,LOW=1,0
                   gpio.write(pin, gpio.HIGH + gpio.LOW - gpio.read(pin))
                end
      )
   end
end

return M
