-- update to comms_statton that uses the friendlyness comms_data variable
-- to decide what can be bought
--
require("utils.lua")

function mainMenu()
    if comms_target.comms_data == nil then
        comms_target.comms_data = {}
    end
    mergeTables(comms_target.comms_data, {
        friendlyness = random(0.0, 100.0),
        stock = { -- keep track of stock
            Homing = 50,
            HVLI = 100,
            Mine = 50,
            Nuke = 25,
            EMP = 25
        },
        weapons = { -- required friendlyness (if neutral)
            Homing = 50,
            HVLI = 50,
            Mine = 50,
            Nuke = 50,
            EMP = 50
        },
        weapon_cost = {
            Homing = 12,
            HVLI = 8,
            Mine = 14,
            Nuke = 80,
            EMP = 25
        },
        services = {
            supplydrop = 75,
            reinforcements = 90,
        },
        service_cost = {
            supplydrop = 120,
            reinforcements = 150,
        }
    })
    comms_data = comms_target.comms_data

    if player:isEnemy(comms_target) then
        return false
    end

    if comms_target:areEnemiesInRange(5000) then
        setCommsMessage("Station is under attack! Please assist us "..player:getCallSign()..", "..comms_target:getCallSign().." out.");
        return true
    end
    if not player:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end

function handleDockedState()
    -- Handle communications while docked with this station.
    if player:isFriendly(comms_target) or (comms_target.comms_data.friendlyness > 50 and not player:isEnemy(comms_target)) then
        setCommsMessage("Welcome "..player:getCallSign()..", what can we do for you today?")
    else
        setCommsMessage("Hello "..player:getCallSign()..", what are you doing here?")
    end

    if player:getWeaponStorageMax("Homing") > 0 then
        addCommsReply("Do you have spare homing missiles for us? ("..getWeaponCost("Homing").."rep each)", function()
            handleWeaponRestock("Homing")
        end)
    end
    if player:getWeaponStorageMax("HVLI") > 0 then
        addCommsReply("Can you restock us with HVLI? ("..getWeaponCost("HVLI").."rep each)", function()
            handleWeaponRestock("HVLI")
        end)
    end
    if player:getWeaponStorageMax("Mine") > 0 then
        addCommsReply("Please re-stock our mines. ("..getWeaponCost("Mine").."rep each)", function()
            handleWeaponRestock("Mine")
        end)
    end
    if player:getWeaponStorageMax("Nuke") > 0 then
        addCommsReply("Can you supply us with some nukes? ("..getWeaponCost("Nuke").."rep each)", function()
            handleWeaponRestock("Nuke")
        end)
    end
    if player:getWeaponStorageMax("EMP") > 0 then
        addCommsReply("Please re-stock our EMP missiles. ("..getWeaponCost("EMP").."rep each)", function()
            handleWeaponRestock("EMP")
        end)
    end
end

function handleWeaponRestock(weapon)
    if not player:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        setCommsMessage("We don't have any of those for you"..player:getCallSign()..".")
        return
    end
    local stock = getWeaponStock(weapon)
    if stock <= 0 then
        setCommsMessage("We don't have any of those in stock "..player:getCallSign()..".")
        return
    end

    local points_per_item = getWeaponCost(weapon)
    local item_amount = player:getWeaponStorageMax(weapon) - player:getWeaponStorage(weapon)

    if item_amount > stock then
        item_amount = stock
    end

    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage("All nukes are charged and primed for destruction.");
        else
            setCommsMessage("Sorry, sir, but you are as fully stocked as I can allow.");
        end
        addCommsReply("Back", mainMenu)
    else
        if not player:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage("Not enough reputation.")
            return
        end
        player:setWeaponStorage(weapon, player:getWeaponStorage(weapon) + item_amount)

        useWeaponStock(weapon, item_amount)

        if player:getWeaponStorage(weapon) == player:getWeaponStorageMax(weapon) then
            setCommsMessage("You are fully loaded and ready to explode things.")
        else
            setCommsMessage("We generously resupplied you with some weapon charges.\nPut them to good use.")
        end
        addCommsReply("Back", mainMenu)
    end
end

function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if player:isFriendly(comms_target) or (comms_target.comms_data.friendlyness > 50 and not player:isEnemy(comms_target)) then
        local message = "Good day "..player:getCallSign()..[[, if you need supplies please dock with us and we'll do our best.

Here is our inventory.

]]
        for weapon_stock_key, weapon_stock_value in pairs(comms_target.comms_data['stock']) do
            if (weapon_stock_value > 0) then
                message = message..weapon_stock_key..": "..weapon_stock_value.."\n"
            end
        end

        setCommsMessage(message)
    else
        setCommsMessage("Good day "..player:getCallSign()..", if you want to do business please dock with us first.")
    end

    addCommsReply("Can you send a supply drop? ("..getServiceCost("supplydrop").."rep)", function()
        if isAllowedTo(comms_target.comms_data['services']['supplydrop']) then
            if player:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request backup.");
            else
                setCommsMessage("To which waypoint should we deliver your supplies?");
                for n=1,player:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if player:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = player:getWaypoint(n)
                            local script = Script()
                            script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                            script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                            script:setVariable("player_faction_id", player:getFactionId())
                            script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                            useWeaponStock("Nuke", 1)
                            useWeaponStock("Homing", 4)
                            useWeaponStock("Mine", 2)
                            useWeaponStock("EMP", 1)
                            setCommsMessage("We have dispatched a supply ship toward WP" .. n);
                        else
                            setCommsMessage("Not enough reputation!");
                        end
                        addCommsReply("Back", mainMenu)
                    end)
                end
            end
        else
            setCommsMessage("We've heard about your operations against independent traders "..player:getCallSign()..", you'll get no help from us.");
        end
        addCommsReply("Back", mainMenu)
    end)

    addCommsReply("Please send reinforcements! ("..getServiceCost("reinforcements").."rep)", function()
        if isAllowedTo(comms_target.comms_data['services']['reinforcements']) then
            if player:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,player:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if player:takeReputationPoints(getServiceCost("reinforcements")) then
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
                            setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
                        else
                            setCommsMessage("Not enough reputation!");
                        end
                        addCommsReply("Back", mainMenu)
                    end)
                end
            end
        else
            setCommsMessage("We've heard about your operations against independent traders "..player:getCallSign()..", you'll get no help from us.");
        end
        addCommsReply("Back", mainMenu)
    end)

end

function isAllowedTo(required_friendlyness)
    if player:isFriendly(comms_target) and comms_target.comms_data['friendlyness'] >= 10 then
        return true
    end
    if (not player:isEnemy(comms_target)) and comms_target.comms_data['friendlyness'] >= required_friendlyness then
        return true
    end
    return false
end

-- Return the number of reputation points that a specified weapon costs for the
-- current player.
function getWeaponCost(weapon)
    return comms_data['weapon_cost'][weapon]
end

-- Return the number of the weapon left at the station
function getWeaponStock(weapon)
    return comms_data['stock'][weapon]
end

-- use some weapons from stock
function useWeaponStock(weapon, used)
    comms_data['stock'][weapon] = comms_data['stock'][weapon] - used
    if (comms_data['stock'][weapon] < 0) then
        comms_data['stock'][weapon] = 0
    end
end

-- Return the number of reputation points that a specified service costs for
-- the current player.
function getServiceCost(service)
    return math.ceil(comms_data['service_cost'][service])
end

mainMenu()
