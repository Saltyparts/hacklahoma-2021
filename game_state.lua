local cpml = require 'cpml-master'
local spritesheet = require 'spritesheet'

local scaleFactor = 3

function newPlayer()
    return {
        input = cpml.vec2.new(0, 0),
        inputDeadzone = 0.26,
        position = cpml.vec2.new(0, 0),
        speed = 80,
        sprites = spritesheet.new("content/player.png", 32, 40),
        lastFacingDirection = 2,
        collider = { 
            width = 16, height = 8,
            x = 8, y = 32
        },

        transform = function(player, event, map)
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

                player.position = player.position:add(player.input:scale(player.speed * deltaTime))
                player.position.x = math.max(-player.collider.x, player.position.x)
                player.position.y = math.max(-love.graphics.getHeight() / scaleFactor + player.collider.height + player.collider.y, player.position.y)
                player.position.x = math.min(love.graphics.getWidth() / scaleFactor - player.collider.width - player.collider.x, player.position.x)
                player.position.y = math.min(player.collider.y, player.position.y)

                local colliding = false
                for x = math.floor(player.position.x) + player.collider.x, math.floor(player.position.x) + player.collider.x + player.collider.width, 16 do
                    for y = math.floor(-player.position.y) + player.collider.y, math.floor(-player.position.y) + player.collider.y + player.collider.height, 16 do
                        print(map[4][1 + math.floor(x / 16) + map.width * math.floor(y / 16)])
                    end
                end
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
        local state = {
            scaleFactor = 3,
            map = {
                {
                    1, 1, 259, 260, 259, 259, 260, 259, 259, 259, 260, 260, 260, 259, 259, 260, 259, 260, 259, 260, 259, 259, 260, 260, 259, 259, 260, 260, 1, 1,
                    1, 261, 262, 324, 324, 324, 356, 324, 324, 324, 324, 355, 324, 324, 324, 324, 355, 356, 324, 324, 324, 324, 356, 324, 324, 356, 324, 257, 258, 196,
                    195, 293, 294, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 289, 290, 196,
                    227, 325, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 322, 196,
                    195, 1, 1, 258, 259, 260, 261, 1, 1, 1, 39, 37, 37, 37, 37, 37, 37, 37, 40, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 196,
                    227, 1, 1, 290, 291, 292, 293, 1, 1, 39, 34, 33, 33, 33, 33, 33, 33, 33, 35, 40, 1, 1, 1, 1, 1, 1, 1, 1, 1, 196,
                    227, 1, 1, 322, 323, 324, 325, 1, 39, 34, 33, 33, 33, 33, 33, 33, 33, 33, 33, 35, 40, 1, 1, 1, 1, 1, 1, 1, 1, 196,
                    195, 1, 1, 1, 1, 1, 1, 1, 42, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 70, 1, 1, 1, 1, 1, 1, 1, 1, 196,
                    227, 1, 1, 1, 1, 1, 1, 1, 42, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 70, 1, 1, 1, 1, 1, 1, 1, 1, 196,
                    227, 1, 1, 1, 1, 1, 1, 1, 42, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 70, 1, 1, 1, 1, 1, 1, 1, 1, 196,
                    195, 1, 1, 1, 1, 1, 1, 1, 42, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 70, 1, 1, 1, 1, 1, 1, 1, 1, 196,
                    227, 1, 1, 1, 1, 1, 1, 1, 42, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 67, 72, 1, 1, 1, 1, 1, 1, 1, 1, 196,
                    195, 1, 1, 1, 1, 1, 1, 1, 71, 66, 33, 33, 33, 33, 33, 33, 33, 33, 67, 72, 258, 1, 1, 1, 1, 230, 1, 1, 1, 196,
                    227, 1, 1, 1, 1, 1, 1, 1, 1, 71, 73, 77, 69, 69, 69, 77, 69, 69, 72, 1, 290, 258, 259, 260, 261, 262, 1, 1, 1, 196,
                    195, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 322, 290, 291, 292, 293, 294, 1, 1, 1, 196,
                    227, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 322, 323, 324, 325, 1, 1, 1, 1, 196,
                    258, 260, 259, 260, 260, 259, 260, 259, 260, 260, 259, 260, 259, 260, 259, 260, 260, 260, 259, 259, 259, 260, 260, 259, 259, 260, 259, 259, 260, 261,
                    290, 292, 291, 292, 292, 291, 292, 291, 292, 292, 291, 292, 291, 292, 291, 292, 292, 292, 291, 291, 291, 292, 291, 291, 291, 292, 291, 291, 292, 262,
                },
                {
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 241, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 179, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 179, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 242, 0, 14, 0, 13, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 209, 0, 0, 274, 13, 0, 0, 0, 0,
                    0, 0, 242, 0, 0, 209, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 10, 14, 0,
                    0, 0, 274, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 209,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 179, 0,
                    0, 0, 179, 0, 0, 0, 0, 241, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 179, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 209, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 242, 0, 0, 0, 0, 13, 13, 11, 14, 0, 0, 0, 177, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                },
                {
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 162, 164, 164, 165, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 195, 1, 1, 196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 225, 259, 260, 261, 153, 156, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 153, 0, 0, 156, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 162, 164, 164, 165, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 162, 1, 43, 45, 1, 198, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 195, 1, 46, 33, 74, 196, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 195, 1, 38, 33, 74, 196, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 195, 1, 75, 77, 72, 196, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 230, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 260, 261, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 156, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                },
                {
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
                    1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
                    1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                },
                spawnpoints = {
                    { 80, -160 },
                    { 80, -170 },
                    { 160, -160 },
                    { 160, -80 },
                },
                spritesheet = spritesheet.new("content/tileset.png", 16, 16),
                width = 30,
            },
            time = 0,
            gameView = love.graphics.newCanvas(),
            players = {
                newPlayer(),
                newPlayer(),
                newPlayer(),
                newPlayer(),
            },
            camera = {
                position = cpml.vec2.new(),
            },
            transform = function(state, event)
                if event.type == "input" then
                    state.players[1]:transform(event)
                elseif event.type == "update" then
                    local deltaTime = event.deltaTime
                    state.time = state.time + event.deltaTime
                    state.players[1]:transform(event, state.map)
                    --for i = 1, #state.players do state.players[i]:transform(event, state.map) end 
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

                    for i = 1, #state.players do state.players[i]:transform(event) end 

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

        for i = 1, #state.players do
            state.players[i].position = cpml.vec2.new(state.map.spawnpoints[i][1], state.map.spawnpoints[i][2])
        end

        local delay = 2
        local lastOcc = -delay
        local timeElapsed = os.time() - lastOcc
            if timeElapsed > lastOcc then
            for i = 1, 4 do
                local map = state.map
                local footstepsPath = love.audio.newSource("gravel_footsteps.wav", "static")
                local footstepsGrass = love.audio.newSource("Footstep.wav", "static")
                local xcord = state.players[i].position.x % 16
                local ycord = state.players[i].position.y % 16
                local tile = xcord + ( 32 * (ycord % 16))
                if map[1][tile] == 33 then love.audio.play(footstepsPath)
                elseif map[1][tile] == 42 then love.audio.play(footstepsPath)
                else love.audio.play(footstepsGrass)
                end
            end
        end


        local backgroundMusic = love.audio.newSource("Music.wav", "static")
        love.audio.play(backgroundMusic)
        
        return state
    end

}
