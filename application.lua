local module = {}

m = nil

local function send_ping()
    if m ~= nil then
        m:publish(config.ENDPOINT .. "ping", "id=" .. config.ID, 0, 0)
    end
end

local function register_myself()
    m:subscribe(config.ENDPOINT .. config.ID .. "/#", 0, function(conn)
        print("Succesfully subscribe to data endpoint: ")
    end)
end

local function led_update(r, g, b)
    pwm.setduty(config.PIN_RED, r*1023/255)
    pwm.setduty(config.PIN_GRN, g*1023/255)
    pwm.setduty(config.PIN_BLU, b*1023/255)
end

local function rgbcolor(color)
    local r, g, b

    r = string.sub(color,1,3)
    g = string.sub(color,5,7)
    b = string.sub(color,9,11)

    return {red = r, green = g, blue = b}
end

local function mqtt_start()
    m = mqtt.Client(config.ID, 120)

    m:on("message", function(conn, topic, data)
        if data ~= nil then
            print(topic .. ": " .. data)
        end

        if topic == config.ENDPOINT .. config.ID .. "/dishwasher/1" then
                local rgbObj = rgbcolor(data)

                led_update(rgbObj.red, rgbObj.green, rgbObj.blue)
        end
    end)

    m:connect(config.MQTT_HOST, config.MQTT_PORT, 0, 1, function(conn)
        register_myself()

        tmr.stop(6)
        tmr.alarm(6, 1000, 1, send_ping)
    end)
end

local function led_start(freq, duty)
    pwm.setup(config.PIN_RED, freq, duty)
    pwm.setup(config.PIN_GRN, freq, duty)
    pwm.setup(config.PIN_BLU, freq, duty)

    pwm.start(config.PIN_RED)
    pwm.start(config.PIN_GRN)
    pwm.start(config.PIN_BLU)
end

function module.start()
    print("Application STARTED!!")
    led_start(100, 100)
    mqtt_start()
end

return module
