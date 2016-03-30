PORT := /dev/ttyUSB0

all: init lib

init: init.lua
	nodemcu-uploader --port $(PORT) upload  $?

lib: wireless.lua ntp.lua led.lua telnetd.lua
	nodemcu-uploader  --port $(PORT) upload --compile $?

settings: settings.lua
	nodemcu-uploader  --port $(PORT) upload  $?
