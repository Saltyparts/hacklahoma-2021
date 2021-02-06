local gameState = require 'game_state'

return {
    new = function()
        return {
            buttons = {
                "new game",
                "load game",
                "options",
                "quit",
            },
            cursor = 1,
            transform = function(state, event)
                if event.type == "input" then
                    local button = event.button
                    local buttonState = event.state
                    if button == "down" and buttonState == "pressed" then state.cursor = (state.cursor % #state.buttons) + 1
                    elseif button == "up" and buttonState == "pressed" then state.cursor = ((state.cursor - 2) % #state.buttons) + 1
                    elseif button == "accept" and buttonState == "pressed" then
                        if state.buttons[state.cursor] == "new game" then return gameState.new() end
                    end
                elseif event.type == "draw" then
                    local graphics = love.graphics
                    for i=1, #state.buttons do
                        if i == state.cursor then graphics.setColor(0.95, 0.95, 0.95, 1)
                        else graphics.setColor(0.5, 0.5, 0.5, 1)
                        end
                        graphics.print(state.buttons[i], 20, (i - 1) * 30 + 20)
                    end
                end

                return state
            end,
        }
    end,
}
