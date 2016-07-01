local module = {}

m = nil

colors = {}
colors["off"]    = "000,000,000"
colors["orange"] = "255,064,000"
colors["yellow"] = "255,255,000"
colors["red"]    = "255,000,000"
colors["green"]  = "000,255,000"
colors["blue"]   = "000,000,255"
colors["purple"] = "255,000,255"
colors["white"]  = "255,255,255"

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

local function rgbcolor(c)
    local r, g, b
    local setthem = "000,000,000"

    if c then
        if colors[c] then
            setthem = colors[c]
        end
    end

    r = string.sub(setthem,1,3)
    g = string.sub(setthem,5,7)
    b = string.sub(setthem,9,11)

    led_update(r,g,b)
end

local function mqtt_start()
    m = mqtt.Client(config.ID, 120)

    m:on("message", function(conn, topic, data)
        if data ~= nil then
            print(topic .. ": " .. data)
        end

        if data == "ping" then
            m:publish(config.ENDPOINT .. "ping", "pong", 0, 0)
        end

        if topic == config.ENDPOINT .. config.ID .. "/dishwasher/1" then
            rgbcolor(data)
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
