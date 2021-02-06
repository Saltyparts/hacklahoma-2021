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

function love.keypressed(scancode) pushInputEvent(scancode, "pressed") end
function love.keyreleased(scancode) pushInputEvent(scancode, "released") end

function love.run()
    local event = love.event
    local graphics = love.graphics
    local handlers = love.handlers
    local state = mainMenuState.new()
    local timer = love.timer

    graphics.setDefaultFilter("nearest", "nearest")

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
