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
            scaleFactor = 3,
            map = {
                {
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 39, 37, 37, 37, 37, 37, 37, 37, 40, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 39, 34, 33, 33, 33, 33, 33, 33, 33, 35, 40, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 39, 34, 33, 33, 33, 33, 33, 33, 33, 33, 33, 35, 40, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 42, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 70, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 42, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 70, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 42, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 70, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 42, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 70, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 42, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 67, 72, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 71, 66, 33, 33, 33, 33, 33, 33, 33, 33, 67, 72, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 71, 73, 77, 69, 69, 69, 77, 69, 69, 72, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                },
                {
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 186, 187, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 186, 187, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 186, 187, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                },
                {
                    0, 0, 0, 0, 0, 25, 26, 27, 28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 57, 58, 59, 60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 26, 27, 28, 0,
                    0, 162, 164, 164, 165, 89, 90, 91, 92, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1385, 1386, 0, 57, 58, 59, 60, 0,
                    0, 195, 0, 0, 196, 121, 122, 123, 124, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1417, 1418, 0, 89, 90, 91, 92, 0,
                    0, 258, 259, 260, 261, 153, 154, 155, 156, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1449, 1450, 0, 121, 122, 123, 124, 0,
                    0, 290, 291, 292, 293, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 153, 154, 155, 156, 0,
                    0, 322, 323, 324, 325, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 162, 164, 164, 165, 1, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 162, 0, 43, 45, 0, 198, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 195, 0, 46, 33, 74, 196, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 195, 0, 38, 33, 74, 196, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 26, 27, 28, 0, 0, 0, 0, 0, 0, 0, 195, 0, 75, 77, 72, 196, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 1385, 1386, 0, 0, 57, 58, 59, 60, 0, 0, 0, 0, 0, 0, 0, 225, 0, 0, 0, 0, 230, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 1417, 1418, 0, 0, 89, 90, 91, 92, 0, 0, 0, 0, 0, 0, 0, 257, 225, 259, 260, 261, 262, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 1449, 1450, 0, 0, 121, 122, 123, 124, 0, 0, 0, 0, 0, 0, 0, 289, 257, 291, 292, 293, 294, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 153, 154, 155, 156, 0, 0, 0, 0, 0, 0, 0, 0, 289, 323, 324, 325, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                },
                spritesheet = spritesheet.new("content/tileset.png", 16, 16),
                width = 30,
            },
            time = 0,
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

                    graphics.setColor(1, 1, 1, 1)
                    for i = 1, #state.map[1] do
                        local map = state.map
                        graphics.draw(map.spritesheet.image, map.spritesheet.quads[map[1][i]], 16 * ((i - 1) % map.width), math.floor((i - 1) / map.width) * 16)
                    end

                    for i = 1, #state.map[2] do
                        local map = state.map
                        if map[2][i] ~= 0 then
                            graphics.draw(map.spritesheet.image, map.spritesheet.quads[map[2][i]], 16 * ((i - 1) % map.width), math.floor((i - 1) / map.width) * 16)
                        end
                    end

                    state.player:transform(event)

                    for i = 1, #state.map[3] do
                        local map = state.map
                        if map[3][i] ~= 0 then
                            graphics.draw(map.spritesheet.image, map.spritesheet.quads[map[3][i]], 16 * ((i - 1) % map.width), math.floor((i - 1) / map.width) * 16)
                        end
                    end

                    graphics.setCanvas()
                    graphics.draw(state.gameView, 0, 0, 0, state.scaleFactor, state.scaleFactor)
                end

                return state
            end,
        }
    end,
}
