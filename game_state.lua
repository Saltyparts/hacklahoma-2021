local cpml = require 'cpml-master'
local spritesheet = require 'spritesheet'

return {
    new = function()
        return {
            time = 0,
            scaleFactor = 3,
            gameView = love.graphics.newCanvas(),
            move = cpml.vec2.new(0, 0),
            player = {
                position = cpml.vec2.new(0, 0),
                sprites = spritesheet.new("content/player.png", 32, 40),
                --animations = {
                --    idleUp = { 1, speed = 0 },
                --    walkUp = { 1, 2, 3, 2, speed = 5 },
                --    walkUpRight = { 12, 13, 14, 13, speed = 5 },
                --}
            },
            camera = {
                position = cpml.vec2.new(),
            },
            transform = function(state, event)
                if event.type == "input" then
                    local button = event.button
                    local buttonState = event.state
                    if button == "left" and buttonState == "pressed" then state.move.x = state.move.x - 1
                    elseif button == "left" and buttonState == "released" then state.move.x = state.move.x + 1
                    elseif button == "right" and buttonState == "pressed" then state.move.x = state.move.x + 1
                    elseif button == "right" and buttonState == "released" then state.move.x = state.move.x - 1
                    elseif button == "down" and buttonState == "pressed" then state.move.y = state.move.y - 1
                    elseif button == "down" and buttonState == "released" then state.move.y = state.move.y + 1
                    elseif button == "up" and buttonState == "pressed" then state.move.y = state.move.y + 1
                    elseif button == "up" and buttonState == "released" then state.move.y = state.move.y - 1
                    end
                elseif event.type == "update" then
                    local deltaTime = event.deltaTime
                    state.time = state.time + event.deltaTime

                    local move = state.move:normalize()
                    move.x = move.x * deltaTime * 50
                    move.y = move.y * deltaTime * 50
                    state.player.position = state.player.position:add(move)

                elseif event.type == "draw" then
                    local graphics = love.graphics
                    graphics.setCanvas(state.gameView)
                    graphics.clear(0.3, 0.0, 0.3, 1.0, true, true)
                    graphics.setColor(1, 1, 1, 1)
                    local x = 1 + ((state.time * 6) % 4)
                    local y = cpml.vec2.new(state.move.y, state.move.x):normalize():angle_to(cpml.vec2.new(0, 1)) / math.pi * 8 * -1
                    local sprite = math.floor(x + y * 6)
                    graphics.draw(state.player.sprites.image, state.player.sprites.quads[sprite])
                    graphics.setCanvas()
                    graphics.draw(state.gameView, 0, 0, 0, state.scaleFactor, state.scaleFactor)
                end

                return state
            end,
        }
    end,
}
