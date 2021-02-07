local gameState = require 'game_state'

return {
    new = function()
        return {
            inputDevices = { "not connected", "not connected", "not connected", "not connected" },

            transform = function(state, event)
                if event.type == "input" and event.kind == "button" then
                    if event.specifier == "accept" and event.value == "pressed" then
                        for i = 1, #state.inputDevices do
                            if state.inputDevices[i] == event.device then return gameState.new(state.inputDevices)
                            elseif state.inputDevices[i] == "not connected" then
                                state.inputDevices[i] = event.device
                                break
                            end
                        end
                    elseif event.specifier == "cancel" and event.value == "pressed" then
                        for i = 1, #state.inputDevices do
                            if state.inputDevices[i] == event.device then state.inputDevices[i] = "not connected" end
                        end
                    end
                elseif event.type == "draw" then
                    local graphics = love.graphics
                    graphics.clear(0, 0, 0, 1)
                    graphics.setColor(0.95, 0.95, 0.95, 1)
                    for i = 1, #state.inputDevices do
                        graphics.print(state.inputDevices[i], 20, (i - 1) * 30 + 20)
                    end
                end

                return state
            end
        }
    end
}
