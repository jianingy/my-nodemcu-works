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
-- based on https://github.com/avaldebe/AQmon/blob/master/lua_modules/telnet_app.lua

local M = {
   name = ...,
}

_G[M.name] = M

function M.start(port)
   print('telnetd: starting server at port ' .. port)
   print('telnetd: please use console via telent from now.')
   s = net.createServer(net.TCP, 180)
   s:listen(port,
            function(c)

               function s_output(str)
                  if(c ~= nil) then
                     c:send(str)
                  end
               end

               -- redirect output to function s_ouput.
               node.output(s_output, 0)

               -- works like pcall(loadstring(l)) but support multiple separate line
               c:on("receive",
                    function(c, l)
                       node.input(l)
                    end
               )
               -- un-regist the redirect output function, output goes to serial
               c:on("disconnection",
                    function(c)
                       node.output(nil)
                    end
               )
               print('Welcome to NodeMCU console.\r\n')
   end)
end

return M
