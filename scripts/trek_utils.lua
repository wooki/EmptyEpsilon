require("delays.lua")

-- message players with mission specific info, also add to ship log
function missionMessage(players, delaytimers, message_id, message)

  -- delay mission messages
  addDelayedCallback(delaytimers, message_id, 5, function()

    for player_ship_keys, player_ship in ipairs(players) do

    if (player_ship:hasPlayerAtPosition("Relay")) then
      playSoundFile("chirp.ogg")
      player_ship:addCustomMessage("Relay",message_id, message)
      player_ship:addToShipLog("[STARFLEET COMMAND] "..message, "Yellow")
    elseif (player_ship:hasPlayerAtPosition("Operations")) then
      playSoundFile("chirp.ogg")
      player_ship:addCustomMessage("Operations",message_id, message)
      player_ship:addToShipLog("[STARFLEET COMMAND] "..message, "Yellow")
    elseif (player_ship:hasPlayerAtPosition("single")) then
      playSoundFile("chirp.ogg")
      player_ship:addCustomMessage("Single",message_id, message)
      player_ship:addToShipLog("[STARFLEET COMMAND] "..message, "Yellow")
    else
      addDelayedCallback(delaytimers, message_id .. '-delayed', 5, function()
        missionMessage(players, delaytimers, message_id, message)
      end)
    end

  end

  end)

end


function endGameMessage(delaytimers, message, victors)

  globalMessage(message)

  addDelayedCallback(delaytimers, "endgameMessage", 10, function()
    victory(victors)
  end)

end