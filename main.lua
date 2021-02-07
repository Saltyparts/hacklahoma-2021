local spritesheet = require 'spritesheet'
local mainMenuState = require 'main_menu_state'

function clamp(val, min, max)
    return math.max(min, math.min(val, max));
end

local eventBuffer = {
    first = 0,
    last = -1,
    push = function(eventBuffer, event)
        eventBuffer.last = eventBuffer.last + 1
        eventBuffer[eventBuffer.last] = event
    end,
    peek = function(eventBuffer)
        if eventBuffer.first > eventBuffer.last then return nil end
        return eventBuffer[eventBuffer.first]
    end,
    pop = function(eventBuffer)
        if eventBuffer.first > eventBuffer.last then return nil end
        local event = eventBuffer[eventBuffer.first]
        eventBuffer[eventBuffer.first] = nil
        eventBuffer.first = eventBuffer.first + 1
        return event
    end,
}

function pushInputEvent(device, kind, specifier, value)
    if device ~= "keyboard" then device = device:getGUID() end

    local event = {
        type = "input",
        device = device,
        kind = kind,
        value = value,
    }

    if device == "keyboard" then
        if specifier == "escape" then event.specifier = "start"
        elseif specifier == "a" then event.specifier = "left"
        elseif specifier == "d" then event.specifier = "right"
        elseif specifier == "s" then event.specifier = "down"
        elseif specifier == "w" then event.specifier = "up"
        elseif specifier == "c" then event.specifier = "accept"
        elseif specifier == "x" then event.specifier = "cancel"
        end
    else
        if kind == "axis" then
            if specifier == "leftx" then event.specifier = "horizontal"
            elseif specifier == "lefty" then event.specifier = "vertical"
            end
        elseif kind == "button" then
            if specifier == "dpleft" then event.specifier = "left"
            elseif specifier == "dpright" then event.specifier = "right"
            elseif specifier == "dpdown" then event.specifier = "down"
            elseif specifier == "dpup" then event.specifier = "up"
            elseif specifier == "a" then event.specifier = "accept"
            elseif specifier == "x" then event.specifier = "cancel"
            end
        end
    end

    eventBuffer:push(event)
end

function love.gamepadaxis(joystick, axis, value) pushInputEvent(joystick, "axis", axis, value) end
function love.gamepadpressed(joystick, button) pushInputEvent(joystick, "button", button, "pressed") end
function love.gamepadreleased(joystick, button) pushInputEvent(joystick, "button", button, "released") end
function love.keypressed(scancode) pushInputEvent("keyboard", "button", scancode, "pressed") end
function love.keyreleased(scancode) pushInputEvent("keyboard", "button", scancode, "released") end

function love.run()
    local event = love.event
    local graphics = love.graphics
    local handlers = love.handlers
    local state = mainMenuState.new()
    local timer = love.timer
    local window = love.window

    graphics.setDefaultFilter("nearest", "nearest")
    window.setMode(1440, 864)

    -- Required for the first calculation of deltaTime
    timer.step()

    -- Main loop
    return function()
        -- Internal event handling
        event.pump()
        for name, a, b, c, d, e, f in event.poll() do
            if name == "quit" then return a or 0 end
            handlers[name](a, b, c, d, e, f)
        end

        -- State event handling
        while eventBuffer:peek() ~= nil do
            local event = eventBuffer:pop()
            state = state:transform(event)
        end

        -- Apply deltaTime to state
        state = state:transform({
            type = "update",
            deltaTime = timer.step(),
        })

        -- Draw the current state
        if graphics.isActive() then
            graphics.setColor(1, 0, 1, 1)
            graphics.push()
            state = state:transform({ type = "draw" })
            graphics.pop()
            graphics.present()
        end
    end
end
