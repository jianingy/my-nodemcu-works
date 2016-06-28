PORT := /dev/ttyUSB0
BAUDRATE := 115200
all: init lib

init: init.lua
	nodemcu-uploader --start_baud $(BAUDRATE) --port $(PORT) upload  $?

lib: wireless.lua ntp.lua led.lua telnetd.lua
	nodemcu-uploader --start_baud $(BAUDRATE)  --port $(PORT) upload --compile $?

settings: settings.lua
	nodemcu-uploader --start_baud $(BAUDRATE)  --port $(PORT) upload  $?
