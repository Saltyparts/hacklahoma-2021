local gameState = require 'game_state'

return {
    new = function()
        return {
            inputDevices = { nil, nil, nil, nil },

            transform = function(state, event)
                if event.type == "input" then
                    local button = event.button
                    local buttonState = event.state
                    if button == "accept" and buttonState == "pressed" then
                        for i = 1, 4 do
                            if state.inputDevices[i] == "keyboard" then return gameState.new()
                            elseif state.inputDevices[i] == nil then state.inputDevices[i] = "keyboard"
                                print("Player is connected")
                                break
                            else 
                                print("Lobby is full")
                            end
                        end
                    end

                    if button == "cancelled" and buttonState == "pressed" then
                        for i = 1, 4 do
                            if state.inputDevices[i] == "keyboard" then state.inputDevices[i] = nil
                            end
                        end
                    end
                elseif event.type == "joystick" then
                    if button == "accept" and buttonState == "pressed" then
                        for i = 1, 4 do
                            if state.inputDevices[i] == eventType.joystick:getGUID() then return gameState.new()
                            elseif state.inputDevices[i] == nil then state.inputDevices[i] = eventType.joystick:getGUID()
                                break
                            else
                                print("Lobby is full")
                            end
                        end
                    end
                elseif event.type == "draw" then
                    local graphics = love.graphics
                    graphics.setColor(0.95, 0.95, 0.95, 1)
                    for i = 1, 4 do
                        if state.inputDevices[i] == nil then graphics.print("Not connected", 100)
                        else graphics.print(state.inputDevices[i], 100, (i - 1) * 30 + 20)
                        end
                    end
                end

                return state
            end
        }
    end
}