PORT := /dev/ttyUSB0
BAUDRATE := 9600

all: app settings

app: app.lua pms5.lua ht.lua
	nodemcu-uploader  --port $(PORT) upload --compile  $?

settings: settings.lua
	nodemcu-uploader  --port $(PORT) upload --compile  $?
