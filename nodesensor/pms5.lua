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
   name = ...,
   pin_set = nil,
   callback = nil,
}

_G[M.name] = M

local function parse (data)
   local bs = {}
   local checksum = 0
   local hdl = 4

   for i = 1, hdl do
      bs[i] = string.byte(data, i)
      checksum = checksum + bs[i]
   end

   if bs[1] ~= 0x42 or bs[2] ~= 0x4d then
      return nil
   end

   local length = bs[3] * 256 + bs[4]

   for i = hdl + 1, length + hdl do
      bs[i] = string.byte(data, i)
      if i < 31 then
         checksum = checksum + bs[i]
      end
   end

   if (checksum ~= bs[31] * 256 + bs[32]) then
      print('pms5003: checksum error ' .. checksum .. ' ~= ' ..
               (bs[31] * 256 + bs[32]))
      return nil
   end

   local d = {}

   d['PM1_0-CF1'] = bs[5] * 256 + bs[6]
   d['PM2_5-CF1'] = bs[7] * 256 + bs[8]
   d['PM10-CF1'] = bs[9] * 256 + bs[10]
   d['PM1_0-AT'] = bs[11] * 256 + bs[12]
   d['PM2_5-AT'] = bs[13] * 256 + bs[14]
   d['PM10-AT'] = bs[15] * 256 + bs[16]

   return d
end


local function clear_uart_buffer()
   -- reset device
   gpio.write(M.pin_set, gpio.LOW)
   -- clear buffer
   uart.on('data', 0, function(data) end, 0)
   uart.on('data')
end

local function on_uart(data)
   print('pms5003: receive data from data(length = '.. #data .. ')\r\n')
   start = string.find(data, 'BM')
   if start then
      d = parse(string.sub(data, start))
      if d and M.callback then
         M.callback(d)
      end
   end
   tmr.start(4)
end

local function read_uart()
   print('pms5003: start reading uart\r\n')
   tmr.stop(4)
   clear_uart_buffer()
   uart.on('data', 32, on_uart, 0)
   gpio.write(M.pin_set, gpio.HIGH)
end

function M.init(pin)
   assert(type(pin) == 'number', 'pms set pin must be a number')
   M.pin_set = pin
   gpio.mode(M.pin_set, gpio.OUTPUT)
end

function M.read (callback)
   M.callback = callback
   tmr.alarm(4, 5000, 1, read_uart)
end

function M.standby()
   gpio.write(M.pin_set, gpio.LOW)
end


return M
