local cpml = require 'cpml-master'
local spritesheet = require 'spritesheet'

function newPlayer()
    return {
        input = cpml.vec2.new(0, 0),
        inputDeadzone = 0.26,
        position = cpml.vec2.new(0, 0),
        velocity = cpml.vec2.new(0, 0),
        minimumVelocity = 1,
        maxVelocity = 100,
        friction = 1,
        sprites = spritesheet.new("content/player.png", 32, 40),
        lastFacingDirection = 2,

        transform = function(player, event)
            if event.type == "input" then
                if event.axis ~= nil then
                    if math.abs(event.value) <= player.inputDeadzone then event.value = 0 end
                    if event.axis == "horizontal" then player.input.x = event.value
                    elseif event.axis == "vertical" then player.input.y = event.value
                    end
                elseif event.button ~= nil then
                    local button = event.button
                    local buttonState = event.state

                    if button == "left" and buttonState == "pressed" then player.input.x = player.input.x - 1
                    elseif button == "left" and buttonState == "released" then player.input.x = player.input.x + 1
                    elseif button == "right" and buttonState == "pressed" then player.input.x = player.input.x + 1
                    elseif button == "right" and buttonState == "released" then player.input.x = player.input.x - 1
                    elseif button == "down" and buttonState == "pressed" then player.input.y = player.input.y - 1
                    elseif button == "down" and buttonState == "released" then player.input.y = player.input.y + 1
                    elseif button == "up" and buttonState == "pressed" then player.input.y = player.input.y + 1
                    elseif button == "up" and buttonState == "released" then player.input.y = player.input.y - 1
                    end
                end
            elseif event.type == "update" then
                local deltaTime = event.deltaTime

                local accelerationDirection = player.input:trim(1.0)
                local acceleration = accelerationDirection:scale(player.maxVelocity * 10 * deltaTime)
                local appliedFriction = player.velocity:scale(12 * deltaTime)
                local velocityLen = player.velocity:len()
                if velocityLen <= player.maxVelocity then
                    local dot = acceleration:dot(appliedFriction)
                    if dot >= 0 then appliedFriction = appliedFriction:sub(acceleration * dot) end
                end
                player.velocity = player.velocity:add(acceleration):sub(appliedFriction):trim(math.max(velocityLen, player.maxVelocity))

                player.position = player.position:add(player.velocity * deltaTime)
            elseif event.type == "draw" then
                local time = event.time
                local graphics = love.graphics

                graphics.setColor(1, 1, 1, 1)
                local sprite = nil
                local x = math.floor(1 + ((time * 8) % 4))
                local y = math.floor(cpml.vec2.new(player.input.y, player.input.x):normalize():angle_to(cpml.vec2.new(0, 1)) / math.pi * -8)
                y = math.max(y, 0)
                if player.input:len() > player.inputDeadzone then
                    player.lastFacingDirection = 2 + y * 6
                    sprite = x + y * 6
                else sprite = player.lastFacingDirection
                end

                graphics.draw(
                    player.sprites.image,
                    player.sprites.quads[sprite],
                    math.floor(player.position.x),
                    math.floor(-player.position.y)
                )
            end
        end,
    }
end

return {
    new = function()
        return {
            time = 0,
            scaleFactor = 3,
            gameView = love.graphics.newCanvas(),
            player = newPlayer(),
            camera = {
                position = cpml.vec2.new(),
            },
            transform = function(state, event)
                if event.type == "input" then
                    state.player:transform(event)
                elseif event.type == "update" then
                    local deltaTime = event.deltaTime
                    state.time = state.time + event.deltaTime
                    state.player:transform(event)
                elseif event.type == "draw" then
                    event.time = state.time -- TODO: this is a workaround
                    local graphics = love.graphics
                    graphics.setCanvas(state.gameView)
                    graphics.clear(0.3, 0.0, 0.3, 1.0, true, true)
                    state.player:transform(event)
                    graphics.setCanvas()
                    graphics.draw(state.gameView, 0, 0, 0, state.scaleFactor, state.scaleFactor)
                end

                return state
            end,
        }
    end,
}
