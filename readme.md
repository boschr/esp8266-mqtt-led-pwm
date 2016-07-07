# ESP8266 MQTT led pwm

A project to control a ledstrip (like a 5050 SMD) with the MQTT protocol connected on a ESP8266 with PWM.

## System requirements
- ..

## Getting started
- Create a `config.lua` with the following configuration

```
local module = {}

module.SSID = {}
module.SSID["ssid1"] = "passw1"
module.SSID["ssid2"] = "passw2"

module.MQTT_HOST = "test.mosquitto.org"
module.MQTT_PORT = 1883

module.ID = node.chipid()

module.ENDPOINT = "esp/"

module.PIN_RED = 1
module.PIN_GRN = 2
module.PIN_BLU = 3

return module
```
