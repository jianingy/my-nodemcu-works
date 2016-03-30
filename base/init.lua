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
-- based on https://github.com/avaldebe/AQmon/blob/master/lua_modules/init.lua
require 'settings'
require 'led'

do
   local pin, console = {led = settings.pin.led, tact = 3}, false

   -- disable serial/uart (console)
   print('Press ENTER or KEY_FLASH to enable the console.')
   uart.on('data', '\r',
           function(data)
              if data=='\r' then
                 console = true
                 uart.on('data')
              end
           end, 0)

   -- pin.led ON
   gpio.write(pin.led, gpio.LOW)
   -- blink: 100 ms ON, 100 ms OFF
   led.flash(100)
   gpio.mode(pin.tact, gpio.INT)
   gpio.trig(pin.tact, 'down',
             function(state)
                led.flash(0)
                console = true
             end
   )

   -- console mode or application
   tmr.alarm(1, 2000, 0,
             function()   -- 2s from boot
                led.flash(0)
                gpio.mode(pin.tact, gpio.INPUT)  -- release pin.tact interrupt
                if console then
                   pin, console = nil, nil
                   print('-== Enter Console/Upload mode ==-')
                   uart.on('data')
                else
                   pin, console = nil, nil
                   print('-== Enter App mode ==-')
                   require('app')
                end
             end
   )
end
