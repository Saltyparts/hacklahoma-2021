return {
    new = function(path, width, height)
        local image = love.graphics.newImage(path)
        local spritesheet = {
            image = image,
            quads = {},
        }

        for y = 0, image:getHeight() - height, height do
            for x = 0, image:getWidth() - width, width do
                table.insert(spritesheet.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
            end
        end

        return spritesheet
    end,
}
