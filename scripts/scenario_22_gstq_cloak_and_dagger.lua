-- Name: Galaxy Space Trek Quest - Cloak & Dagger
-- Description: Hunt down and destroy a cloaked Klingon ship
-- Type: Mission
-- Variation[1 Galaxy Class]: Galaxy Class
-- Variation[1 Constitution Class]: Constitution Class
-- Variation[1 Defiant Class]: Defiant Class

-- also requires star trek mod, along with custom ships, custom faction file and added sound effects etc.
require("utils.lua")
require("more_utils.lua")
require("delays.lua")
require("trek_utils.lua")

timers = {}
players = {}
klingon_trace = {}
klingon_position = nil
mission_state = "search"
klingon = nil

player_ship_names = shuffle({
  "Agamemnon",
  "Prometheus",
  "Theseus",
  "Perseus",
  "Achilles",
  "Hercules",
  "Odysseus",
  "Orpheus"
})

function addNukesToPlayer(player, shipClass)
  if shipClass == "Constitution Refit" then
    player:setWeaponStorage("Nuke", 0)
    player:setWeaponStorageMax("Nuke", 1)
  elseif shipClass == "Galaxy Class" then
    player:setWeaponStorage("Nuke", 2)
    player:setWeaponStorageMax("Nuke", 4)
  elseif shipClass == "Defiant Class" then
    player:setWeaponStorage("Nuke", 0)
    player:setWeaponStorageMax("Nuke", 0)
  end
end

function map()

    for i=1,10 do
    	placeRandomAroundPoint(Asteroid, math.floor(random(2, 12)), 1000, 6000, random(-140000, 140000), random(-140000, 140000))
    	placeRandomAroundPoint(VisualAsteroid, math.floor(random(2, 12)), 1000, 6000, random(-140000, 140000), random(-140000, 140000))
    end

  placeRandomObjects(Asteroid, 20, 0.3, 0, 0, 14, 14)
  placeRandomObjects(VisualAsteroid, 20, 0.3, 0, 0, 14, 14)
  placeRandomObjects(Nebula, 15, 0.22, 0, 0, 14, 14)


end

function nextStep(step, current_x, current_y)

	-- dummy object to get sector name
	local marker = Artifact():setPosition(current_x, current_y):setModel("artifact3"):allowPickup(false)
	local sector = marker:getSectorName()
	marker:destroy()

	local r = irandom(0, 100)
	local left_chance = 20
	local right_chance = 20
	local angle = 30

	-- if we're close to the edge (or middle) and heading towards that edge make turning more likely

	-- turn away from edges
	if klingon_course > 270 and current_x > 110000 then
		left_chance = 90
		right_chance = 0
		angle = 30
	elseif klingon_course < 90 and current_x > 110000 then
		left_chance = 0
		right_chance= 90
		angle = 30
	elseif klingon_course >= 180 and klingon_course < 270 and current_x < -110000 then
		left_chance = 0
		right_chance= 90
		angle = 30
	elseif klingon_course <= 180 and klingon_course > 90 and current_x < -110000 then
		left_chance = 90
		right_chance = 0
		angle = 30
	elseif klingon_course > 270 and current_y < -110000 then
		left_chance = 0
		right_chance= 90
		angle = 30
	elseif klingon_course > 180 and klingon_course <= 270 and current_y < -110000 then
		left_chance = 90
		right_chance = 0
		angle = 30
	elseif klingon_course > 0 and klingon_course <= 90 and current_y > 110000 then
		left_chance = 90
		right_chance = 0
		angle = 30
	elseif klingon_course > 90 and klingon_course <= 180 and current_y > 110000 then
		left_chance = 0
		right_chance= 90
		angle = 30
	end

	-- turn away from central area
	if current_x > -50000 and current_x < 50000 and current_y > -50000 and current_y < 50000 then
		if klingon_course >= 270 then
			if current_y >= 0 and current_x <= 0 then
				left_chance = 50
				right_chance = 50
				angle = 180
			elseif current_y >= 0 then
				left_chance = 0
				right_chance = 100
			elseif current_x <= 0 then
				left_chance = 100
				right_chance = 0
			end
		elseif klingon_course <= 90 then
			if current_y <= 0 and current_x <= 0 then
				left_chance = 50
				right_chance = 50
				angle = 180
			elseif current_y <= 0 then
				left_chance = 100
				right_chance = 0
			elseif current_x <= 0 then
				left_chance = 0
				right_chance = 100
			end
		elseif klingon_course >= 180 and klingon_course <= 270 and current_y >= 0 then
			if current_y >= 0 and current_x >= 0 then
				left_chance = 50
				right_chance = 50
				angle = 180
			elseif current_y >= 0 then
				left_chance = 100
				right_chance = 0
			elseif current_x >= 0 then
				left_chance = 0
				right_chance = 100
			end
		elseif klingon_course <= 180 and klingon_course >= 90 and current_x >= 0 and current_y <= 0 then
			if current_y <= 0 and current_x >= 0 then
				left_chance = 50
				right_chance = 50
				angle = 180
			elseif current_y <= 0 then
				left_chance = 0
				right_chance = 100
			elseif current_x >= 0 then
				left_chance = 100
				right_chance = 0
			end
		end
	end

	if r > (100 - right_chance) then
		klingon_course = (klingon_course + angle) % 360
	elseif r > (100 - (left_chance + right_chance)) then
		klingon_course = (klingon_course - angle) % 360
	end

	local next_x, next_y = vectorFromAngle(klingon_course, 15000)
	next_x = math.floor(next_x)
	next_y = math.floor(next_y)

	if step == 0 then
		klingon_position = sector
		return 0, current_x + next_x, current_y + next_y
	else
		klingon_trace[sector] = math.floor((31 - step) * (random(9, 10))) / 500
		return nextStep(step - 1, current_x + next_x, current_y + next_y)
	end
end

function chargeDecloak()

	-- check shields are zero power
	local shield_power = player_ship:getSystemPower("frontshield") + player_ship:getSystemPower("rearshield")
	if shield_power <= 0 then

		-- check we have 250 power
		if player_ship:getEnergyLevel() >= 250 then

			-- take 250 power
			player_ship:setEnergyLevel(player_ship:getEnergyLevel() - 250)

			-- remove button, add charging info
			player_ship:removeCustom("decloak-charge")
			player_ship:addCustomInfo("Weapons", "decloak-charging", "Shield Emitters Charging")

			-- after recharge delay, remove info and add Tachyon Pule button
			addDelayedCallback(timers, "decloak-charging", irandom(15, 25), function()

				local shield_power = player_ship:getSystemPower("frontshield") + player_ship:getSystemPower("rearshield")
				if shield_power <= 0 then

					player_ship:removeCustom("decloak-charging")
					player_ship:addCustomButton("Weapons", "decloak-fire", "Tachyon Pulse", function()
						decloak()
					end)
				else
					player_ship:addCustomMessage("Weapons", "shields-still-powered", [[Charging failed because the shields have not been drained of all power.]])
				end
			end)

		else
			player_ship:addCustomMessage("Weapons", "shields-no-power", [[Your ship does not have the required 250 energy to divert to the shield emitters.]])
		end
	else
		-- shield power > 0
		player_ship:addCustomMessage("Weapons", "shields-still-powered", [[You cannot charge the Tachyon pulse until the shields have been drained of all power.

Speak to your chief engineer.]])
	end

end

function decloak()

	-- remove the button, add charge button
	player_ship:removeCustom("decloak-fire")
	player_ship:addCustomButton("Weapons", "decloak-charge", "Charge Shield Emitters", function()
		chargeDecloak()
	end)

	-- check if the player is in the the klingon_position sector
	local player_sector = player_ship:getSectorName()
	local player_x, player_y = player_ship:getPosition()
	if player_sector == klingon_position then
		mission_state = "klingon"

		-- if so create bird of prey and attack player!
		-- work out 5k behind player and angle towards player!
		playSoundFile("decloak.ogg")
		local player_x, player_y = player_ship:getPosition()
		local player_heading = player_ship:getHeading()
		local behind_heading = (player_heading + 180) % 360
		local ky, kx = vectorFromAngle(behind_heading, 5000)
		klingon = CpuShip():setFaction("Klingons"):setTemplate("Klingon Bird Of Prey"):setJumpDrive(true)
		klingon:setPosition(player_x + kx, player_y - ky):setHeading(player_heading):setHullMax(120):setHull(120):setShieldsMax(200, 40):setShields(0, 0)
		klingon:setWeaponStorageMax("Nuke", 2):setWeaponStorage("Nuke", 2)
		klingon:orderAttack(player_ship):setCallSign("Vo'taq")

	end

end

function init()

	map()

	-- player ship
	shipClass = "Constitution Refit"
	if (getScenarioVariation() == "1 Galaxy Class") then
		shipClass = "Galaxy Class"
	elseif (getScenarioVariation() == "1 Defiant Class") then
	    shipClass = "Defiant Class"
	end
	player_ship_names_index = 1
	player_ship = PlayerSpaceship():setFaction("Starfleet"):setTemplate(shipClass):setHeading(irandom(0, 360)):setCallSign(player_ship_names[player_ship_names_index])
	player_ship:setPosition(10000, 10000)
	addNukesToPlayer(player_ship, shipClass)
	table.insert(players, player_ship)

	-- add button to weapons to charge decloak device (must have shields with zero power)
	player_ship:addCustomButton("Weapons", "decloak-charge", "Charge Shield Emitters", function()
		chargeDecloak()
	end)
	addDelayedCallback(timers, "brief-weapons", 5, function()
		player_ship:addCustomMessage("Weapons", "brief-weapons", [[Your shield emitters have been configured to send out a powerful Tachyon pulse which we believe will decloak any nearby vessels.

Shield power must be diverted away before you can charge the emitters.]])
	end)
	addDelayedCallback(timers, "brief-science", 5, function()
		player_ship:addCustomMessage("Science", "brief-science", [[Our sensors have been tuned to detect the Tetryon radiation that a cloaked vessel leaves behind.

Our scientists speculate that the radiation develops sometime after the cloaked vessel has left and then decays slowly. A ship containing will likely return a zero reading.

Access using the <Scanning> button on the right.]])
	end)

	-- start the Mission
	missionMessage(players, timers, 'mission-start', [[Starfleet command has had reports of a cloaked Klingon vessel ambushing ships in this sector.

Our sensors and shields have been modified in an attempt to find this ship.

Your orders are to search and destroy.]])

	-- build a route for the klingon ship to have taken
	step = irandom(15, 18)

	-- move one step directly away from the player
	klingon_course = irandom(0, 359)
	local klingon_x, klingon_y = vectorFromAngle(klingon_course, 20000)
	klingon_x = 10000 + math.floor(klingon_x)
	klingon_y = 10000 + math.floor(klingon_y)
	step, klingon_x, klingon_y = nextStep(step, klingon_x, klingon_y)

end




function update(delta)

	-- update timer for delayed stuff
	tick(timers, delta)

	-- check for player destroyed
	if not player_ship:isValid() then
		endGameMessage(timers, player_ship_names[1].." lost with all hands", "Klingons")
	else

		-- display tetryon particles to science officer
		player_sector = player_ship:getSectorName()
		tetryon = klingon_trace[player_sector]
		if previous_sector then
			player_ship:removeCustom ("tetryon"..previous_sector)
		end
		if tetryon then
			player_ship:addCustomInfo("Science", "tetryon"..player_sector, "Tetryon:"..tostring(tetryon).."ug/m3")
		else
			player_ship:addCustomInfo("Science", "tetryon"..player_sector, "Tetryon:0.00ug/m3")
		end
		previous_sector = player_sector

		-- if we have revealed a klingon, check if it is destroyed
		if mission_state == "klingon" then
			if klingon and not klingon:isValid() then
				endGameMessage(timers, "Klingon Bird of Prey Destroyed", "Starfleet")
			end
		end
	end


end

