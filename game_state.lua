local cpml = require 'cpml-master'
local spritesheet = require 'spritesheet'

local scaleFactor = 3

function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

function round(num)
    local mult = 10 ^ 0
    return math.floor(num * mult + 0.5) / mult
end

function colliding(map, x, y, width, height)
    local colliding = 0
    for x = x, x + width, 16 do
        for y = y, y + height, 16 do
            if map[4][1 + math.floor(x / 16) + map.width * math.floor(y / 16)] == 1 then return true end
        end
    end
    return false
end

function newPlayer()
    return {
        input = cpml.vec2.new(0, 0),
        inputDeadzone = 0.26,
        position = cpml.vec2.new(0, 0),
        velocity = cpml.vec2.new(0, 0),
        speed = 100,
        sprites = spritesheet.new("content/player.png", 32, 40),
        lastFacingDirection = 2,
        collider = { 
            width = 16, height = 8,
            x = 8, y = 34
        },

        transform = function(player, event, map)
            if event.type == "input" then
                if event.kind == "axis" then
                    if math.abs(event.value) <= player.inputDeadzone then event.value = 0 end
                    if event.specifier == "horizontal" then player.input.x = event.value
                    elseif event.specifier == "vertical" then player.input.y = event.value
                    end
                elseif event.kind == "button" then
                    if event.specifier == "left" and event.value == "pressed" then player.input.x = player.input.x - 1
                    elseif event.specifier == "left" and event.value == "released" then player.input.x = player.input.x + 1
                    elseif event.specifier == "right" and event.value == "pressed" then player.input.x = player.input.x + 1
                    elseif event.specifier == "right" and event.value == "released" then player.input.x = player.input.x - 1
                    elseif event.specifier == "down" and event.value == "pressed" then player.input.y = player.input.y + 1
                    elseif event.specifier == "down" and event.value == "released" then player.input.y = player.input.y - 1
                    elseif event.specifier == "up" and event.value == "pressed" then player.input.y = player.input.y - 1
                    elseif event.specifier == "up" and event.value == "released" then player.input.y = player.input.y + 1
                    end
                end
            elseif event.type == "update" then
                local deltaTime = event.deltaTime

                player.velocity = player.input:trim(1):scale(player.speed * deltaTime)

                if colliding(
                    map,
                    math.floor(player.position.x) + player.collider.x,
                    math.floor(player.position.y + player.velocity.y) + player.collider.y,
                    player.collider.width,
                    player.collider.height
                ) == true then
                    while colliding(
                        map,
                        math.floor(player.position.x) + player.collider.x,
                        math.floor(player.position.y + sign(player.velocity.y)) + player.collider.y,
                        player.collider.width,
                        player.collider.height
                    ) == false do player.position.y = player.position.y + sign(player.velocity.y) end
                else player.position.y = player.position.y + player.velocity.y end

                if colliding(
                    map,
                    math.floor(player.position.x + player.velocity.x) + player.collider.x,
                    math.floor(player.position.y) + player.collider.y,
                    player.collider.width,
                    player.collider.height
                ) == true then
                    while colliding(
                        map,
                        math.floor(player.position.x + sign(player.velocity.x)) + player.collider.x,
                        math.floor(player.position.y) + player.collider.y,
                        player.collider.width,
                        player.collider.height
                    ) == false do player.position.x = player.position.x + sign(player.velocity.x) end
                else player.position.x = player.position.x + player.velocity.x end
            elseif event.type == "draw" then
                local time = event.time
                local graphics = love.graphics

                graphics.setColor(1, 1, 1, 1)
                local sprite = nil
                local x = 0
                local y = 0
                local angle = round(math.atan2(player.input.y, player.input.x) / math.pi * 4)
                if angle == 0 then y = 0
                elseif angle == -1 then y = 1
                elseif angle == -2 then y = 2
                elseif angle == -3 then y = 3
                elseif angle == 4 then y = 4
                elseif angle == 3 then y = 5
                elseif angle == 2 then y = 6
                elseif angle == 1 then y = 7
                end

                if player.input:len() > 0.85 then
                    x = math.floor(1 + ((time * 8) % 6))
                    player.lastFacingDirection = 2 + y * 6
                    y = y + 8
                    sprite = x + y * 6
                elseif player.input:len() > player.inputDeadzone then 
                    x = math.floor(1 + ((time * 8) % 4))
                    player.lastFacingDirection = 2 + y * 6
                    sprite = x + y * 6
                else sprite =  player.lastFacingDirection
                end

                graphics.draw(
                    player.sprites.image,
                    player.sprites.quads[sprite],
                    math.floor(player.position.x),
                    math.floor(player.position.y)
                )
            end
        end,
    }
end

return {
    new = function(players)
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
                    { 120, 200 },
                    { 80, 170 },
                    { 160, 160 },
                    { 160, 80 },
                },
                spritesheet = spritesheet.new("content/tileset.png", 16, 16),
                width = 30,
            },
            players = {},
            time = 0,
            gameView = love.graphics.newCanvas(),
            camera = {
                position = cpml.vec2.new(),
            },
            transform = function(state, event)
                if event.type == "input" then
                    if state.players[event.device] then state.players[event.device]:transform(event) end
                elseif event.type == "update" then
                    local deltaTime = event.deltaTime
                    state.time = state.time + event.deltaTime
                    for i, player in pairs(state.players) do player:transform(event, state.map) end
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

                    local drawOrder = {}
                    for i, player in pairs(state.players) do
                        table.insert(drawOrder, player)
                    end
                    table.sort(drawOrder, function(left, right)
                            return left.position.y < right.position.y
                        end
                    )

                    for i = 1, #drawOrder do
                        drawOrder[i]:transform(event, state.map)
                    end

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

        for i = 1, #players do
            if players[i] ~= "not connected" then
                state.players[players[i]] = newPlayer()
                state.players[players[i]].position = cpml.vec2.new(state.map.spawnpoints[i][1], state.map.spawnpoints[i][2])
            end
        end

        local delay = 2
        local lastOcc = -delay
        local timeElapsed = os.time() - lastOcc
            if timeElapsed > lastOcc then
            for i = 1, 4 do
                local map = state.map
                local footstepsPath = love.audio.newSource("content/gravel_footsteps.wav", "static")
                local footstepsGrass = love.audio.newSource("content/footstep.wav", "static")
                if map[1][tile] == 33 then love.audio.play(footstepsPath)
                elseif map[1][tile] == 42 then love.audio.play(footstepsPath)
                else love.audio.play(footstepsGrass)
                end
            end
        end


        local backgroundMusic = love.audio.newSource("content/music.wav", "stream")
        backgroundMusic:setVolume(0.5)
        love.audio.play(backgroundMusic)
        
        return state
    end

}
