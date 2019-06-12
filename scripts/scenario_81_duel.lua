-- Name: Duel (PvP)
-- Description: Random map and prebuilt for a PvP between two ships
-- Type: PvP
-- Variation[1 Crew, Small Map]: 3x3 sectors vs AI Ship
-- Variation[1 Crew, Medium Map]: 5x5 sectors vs AI Ship
-- Variation[1 Crew, Large Map]: 7x7 sectors vs AI Ship
-- Variation[1 Crew, Huge Map]: 10x10 sectors vs AI Ship
-- Variation[2 Crews, Small Map]: 3x3 sectors vs a second player crew
-- Variation[2 Crews, Medium Map]: 5x5 sectors vs a second player crew
-- Variation[2 Crews, Large Map]: 7x7 sectors vs a second player crew
-- Variation[2 Crews, Huge Map]: 10x10 sectors vs a second player crew

-- TODO: warn then lose when moving too far outside map area
-- TODO: new scenario for multiple players - fortnight circle reducing

require("utils.lua")
require("more_utils.lua")

function scale(x)
	local scale = 1

	if (getScenarioVariation() == "1 Crew, Small Map") then
		scale = 0.33
	elseif (getScenarioVariation() == "1 Crew, Medium Map") then
		scale = 0.5
	elseif (getScenarioVariation() == "1 Crew, Large Map") then
		scale = 0.7
	elseif (getScenarioVariation() == "1 Crew, Huge Map") then
		scale = 1
	elseif (getScenarioVariation() == "2 Crews, Small Map") then
		scale = 0.33
	elseif (getScenarioVariation() == "2 Crews, Medium Map") then
		scale = 0.5
	elseif (getScenarioVariation() == "2 Crews, Large Map") then
		scale = 0.7
	elseif (getScenarioVariation() == "2 Crews, Huge Map") then
		scale = 1
	else
		-- default to Medium, 2 player
		scale = 0.5
	end

	return x * scale
end

function zoneForHumanStation()
	local x = scale(random(30000, 100000))
	local y = scale(random(30000, 100000))
	return x, 0 - y
end

function zoneForKraylorStation()
	local x = scale(random(30000, 100000))
	local y = scale(random(30000, 100000))
	return 0 - x, y
end

function init()

	humanTroops = {}
	kraylorTroops = {}

	-- Spawn players
	human_ship = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(scale(-70000), scale(-70000)):setCallSign("USS Bill Gates"):setScannedByFaction("Kraylor", false)

	-- Player or AI
	if string.find(getScenarioVariation(), "2 Players") then
		kraylor_ship = PlayerSpaceship():setFaction("Kraylor"):setTemplate("Atlantis"):setPosition(scale(70000), scale(70000)):setCallSign("KS Steve Jobs"):setScannedByFaction("Human Navy", false)
	else
		kraylor_ship = CpuShip():setFaction("Kraylor"):setTemplate("Atlantis"):setPosition(scale(70000), scale(70000)):setCallSign("KS Steve Jobs"):setScannedByFaction("Human Navy", false):orderRoaming()
	end

	-- Start the players with 100 reputation.
	-- human_ship:addReputationPoints(100.0)
	-- kraylor_ship:addReputationPoints(100.0)

	-- Human station, top right
	local human_station_x, human_station_y = zoneForHumanStation()
	human_station = SpaceStation():setPosition(human_station_x, human_station_y):setTemplate('Small Station'):setFaction("Human Navy"):setRotation(random(0, 360)):setCallSign("Forward Command")
	human_patrol_1 = CpuShip():setTemplate('Flavia Falcon'):setFaction("Human Navy"):setPosition(human_station_x + 5000, human_station_y + 1000):orderDefendTarget(human_station):setScannedByFaction("Human Navy", true)
	human_patrol_2 = CpuShip():setTemplate('MT52 Hornet'):setFaction("Human Navy"):setPosition(human_station_x + 4000, human_station_y + 3000):orderFlyFormation(human_patrol_1,-400, 0):setScannedByFaction("Human Navy", true)
	human_patrol_3 = CpuShip():setTemplate('MT52 Hornet'):setFaction("Human Navy"):setPosition(human_station_x + 4000, human_station_y + 3000):orderFlyFormation(human_patrol_1,0, -400):setScannedByFaction("Human Navy", true)

	local kraylor_station_x, kraylor_station_y = zoneForKraylorStation()
	kraylor_station = SpaceStation():setPosition(kraylor_station_x, kraylor_station_y):setTemplate('Small Station'):setFaction("Kraylor"):setRotation(random(0, 360)):setCallSign("Forward Command")
	kraylor_patrol_1 = CpuShip():setTemplate('Flavia Falcon'):setFaction("Kraylor"):setPosition(kraylor_station_x + 5000, kraylor_station_y + 1000):orderDefendTarget(kraylor_station):setScannedByFaction("Kraylor", true)
	kraylor_patrol_2 = CpuShip():setTemplate('MT52 Hornet'):setFaction("Kraylor"):setPosition(kraylor_station_x + 4000, kraylor_station_y + 3000):orderFlyFormation(kraylor_patrol_1, -400, 0):setScannedByFaction("Kraylor", true)
	kraylor_patrol_3 = CpuShip():setTemplate('MT52 Hornet'):setFaction("Kraylor"):setPosition(kraylor_station_x + 4000, kraylor_station_y + 3000):orderFlyFormation(kraylor_patrol_1, 0, -400):setScannedByFaction("Kraylor", true)

	-- keep track of human and kraylor sides for calculating reputation
 	humanList = {}
 	table.insert(humanList, human_ship)
	table.insert(humanList, human_station)
	table.insert(humanList, human_patrol_1)
	table.insert(humanList, human_patrol_2)
	table.insert(humanList, human_patrol_3)

 	kraylorList = {}
 	table.insert(kraylorList, kraylor_ship)
	table.insert(kraylorList, kraylor_station)
	table.insert(kraylorList, kraylor_patrol_1)
	table.insert(kraylorList, kraylor_patrol_2)
	table.insert(kraylorList, kraylor_patrol_3)


	-- hide each station with a nebula cluster directly between the station and the enemy ship starting location
	local human_camouflage_angle = angleFromVector(human_station_x, human_station_y, scale(70000), scale(70000))
	local human_camouflage_vector_x, human_camouflage_vector_y = vectorFromAngle(human_camouflage_angle, -10000)

	local kraylor_camouflage_angle = angleFromVector(kraylor_station_x, kraylor_station_y, -scale(70000), -scale(70000))
	local kraylor_camouflage_vector_x, kraylor_camouflage_vector_y = vectorFromAngle(kraylor_camouflage_angle, 10000)

	placeRandomAroundPoint(Nebula, 3, 5000, 20000, human_station_x + human_camouflage_vector_x,  human_station_y + human_camouflage_vector_y)
	placeRandomAroundPoint(Nebula, 3, 5000, 20000, kraylor_station_x + kraylor_camouflage_vector_x,  kraylor_station_y + kraylor_camouflage_vector_y)

	-- place some random clusters where stations could be
	-- for i=1,3 do
      local rndZoneX, rndZoneY = zoneForHumanStation()
	  placeRandomAroundPoint(Nebula, 5, 5000, 20000, rndZoneX, rndZoneY)
 --    end
	-- for i=1,3 do
	    local rndZoneX, rndZoneY = zoneForKraylorStation()
		placeRandomAroundPoint(Nebula, 5, 5000, 20000, rndZoneX, rndZoneY)
	-- end

	--Create 50 random asteroids
	for asteroid_counter=1,math.floor(scale(80)) do
	    Asteroid():setPosition(random(-scale(100000), scale(100000)), random(-scale(100000), scale(100000)))
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
	planet1 = Planet():setPosition(6000, 0):setPlanetRadius(6000):setDistanceFromMovementPlane(-3000):setPlanetSurfaceTexture("planets/gas-1.png"):setPlanetCloudTexture("planets/clouds-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
	orbit_station = SpaceStation():setPosition(-2500, 0):setTemplate('Large Station'):setFaction("Independent"):setRotation(random(0, 360)):setCallSign("Independent Station")
	-- orbit_station:setOrbit(planet1, 40)

	-- Create some random outposts
	random_station_1 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("DS7"):setPosition(random(-scale(80000), scale(80000)), random(-scale(80000), scale(80000)))
	random_station_2 = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS4"):setPosition(random(-scale(80000), scale(80000)), random(-scale(80000), scale(80000)))
	if string.find(getScenarioVariation(), "Medium") or string.find(getScenarioVariation(), "Large") or string.find(getScenarioVariation(), "Huge") then
		random_station_3 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("DS3"):setPosition(random(-scale(80000), scale(80000)), random(-scale(80000), scale(80000)))
	end
	random_station_4 = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS2"):setPosition(random(-scale(80000), scale(80000)), random(-scale(80000), scale(80000)))

	-- create some random freighters
	freighter_1 = CpuShip():setTemplate('Goods Freighter 1'):setFaction("Human Navy"):setPosition(random(-scale(120000), scale(120000)), random(-scale(120000), scale(120000))):orderDefendTarget(random_station_1)
	freighter_2 = CpuShip():setTemplate('Goods Freighter 1'):setFaction("Kraylor"):setPosition(random(-scale(120000), scale(120000)), random(-scale(120000), scale(120000))):orderDefendTarget(random_station_2)

	freighter_escort_1 = CpuShip():setTemplate('MT52 Hornet'):setFaction("Human Navy"):setPosition(human_station_x + 4000, human_station_y + 3000):orderFlyFormation(freighter_1,0, -400):setScannedByFaction("Human Navy", false)
	freighter_escort_2 = CpuShip():setTemplate('MT52 Hornet'):setFaction("Kraylor"):setPosition(human_station_x + 4000, human_station_y + 3000):orderFlyFormation(freighter_2,0, -400):setScannedByFaction("Human Navy", false)

	if string.find(getScenarioVariation(), "Medium") or string.find(getScenarioVariation(), "Large") or string.find(getScenarioVariation(), "Huge") then
		CpuShip():setTemplate('Goods Freighter 1'):setFaction("Independent"):setPosition(random(-scale(120000), scale(120000)), random(-scale(120000), scale(120000))):orderDefendTarget(random_station_3)
	end
	if string.find(getScenarioVariation(), "Large") or string.find(getScenarioVariation(), "Huge") then
		CpuShip():setTemplate('Goods Freighter 1'):setFaction("Independent"):setPosition(random(-scale(120000), scale(120000)), random(-scale(120000), scale(120000))):orderDefendTarget(random_station_4)
	end
	table.insert(humanList, freighter_1)
	table.insert(humanList, freighter_escort_1)
	table.insert(kraylorList, freighter_2)
	table.insert(kraylorList, freighter_escort_2)


	freighter_3 = CpuShip():setTemplate('Fuel Freighter 1'):setFaction("Human Navy"):setPosition(random(-scale(120000), scale(120000)), random(-scale(120000), scale(120000))):orderDefendTarget(random_station_1)
	freighter_4 = CpuShip():setTemplate('Fuel Freighter 1'):setFaction("Kraylor"):setPosition(random(-scale(120000), scale(120000)), random(-scale(120000), scale(120000))):orderDefendTarget(random_station_2)

	freighter_escort_3 = CpuShip():setTemplate('MT52 Hornet'):setFaction("Human Navy"):setPosition(human_station_x - 4000, human_station_y - 3000):orderFlyFormation(freighter_3,0, -400):setScannedByFaction("Human Navy", false)
	freighter_escort_4 = CpuShip():setTemplate('MT52 Hornet'):setFaction("Kraylor"):setPosition(human_station_x - 4000, human_station_y - 3000):orderFlyFormation(freighter_4,0, -400):setScannedByFaction("Human Navy", false)

	if string.find(getScenarioVariation(), "Medium") or string.find(getScenarioVariation(), "Large") or string.find(getScenarioVariation(), "Huge") then
		CpuShip():setTemplate('Fuel Freighter 1'):setFaction("Independent"):setPosition(random(-scale(120000), scale(120000)), random(-scale(120000), scale(120000))):orderDefendTarget(random_station_3)
	end
	if string.find(getScenarioVariation(), "Large") or string.find(getScenarioVariation(), "Huge") then
		CpuShip():setTemplate('Fuel Freighter 1'):setFaction("Independent"):setPosition(random(-scale(120000), scale(120000)), random(-scale(120000), scale(120000))):orderDefendTarget(random_station_4)
	end
	table.insert(humanList, freighter_3)
	table.insert(humanList, freighter_escort_3)
	table.insert(kraylorList, freighter_4)
	table.insert(kraylorList, freighter_escort_4)

	-- create roaming bad guys
	CpuShip():setTemplate('Adder MK5'):setFaction("Exuari"):setPosition(scale(100000), -scale(100000)):orderRoaming()
	CpuShip():setTemplate('Adder MK5'):setFaction("Exuari"):setPosition(-scale(100000), scale(100000)):orderRoaming()
	if string.find(getScenarioVariation(), "Medium") or string.find(getScenarioVariation(), "Large") or string.find(getScenarioVariation(), "Huge") then
		CpuShip():setTemplate('Adder MK5'):setFaction("Exuari"):setPosition(random(-scale(80000), scale(80000)), 0):orderRoaming()
		CpuShip():setTemplate('Adder MK5'):setFaction("Exuari"):setPosition(random(-scale(80000), scale(80000)), 0):orderRoaming()
	end
	if string.find(getScenarioVariation(), "Large") or string.find(getScenarioVariation(), "Huge") then
		CpuShip():setTemplate('Adder MK5'):setFaction("Exuari"):setPosition(-scale(50000), 0):orderRoaming()
		CpuShip():setTemplate('Adder MK5'):setFaction("Exuari"):setPosition(-scale(50000), 0):orderRoaming()
		CpuShip():setTemplate('Adder MK5'):setFaction("Exuari"):setPosition(-scale(50000), 0):orderRoaming()
		CpuShip():setTemplate('Adder MK5'):setFaction("Exuari"):setPosition(scale(50000), 0):orderRoaming()
	end

	-- some random warp jammers
	WarpJammer():setFaction("Exuari"):setPosition(-scale(100000), scale(100000))
	if string.find(getScenarioVariation(), "Medium") or string.find(getScenarioVariation(), "Large") or string.find(getScenarioVariation(), "Huge") then
		WarpJammer():setFaction("Exuari"):setPosition(-scale(100000), scale(100000))
	end
	if string.find(getScenarioVariation(), "Large") or string.find(getScenarioVariation(), "Huge") then
		WarpJammer():setFaction("Exuari"):setPosition(-scale(100000), scale(100000))
	end
	if string.find(getScenarioVariation(), "Huge") then
		WarpJammer():setFaction("Exuari"):setPosition(-scale(100000), scale(100000))
	end


	-- Brief the players
	human_station:sendCommsMessage(human_ship, [[A long range probe has detected the arrival of a Kraylor warship in Sector ]] .. kraylor_ship:getSectorName() .. [[.

They have destroyed our probe and have almost certainly identified our position.

Captain, your objective is to destroy that ship!

We have a number of assets in defensive position around our forward command base at ]] .. human_station:getSectorName() .. [[.

Intelligence reports the system is home to a small number of neutral stations and we are detecting signs of freighter activity, they may be of use for ressuply.

We are also seeing signs of Exuari pirates in the vicinity.

Good luck, and good hunting.]])

	kraylor_station:sendCommsMessage(kraylor_ship, [[A long range probe has detected the arrival of a Human warship in Sector ]] .. human_ship:getSectorName() .. [[.

They have destroyed our probe and have almost certainly identified our position.

Captain, your objective is to destroy that ship!

We have a number of assets in defensive position around our forward command base at ]] .. kraylor_station:getSectorName() .. [[.

Intelligence reports the system is home to a small number of neutral stations and we are detecting signs of freighter activity, they may be of use for ressuply.

We are also seeing signs of Exuari pirates in the vicinity.

Good luck, and good hunting.]])

end



function update(delta)

	-- if the human is destroyed ...
	if (not human_ship:isValid()) then
		victory("Kraylor")
	end

	-- if the kraylor is destroyed ...
	if (not kraylor_ship:isValid()) then
		victory("Human Navy")
	end

	-- Count all surviving humans and kraylor
	human_count = 0
	for _, h in ipairs(humanList) do
		if h:isValid() then
			human_count = human_count + 1
		end
	end

	kraylor_count = 0
	for _, k in ipairs(kraylorList) do
		if k:isValid() then
			kraylor_count = kraylor_count + 1
		end
	end

	-- add reputation based on number of allies left
	human_ship:addReputationPoints(delta * human_count * 0.1)
	kraylor_ship:addReputationPoints(delta * kraylor_count * 0.1)

end
