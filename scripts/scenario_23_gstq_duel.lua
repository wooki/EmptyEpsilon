-- Name: Galaxy Space Trek Quest - Duel (PvP)
-- Description: Random map and prebuilt for a PvP between two ships
-- Type: PvP
-- Variation[1 Crew, Small Map]: 5x5 sectors vs AI Ship
-- Variation[1 Crew, Medium Map]: 7x7 sectors vs AI Ship
-- Variation[1 Crew, Large Map]: 10x10 sectors vs AI Ship
-- Variation[2 Crews, Small Map]: 5x5 sectors vs a second player crew
-- Variation[2 Crews, Medium Map]: 7x7 sectors vs a second player crew
-- Variation[2 Crews, Large Map]: 10x10 sectors vs a second player crew
-- Variation[1 Romulan, Small Map]: 5x5 sectors vs a second player crew
-- Variation[1 Romulan, Medium Map]: 7x7 sectors vs a second player crew
-- Variation[1 Romulan, Large Map]: 10x10 sectors vs a second player crew

require("utils.lua")
require("more_utils.lua")
require("trek_utils.lua")

prev_fed_rep = 0
prev_rom_rep = 0
timers = {}
crews = 1

function scale(x)
	local scale = 1

	if (getScenarioVariation() == "1 Crew, Small Map") then
		scale = 0.5
	elseif (getScenarioVariation() == "1 Crew, Medium Map") then
		scale = 0.7
	elseif (getScenarioVariation() == "1 Crew, Large Map") then
		scale = 1
	elseif (getScenarioVariation() == "2 Crews, Small Map") then
		scale = 0.5
	elseif (getScenarioVariation() == "2 Crews, Medium Map") then
		scale = 0.7
	elseif (getScenarioVariation() == "2 Crews, Large Map") then
		scale = 1
	elseif (getScenarioVariation() == "1 Romulan, Small Map") then
		scale = 0.5
	elseif (getScenarioVariation() == "1 Romulan, Medium Map") then
		scale = 0.7
	elseif (getScenarioVariation() == "1 Romulan, Large Map") then
		scale = 1
	else
		-- default to Small, 2 player
		scale = 0.5
	end

	return math.floor(x * scale)
end

function zoneForFederationStation()
	local x = scale(irandom(30000, 100000))
	local y = scale(irandom(30000, 100000))
	return x, 0 - y
end

function zoneForRomulanStation()
	local x = scale(irandom(30000, 100000))
	local y = scale(irandom(30000, 100000))
	return 0 - x, y
end

function init()

	federationTroops = {}
	romulanTroops = {}


	-- Player or AI
	if string.find(getScenarioVariation(), "1 Romulan") then
		crews = -1
		romulan_ship = PlayerSpaceship():setFaction("Romulans"):setTemplate("Romulan D'deridex Class"):setPosition(scale(70000), scale(70000)):setCallSign("KS Steve Jobs"):setScannedByFaction("Starfleet", false)
		federation_ship = CpuShip():setFaction("Starfleet"):setTemplate("Constitution Refit"):setPosition(scale(-70000), scale(-70000)):setCallSign("USS Bill Gates"):setScannedByFaction("Romulans", false):orderRoaming()
	elseif string.find(getScenarioVariation(), "2 Crews") or string.find(getScenarioVariation(), "None") then
		crews = 2
		federation_ship = PlayerSpaceship():setFaction("Starfleet"):setTemplate("Constitution Refit"):setPosition(scale(-70000), scale(-70000)):setCallSign("USS Bill Gates"):setScannedByFaction("Romulans", false)
		romulan_ship = PlayerSpaceship():setFaction("Romulans"):setTemplate("Romulan D'deridex Class"):setPosition(scale(70000), scale(70000)):setCallSign("KS Steve Jobs"):setScannedByFaction("Starfleet", false)
	else
		crews = 1
		federation_ship = PlayerSpaceship():setFaction("Starfleet"):setTemplate("Constitution Refit"):setPosition(scale(-70000), scale(-70000)):setCallSign("USS Bill Gates"):setScannedByFaction("Romulans", false)
		romulan_ship = CpuShip():setFaction("Romulans"):setTemplate("Romulan Warbird"):setPosition(scale(70000), scale(70000)):setCallSign("KS Steve Jobs"):setScannedByFaction("Starfleet", false):orderRoaming()
	end

	-- Start the players with 100 reputation.
	-- federation_ship:addReputationPoints(100.0)
	-- romulan_ship:addReputationPoints(100.0)

	-- Federation station, top right
	local federation_station_x, federation_station_y = zoneForFederationStation()
	federation_station = SpaceStation():setCommsScript('comms_station_trek.lua'):setPosition(federation_station_x, federation_station_y):setTemplate('Regula Station'):setFaction("Starfleet"):setRotation(irandom(0, 360)):setCallSign("Forward Command")
	federation_patrol_1 = CpuShip():setTemplate('Intrepid Class'):setFaction("Starfleet"):setPosition(federation_station_x + 5000, federation_station_y + 1000):orderDefendTarget(federation_station):setScannedByFaction("Starfleet", true)
	federation_patrol_2 = CpuShip():setTemplate('Intrepid Class'):setFaction("Starfleet"):setPosition(federation_station_x + 4000, federation_station_y + 3000):orderFlyFormation(federation_patrol_1,-400, 0):setScannedByFaction("Starfleet", true)
	federation_patrol_3 = CpuShip():setTemplate('Intrepid Class'):setFaction("Starfleet"):setPosition(federation_station_x + 4000, federation_station_y + 3000):orderFlyFormation(federation_patrol_1,0, -400):setScannedByFaction("Starfleet", true)

	local romulan_station_x, romulan_station_y = zoneForRomulanStation()
	romulan_station = SpaceStation():setCommsScript('comms_station_trek.lua'):setPosition(romulan_station_x, romulan_station_y):setTemplate('Romulan Station'):setFaction("Romulans"):setRotation(irandom(0, 360)):setCallSign("Forward Command")
	romulan_patrol_1 = CpuShip():setTemplate('Romulan Bird Of Prey'):setFaction("Romulans"):setPosition(romulan_station_x + 5000, romulan_station_y + 1000):orderDefendTarget(romulan_station):setScannedByFaction("Romulans", true)
	romulan_patrol_2 = CpuShip():setTemplate('Romulan Bird Of Prey'):setFaction("Romulans"):setPosition(romulan_station_x + 4000, romulan_station_y + 3000):orderFlyFormation(romulan_patrol_1, -400, 0):setScannedByFaction("Romulans", true)
	romulan_patrol_3 = CpuShip():setTemplate('Romulan Bird Of Prey'):setFaction("Romulans"):setPosition(romulan_station_x + 4000, romulan_station_y + 3000):orderFlyFormation(romulan_patrol_1, 0, -400):setScannedByFaction("Romulans", true)

	-- keep track of federation and romulan sides for calculating reputation
 	federationList = {}
 	table.insert(federationList, federation_ship)
	table.insert(federationList, federation_station)
	table.insert(federationList, federation_patrol_1)
	table.insert(federationList, federation_patrol_2)
	table.insert(federationList, federation_patrol_3)

 	romulanList = {}
 	table.insert(romulanList, romulan_ship)
	table.insert(romulanList, romulan_station)
	table.insert(romulanList, romulan_patrol_1)
	table.insert(romulanList, romulan_patrol_2)
	table.insert(romulanList, romulan_patrol_3)


	-- hide each station with a nebula cluster directly between the station and the enemy ship starting location
	local federation_camouflage_angle = angleFromVector(federation_station_x, federation_station_y, scale(70000), scale(70000))
	local federation_camouflage_vector_x, federation_camouflage_vector_y = vectorFromAngle(federation_camouflage_angle, -10000)

	local romulan_camouflage_angle = angleFromVector(romulan_station_x, romulan_station_y, -scale(70000), -scale(70000))
	local romulan_camouflage_vector_x, romulan_camouflage_vector_y = vectorFromAngle(romulan_camouflage_angle, 10000)

	placeRandomAroundPoint(Nebula, 3, 5000, 20000, federation_station_x + federation_camouflage_vector_x,  federation_station_y + federation_camouflage_vector_y)
	placeRandomAroundPoint(Nebula, 3, 5000, 20000, romulan_station_x + romulan_camouflage_vector_x,  romulan_station_y + romulan_camouflage_vector_y)

	-- place some random clusters where stations could be
	-- for i=1,3 do
      local rndZoneX, rndZoneY = zoneForFederationStation()
	  placeRandomAroundPoint(Nebula, 5, 5000, 20000, rndZoneX, rndZoneY)
 --    end
	-- for i=1,3 do
	    local rndZoneX, rndZoneY = zoneForRomulanStation()
		placeRandomAroundPoint(Nebula, 5, 5000, 20000, rndZoneX, rndZoneY)
	-- end

	--Create 50 random asteroids
	for asteroid_counter=1,math.floor(scale(80)) do
	    Asteroid():setPosition(irandom(-scale(100000), scale(100000)), irandom(-scale(100000), scale(100000)))
	end

	-- place a line down throug the middle as nebula
	createObjectsOnLine(-scale(100000), scale(30000), -scale(20000), scale(10000), 500, Nebula, 1, 3, 10000)
	createObjectsOnLine(scale(20000), scale(30000), scale(100000), scale(10000), 500, Nebula, 1, 3, 10000)

	-- asteroids on far edges
	createObjectsOnLine(-scale(120000), 0, -scale(80000), 0, 200, Asteroid, 40, 8, 1000)
	createObjectsOnLine(scale(80000), 0, scale(120000), 0, 200, Asteroid, 40, 8, 1000)
	createObjectsOnLine(-scale(120000), 0, -scale(80000), 0, 200, VisualAsteroid, 20, 4, 1000)
	createObjectsOnLine(scale(80000), 0, scale(120000), 0, 200, VisualAsteroid, 20, 4, 1000)

	-- place a line down vertical as asteroids
	createObjectsOnLine(-scale(50000), -scale(120000), -scale(8000), 0, 100, Asteroid, 4, 8, 800)
	createObjectsOnLine(-scale(25000), -scale(10000), scale(40000), scale(120000), 100, Asteroid, 4, 8, 800)
	createObjectsOnLine(-scale(50000), -scale(120000), -scale(8000), 0, 100, VisualAsteroid, 2, 8, 800)
	createObjectsOnLine(-scale(25000), -scale(10000), scale(40000), scale(120000), 100, VisualAsteroid, 2, 8, 800)

	-- Create central planet and station
	planet1 = Planet():setPosition(6000, 0):setPlanetRadius(6000):setDistanceFromMovementPlane(-3000):setPlanetSurfaceTexture("planets/gas-blue.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.4,0.5,1.0)
	orbit_station = SpaceStation():setCommsScript('comms_station_trek.lua'):setPosition(-2500, 0):setTemplate('Terok Nor'):setFaction("Independent"):setRotation(irandom(0, 360)):setCallSign("Independent Station")
	-- orbit_station:setOrbit(planet1, 40)

	-- Create some random outposts
	random_station_1 = SpaceStation():setTemplate("Medium Station"):setCommsScript('comms_station_trek.lua'):setFaction("Independent"):setCallSign("DS7"):setPosition(irandom(-scale(80000), scale(80000)), irandom(-scale(80000), scale(80000)))
	random_station_2 = SpaceStation():setTemplate("Medium Station"):setCommsScript('comms_station_trek.lua'):setFaction("Independent"):setCallSign("DS4"):setPosition(irandom(-scale(80000), scale(80000)), irandom(-scale(80000), scale(80000)))
	random_station_3 = SpaceStation():setTemplate("Small Station"):setCommsScript('comms_station_trek.lua'):setFaction("Independent"):setCallSign("DS3"):setPosition(irandom(-scale(80000), scale(80000)), irandom(-scale(80000), scale(80000)))
	random_station_4 = SpaceStation():setTemplate("Small Station"):setCommsScript('comms_station_trek.lua'):setFaction("Independent"):setCallSign("DS2"):setPosition(irandom(-scale(80000), scale(80000)), irandom(-scale(80000), scale(80000)))

	-- create some random freighters
	freighter_1 = CpuShip():setTemplate('Goods Freighter 1'):setFaction("Starfleet"):setPosition(irandom(-scale(120000), scale(120000)), irandom(-scale(120000), scale(120000))):orderDefendTarget(random_station_1)
	freighter_2 = CpuShip():setTemplate('Goods Freighter 1'):setFaction("Romulans"):setPosition(irandom(-scale(120000), scale(120000)), irandom(-scale(120000), scale(120000))):orderDefendTarget(random_station_2)

	freighter_escort_1 = CpuShip():setTemplate('Intrepid Class'):setFaction("Starfleet"):setPosition(federation_station_x + 4000, federation_station_y + 3000):orderFlyFormation(freighter_1,0, -400):setScannedByFaction("Starfleet", false)
	freighter_escort_2 = CpuShip():setTemplate('Romulan Bird Of Prey'):setFaction("Romulans"):setPosition(romulan_station_x + 4000, romulan_station_y + 3000):orderFlyFormation(freighter_2,0, -400):setScannedByFaction("Romulans", false)

	CpuShip():setTemplate('Goods Freighter 1'):setFaction("Independent"):setPosition(irandom(-scale(120000), scale(120000)), irandom(-scale(120000), scale(120000))):orderDefendTarget(random_station_3)
	if string.find(getScenarioVariation(), "Large") then
		CpuShip():setTemplate('Goods Freighter 1'):setFaction("Independent"):setPosition(irandom(-scale(120000), scale(120000)), irandom(-scale(120000), scale(120000))):orderDefendTarget(random_station_4)
	end
	table.insert(federationList, freighter_1)
	table.insert(federationList, freighter_escort_1)
	table.insert(romulanList, freighter_2)
	table.insert(romulanList, freighter_escort_2)


	freighter_3 = CpuShip():setTemplate('Fuel Freighter 1'):setFaction("Starfleet"):setPosition(irandom(-scale(120000), scale(120000)), irandom(-scale(120000), scale(120000))):orderDefendTarget(random_station_1)
	freighter_4 = CpuShip():setTemplate('Fuel Freighter 1'):setFaction("Romulans"):setPosition(irandom(-scale(120000), scale(120000)), irandom(-scale(120000), scale(120000))):orderDefendTarget(random_station_2)

	freighter_escort_3 = CpuShip():setTemplate('Intrepid Class'):setFaction("Starfleet"):setPosition(federation_station_x - 4000, federation_station_y - 3000):orderFlyFormation(freighter_3,0, -400):setScannedByFaction("Starfleet", false)
	freighter_escort_4 = CpuShip():setTemplate('Romulan Bird Of Prey'):setFaction("Romulans"):setPosition(romulan_station_x - 4000, romulan_station_y - 3000):orderFlyFormation(freighter_4,0, -400):setScannedByFaction("Romulans", false)

	if string.find(getScenarioVariation(), "Medium") or string.find(getScenarioVariation(), "Large") then
		CpuShip():setTemplate('Fuel Freighter 1'):setFaction("Independent"):setPosition(irandom(-scale(120000), scale(120000)), irandom(-scale(120000), scale(120000))):orderDefendTarget(random_station_3)
	end
	if string.find(getScenarioVariation(), "Large") then
		CpuShip():setTemplate('Fuel Freighter 1'):setFaction("Independent"):setPosition(irandom(-scale(120000), scale(120000)), irandom(-scale(120000), scale(120000))):orderDefendTarget(random_station_4)
	end
	table.insert(federationList, freighter_3)
	table.insert(federationList, freighter_escort_3)
	table.insert(romulanList, freighter_4)
	table.insert(romulanList, freighter_escort_4)

	-- create roaming bad guys
	local f1 = CpuShip():setTemplate('Ferengi Marauder'):setFaction("Ferengi"):setPosition(0, -100000):orderRoaming()
	local f2 = CpuShip():setTemplate('Ferengi Marauder'):setFaction("Ferengi"):setPosition(0, 100000):orderRoaming()
	if string.find(getScenarioVariation(), "Medium") or string.find(getScenarioVariation(), "Large") then
		local f3 = CpuShip():setTemplate('Ferengi Marauder'):setFaction("Ferengi"):setPosition(irandom(-scale(100000), scale(100000)), 0):orderRoaming()
		local f4 = CpuShip():setTemplate('Ferengi Marauder'):setFaction("Ferengi"):setPosition(irandom(-scale(100000), scale(100000)), 0):orderRoaming()
	end
	if string.find(getScenarioVariation(), "Large") then
		local f5 = CpuShip():setTemplate('Ferengi Marauder'):setFaction("Ferengi"):setPosition(-scale(50000), 0):orderRoaming()
		local f6 = CpuShip():setTemplate('Ferengi Marauder'):setFaction("Ferengi"):setPosition(-scale(50000), 0):orderRoaming()
		local f7 = CpuShip():setTemplate('Ferengi Marauder'):setFaction("Ferengi"):setPosition(scale(80000), 0):orderRoaming()
		local f8 = CpuShip():setTemplate('Ferengi Marauder'):setFaction("Ferengi"):setPosition(scale(80000), 0):orderRoaming()
	end

	-- some random warp jammers
	WarpJammer():setFaction("Ferengi"):setPosition(irandom(-scale(50000), scale(50000)), irandom(-scale(50000), scale(50000)))
	if string.find(getScenarioVariation(), "Medium") then
		WarpJammer():setFaction("Ferengi"):setPosition(irandom(-scale(50000), scale(50000)), irandom(-scale(50000), scale(50000)))
	end
	if string.find(getScenarioVariation(), "Large") then
		WarpJammer():setFaction("Ferengi"):setPosition(irandom(-scale(50000), scale(50000)), irandom(-scale(50000), scale(50000)))
		WarpJammer():setFaction("Ferengi"):setPosition(irandom(-scale(50000), scale(50000)), irandom(-scale(50000), scale(50000)))
	end


	-- Brief the players
	federation_station:sendCommsMessage(federation_ship, [[A long range probe has detected the arrival of a Romulan warship in Sector ]] .. romulan_ship:getSectorName() .. [[.

They have destroyed our probe and have almost certainly identified our position.

Captain, your objective is to destroy that ship!

We have a number of assets in defensive position around our forward command base at ]] .. federation_station:getSectorName() .. [[.

Intelligence reports the system is home to a small number of neutral stations and we are detecting signs of freighter activity, they may be of use for ressuply.

We are also seeing signs of Ferengi pirates in the vicinity.

Good luck, and good hunting.]])

	romulan_station:sendCommsMessage(romulan_ship, [[A long range probe has detected the arrival of a Federation warship in Sector ]] .. federation_ship:getSectorName() .. [[.

They have destroyed our probe and have almost certainly identified our position.

Captain, your objective is to destroy that ship!

We have a number of assets in defensive position around our forward command base at ]] .. romulan_station:getSectorName() .. [[.

Intelligence reports the system is home to a small number of neutral stations and we are detecting signs of freighter activity, they may be of use for ressuply.

We are also seeing signs of Ferengi pirates in the vicinity.

Good luck, and good hunting.]])

end



function update(delta)

	timers = tick(timers, delta)

	-- if the federation is destroyed ...
	if (not federation_ship:isValid()) then
		endGameMessage(timers, "Federation vessel lost with all hands", "Romulans")
	end

	-- if the romulan is destroyed ...
	if (not romulan_ship:isValid()) then
		endGameMessage(timers, "Romulan vessel lost with all hands", "Starfleet")
	end

	-- Count all surviving federations and romulan
	-- first time a destroyed ship or station is found, remove it
	-- and subtracy 100 reputation from that side

	-- add on count for cumulative
	local fed_cumulative = 0
	local rom_cumulative = 0

	if crews == 2 or crews == 1 then
		local federation_count = 0
		local remove_fed_ships = {}
		for _, h in pairs(federationList) do
			if h:isValid() then
				federation_count = federation_count + 1
			else
				table.insert(remove_fed_ships, _)
				fed_cumulative = fed_cumulative - 100
			end
		end
		fed_cumulative = fed_cumulative + (delta * federation_count * 0.1)
	end

	if crews == 2 or crews == -1 then
		local romulan_count = 0
		local remove_romulan_ships = {}
		for _, k in pairs(romulanList) do
			if k:isValid() then
				romulan_count = romulan_count + 1
			else
				table.insert(remove_romulan_ships, _)
				rom_cumulative = rom_cumulative - 100
			end
		end
		rom_cumulative = rom_cumulative + (delta * romulan_count * 0.1)
	end

	-- remove any destroyed ships, so not multi-counted
	federationList = ArrayRemove(federationList, function(t, i, j)
		if not t[i]:isValid() then
			return false
		else
			return true
		end
	end)
	romulanList = ArrayRemove(romulanList, function(t, i, j)
		if not t[i]:isValid() then
			return false
		else
			return true
		end
	end)

	-- add reputation based on number of allies left
	if crews == 2 or crews == 1 then
		federation_ship:addReputationPoints(fed_cumulative)
	end

	if crews == 2 or crews == -1 then
		romulan_ship:addReputationPoints(rom_cumulative)
	end

	-- update relay with other sides points
	if crews == 2 or crews == 1 then
		federation_ship:removeCustom("score"..prev_fed_rep)
	end

	if crews == 2 or crews == -1 then
		romulan_ship:removeCustom("score"..prev_rom_rep)
	end

	if crews == 2 or crews == 1 then
		prev_fed_rep = math.floor(federation_ship:getReputationPoints() / 100)
	end

	if crews == 2 or crews == -1 then
		prev_rom_rep = math.floor(romulan_ship:getReputationPoints() / 100)
	end

	if crews == 2 then
		federation_ship:addCustomInfo("Relay", "score"..tostring(prev_rom_rep), "Romulan Rep: "..tostring(prev_rom_rep).."00+")
		romulan_ship:addCustomInfo("Relay", "score"..tostring(prev_fed_rep), "Fed Rep: "..tostring(prev_fed_rep).."00+")
	end

	-- anyone with 1000 reputation wins
	if crews == 2 then
		if federation_ship:getReputationPoints() >= 1000 and federation_ship:getReputationPoints() > romulan_ship:getReputationPoints() then
			endGameMessage(timers, "Federation first to 1000 reputation", "Starfleet")
		end
		if romulan_ship:getReputationPoints() >= 1000 and romulan_ship:getReputationPoints() > federation_ship:getReputationPoints() then
			endGameMessage(timers, "Romulans first to 1000 reputation", "Romulans")
		end
	end

end
