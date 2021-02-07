local gameState = require 'game_state'

return {
    new = function()
        return {
            inputDevices = { "not connected", "not connected", "not connected", "not connected" },

            transform = function(state, event)
                if event.type == "input" then
                    local button = event.button
                    local buttonState = event.state
                    if button == "accept" and buttonState == "pressed" then
                        for i = 1, 4 do
                            if state.inputDevices[i] == "keyboard" then return gameState.new()
                            elseif state.inputDevices[i] == "not connected" then state.inputDevices[i] = "keyboard"
                                print("Player is connected")
                                break
                            else 
                                print("Lobby is full")
                            end
                        end
                    end

                    if button == "cancelled" and buttonState == "pressed" then
                        for i = 1, 4 do
                            if state.inputDevices[i] == "keyboard" then state.inputDevices[i] = "not connected"
                            end
                        end
                    end
                elseif event.type == "joystick" then
                    if button == "accept" and buttonState == "pressed" then
                        for i = 1, 4 do
                            if state.inputDevices[i] == eventType.joystick:getGUID() then return gameState.new()
                            elseif state.inputDevices[i] == "not connected" then state.inputDevices[i] = eventType.joystick:getGUID()
                                break
                            else
                                print("Lobby is full")
                            end
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