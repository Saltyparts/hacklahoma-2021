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

function pushGamepadEvent(eventType, joystick, button, state)
    local event = { type = "input" }

    if eventType == "axis" then
        local axis = button -- this is dumb, I'm aware
        event.value = state

        if axis == "leftx" then event.axis = "horizontal"
        elseif axis == "lefty" then
            event.axis = "vertical"
            event.value = event.value * -1
        end
    elseif eventType == "button" then
        event.state = state

        if button == "dpleft" then event.button = "left"
        elseif button == "dpright" then event.button = "right"
        elseif button == "dpdown" then event.button = "down"
        elseif button == "dpup" then event.button = "up"
        elseif button == "a" then event.button = "accept"
        elseif button == "x" then event.button = "cancel"
        end
    end

    eventBuffer:push(event)
end

function pushInputEvent(scancode, state)
    local event = {
        type = "input",
        state = state,
    }

    if scancode == "escape" then event.button = "start"
    elseif scancode == "left" then event.button = "left"
    elseif scancode == "right" then event.button = "right"
    elseif scancode == "down" then event.button = "down"
    elseif scancode == "up" then event.button = "up"
    elseif scancode == "c" then event.button = "accept"
    elseif scancode == "x" then event.button = "cancel"
    end

    eventBuffer:push(event)
end

function love.gamepadaxis(joystick, axis, value) pushGamepadEvent("axis", joystick, axis, value) end
function love.gamepadpressed(joystick, button) pushGamepadEvent("button", joystick, button, "pressed") end
function love.gamepadreleased(joystick, button) pushGamepadEvent("button", joystick, button, "released") end
function love.keypressed(scancode) pushInputEvent(scancode, "pressed") end
function love.keyreleased(scancode) pushInputEvent(scancode, "released") end

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
        state:transform({
            type = "update",
            deltaTime = timer.step(),
        })

        -- Draw the current state
        if graphics.isActive() then
            graphics.setColor(1, 0, 1, 1)
            graphics.push()
            state:transform({ type = "draw" })
            graphics.pop()
            graphics.present()
        end
    end
end
