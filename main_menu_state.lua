local lobbyState = require 'lobby_state'

return {
    new = function()
        return {
            buttons = {
                "play",
                "quit",
            },
            cursor = 1,
            transform = function(state, event)
                if event.type == "input" and event.kind == "button" then
                    if event.specifier == "down" and event.value == "pressed" then state.cursor = (state.cursor % #state.buttons) + 1
                    elseif event.specifier == "up" and event.value == "pressed" then state.cursor = ((state.cursor - 2) % #state.buttons) + 1
                    elseif event.specifier == "accept" and event.value == "pressed" then
                        if state.buttons[state.cursor] == "play" then return lobbyState.new()
                        elseif state.buttons[state.cursor] == "quit" then love.event.quit(0)
                        end
                    end
                elseif event.type == "draw" then
                    local graphics = love.graphics
                    graphics.clear(0, 0, 0, 1)
                    for i = 1, #state.buttons do
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
