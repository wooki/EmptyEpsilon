-- Name: Galaxy Space Trek Quest - Kobayashi Maru
-- Description: Starfeleet cadet training simulator, no-win scenario
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
patrol_sectors = {
	["F99"] = true,
	["F0"] = true,
	["F1"] = true,
	["F2"] = true,
	["F3"] = true,
	["F4"] = true,
	["F5"] = true,
	["F6"] = true,
	["F7"] = true,
	["F8"] = true,
	["F9"] = true,
	["F10"] = true
}
patrolled_sectors = {}
patrolled_sectors_count = 0
kobayashi = nil
jammers = {}
klingonShips = {}

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

	-- random map elements
	for i=1,8 do
      placeRandomAroundPoint(Nebula, 5, 5000, 20000, random(-100000, 100000), random(-60000, 60000))
    end

    for i=1,20 do
    	placeRandomAroundPoint(Asteroid, math.floor(random(2, 6)), 1000, 5000, random(-120000, 120000), random(-80000, 80000))
    	placeRandomAroundPoint(VisualAsteroid, math.floor(random(2, 6)), 1000, 5000, random(-120000, 120000), random(-80000, 80000))
    end

    -- asteroids
	createObjectsOnLine(-100000, -6000, -60000, 0, 400, Asteroid, 15, 3, 1600)
	createObjectsOnLine(75000, -22000, 100000, 10000, 400, VisualAsteroid, 15, 3, 1600)
 	createObjectsOnLine(80000, -60000, 90000, 20000, 400, Asteroid, 15, 2, 1600)
	createObjectsOnLine(80000, -60000, 90000, 30000, 400, VisualAsteroid, 15, 2, 1600)
	createObjectsOnLine(-35000, -39000, -22000, -10000, 100, Asteroid, 3, 3, 1000)
    createObjectsOnLine(-35000, -39000, -22000, -10000, 100, VisualAsteroid, 3, 3, 1000)

    neutral_zone = Zone():setPoints(-100000, 0, -100000, -60000, 100000, -60000, 100000, 0):setColor(80, 0, 0):setLabel("Neutral Zone 21527")
    neutral_zone_left = Zone():setPoints(-100000, 0, -200000, 40000, -200000, -20000, -100000, -60000):setColor(80, 0, 0):setLabel("Neutral Zone 21526")
    neutral_zone_right = Zone():setPoints(100000, 0, 100000, -60000, 200000, -100000, 200000, -40000):setColor(80, 0, 0):setLabel("Neutral Zone 21528")

	station = SpaceStation():setPosition(random(-60000, 60000), 60000):setTemplate('Regula Station'):setFaction("Starfleet"):setRotation(random(0, 360)):setCallSign("Nakamura Station")
  	station:setRadarTrace("radartrace_smallstation.png"):setScanned(true)
  	station:setCommsFunction(stationComms)

    -- draw a line, indicating the neutral zone
	-- for i=-120000,120000,22000 do
	-- 	local marker = Artifact():setPosition(i, 0):setScanned():setRadarSignatureInfo(random(8,16),random(22,87),random(1,2))
	-- 	marker:setModel("artifact3"):allowPickup(false):setDescriptions("Border Marker","Warning: Federation vessels should not cross this border")
	-- end
end

checked_in_with_station = false
function stationComms()
	setCommsMessage("Starfleet Directive 010: Before engaging alien species in battle, any and all attempts to make first contact and achieve nonmilitary resolution must be made.")
	if player_ship:getAlertLevel() == "YELLOW ALERT" then
		checked_in_with_station = true
	end
end

function klingonComms()
	if player_ship:getAlertLevel() == "RED ALERT" and checked_in_with_station then
		setCommsMessage("noH QapmeH wo' Qaw'lu'chugh yay chavbe'lu', 'ej wo' choqmeH may' DoHlu'chugh lujbe'lu'")
		for klingon_ship_keys, klingon_ship in pairs(klingonShips) do
			klingon_ship:setFaction("Starfleet")
			klingon_ship:orderDefendTarget(player_ship)
		end
	else
		setCommsMessage("Suvlu'taHvIS yapbe' HoS neH")
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
	player_ship = PlayerSpaceship():setFaction("Starfleet"):setTemplate(shipClass):setRotation(300):setCallSign("USS Simulator")
	player_ship:setPosition(-50000, 40000)
	addNukesToPlayer(player_ship, shipClass)
	table.insert(players, player_ship)

	-- start the Mission
	missionMessage(players, timers, 'mission-start', [[You are ordered to patrol along the edge of the neutral zone sector 21527.

The area of the border you are to patrol has been marked on your star charts, your Relay officer should be able to help you.

Do not stray inside under any circumstances, the Federation cannot afford a war with the Klingons and tensions are already running high.

Starfleet Command out.]])

	-- keep track of state of mission
	kobayashi_state = 'hidden'
	klingon_state = 'waiting'
end

-- create a timer to destroy the kobayashi
function startKobayashiTimer()

	t = random(300, 420)

	addDelayedCallback(timers, "kobayashi-2minutewarning", (t - 180), function()
		if kobayashi_state ~= "aboard" and kobayashi_state ~= "destroyed" then
			kobayashi_state = 'desparate'
		end
	end)

	addDelayedCallback(timers, "kobayashi-destroyed", t, function()
		kobayashi:takeDamage(9999)
	end)
end

-- hails to/from players
function kobayashiComms()
	-- This is the Kobayashi Maru,
	-- ...nineteen periods out of Altair Six.
	-- We have struck a gravitic mine and have lost all power.
	-- ...Our hull is penetrated and we have sustained many casualties.

	-- Enterprise, our position is Gamma Hydra, Section Ten.

	-- Hull penetrated, life support systems failing. Can you assist us, Enterprise? Can you assist us?

	if kobayashi_state == 'destroyed' then


	elseif kobayashi_state == 'hidden' or kobayashi_state == 'aboard' then

		setCommsMessage(".... ..... ....... ...beeep, crrr, kssh")

	else
		if kobayashi_state == 'desparate' then
			msg = [[This is the Kobayashi Maru,

...beeep.... systems critical... crrr, kssh.... immediate assistance.

... two minutes ... crrr, kssh... please respond.]]
		else
			msg = [[This is the Kobayashi Maru,

...crrr, kssh.... nineteen days out of Altair Six.

...beeep.... gravitic mine and have lost all power.

... hull penetrated ... crrr, kssh... please respond.]]
		end
		setCommsMessage(msg)

		addCommsReply("What is your position Kobayashi?", function()

			local kobayashi_zone = kobayashi:getSectorName()

			setCommsMessage([[...crrr, kssh.... casualties.

...beeep.... ]]..kobayashi_zone..[[ ... crrr, kssh...

... life support systems failing. Can you assist us?
			]])

			addCommsReply("We're on our way Kobayashi!", kobayashiComms)
			addCommsReply("Make your way outside the Neutral Zone Kobayashi.", kobayashiComms)

		end)

	end
end

-- allow delayed messages
function openCommsToPlayer()
	if kobayashi_state ~= "aboard" and kobayashi_state ~= "destroyed" then
		kobayashi:openCommsTo(player_ship)
		addDelayedCallback(timers, "kobayashi-comms", random(30, 90), function()
			openCommsToPlayer()
		end)
	end
end

function update(delta)

	-- update timer for delayed stuff
	tick(timers, delta)

	-- check for player destroyed
	if not player_ship:isValid() then
		endGameMessage(timers, "USS Simulator lost with all hands", "Klingons")
	end

	-- watch for player straying into neutral zone
	if klingon_state == 'waiting' and neutral_zone:isInside(player_ship) then
		klingon_state = 'active'

		-- start a delayed timer for war being declared
		addDelayedCallback(timers, "klingon-war", random(300, 420), function()
			endGameMessage(timers, "Federation violated the Organian Treaty", "Klingons")
		end)

		-- spawn some invinsible klingons
		local player_x, player_y = player_ship:getPosition()
		playSoundFile("decloak.ogg")
		klingon1 = CpuShip():setFaction("Klingons"):setTemplate("Klingon Vorcha"):setPosition(player_x + random(-5000, 5000), player_y + random(-5000, -2000)):orderAttack(player_ship)
  		klingon1:setWarpDrive(true)
  		klingon1:setMaxEnergy(10000)
  		klingon1:setEnergy(10000)
  		klingon1:setWeaponStorage("Homing", 100)
  		klingon1:setCommsFunction(klingonComms)
  		table.insert(klingonShips, klingon1)
  		klingon2 = CpuShip():setFaction("Klingons"):setTemplate("Klingon Vorcha"):setPosition(player_x + random(-5000, 5000), player_y + random(-5000, -2000)):orderAttack(player_ship)
  		klingon2:setWarpDrive(true)
  		klingon2:setMaxEnergy(10000)
  		klingon2:setEnergy(10000)
  		klingon2:setWeaponStorage("Homing", 100)
  		klingon2:setCommsFunction(klingonComms)
  		table.insert(klingonShips, klingon2)

  		-- add a new klingon next to the players every 60s
  		additional_klingons = 0
  		spawn = function()
  			playSoundFile("decloak.ogg")
  			additional_klingons = additional_klingons + 1
			local klingon_template = random(1, 9)
			if klingon_template > 6 then
				klingon_template = "Warp Jammer"
			elseif klingon_template > 3 then
				klingon_template = "Klingon Bird Of Prey"
			else
				klingon_template = "Klingon Vorcha"
			end

			local player_x, player_y = player_ship:getPosition()

			if player_y < 0 then
				if klingon_template == "Warp Jammer" then
					local wj = WarpJammer():setPosition(player_x + random(-5000, 5000), player_y + random(-5000, -5000)):setRange(6000):setFaction("Klingons")
					wj:setScanningParameters(1, 2)
			  		jammers["jammer-"..tostring(additional_klingons)] = wj
				else
					local k = CpuShip():setFaction("Klingons"):setTemplate(klingon_template):setPosition(player_x + random(-5000, 5000), player_y + random(-5000, -5000)):orderAttack(player_ship)
			  		k:setWarpDrive(true)
			  		k:setMaxEnergy(10000)
			  		k:setEnergy(10000)
			  		k:setWeaponStorage("Homing", 100)
			  		k:setCommsFunction(klingonComms)
			  		table.insert(klingonShips, k)
			  	end
			end

		  	addDelayedCallback(timers, "spawn-"..tostring(additional_klingons), random(40, 60), spawn)
  		end

  		addDelayedCallback(timers, "spawn-"..tostring(additional_klingons), random(40, 60), spawn)
	end

	-- check for kobayashi destruction (must be at hands of player!?)
	if kobayashi and not kobayashi:isValid() then
		if kobayashi_state == 'aboard' then
			player_ship:addCustomMessage("Science", "kobayashi-destroyed", "We have detected the destruction of the Kobayashi Maru.")
		else
			kobayashi = nil
			kobayashi_state = 'destroyed'
			endGameMessage(timers, "Kobayashi Maru lost with all hands", "Klingons")
		end
	end

	-- check range for transporters
	if kobayashi then
		local kobayashi_range = distance(kobayashi, player_ship)
		if kobayashi_range < 3000 then

			player_ship:addCustomButton("Weapons","transporters","Beam Survivors Aboard",function()

	        	-- must have scanned !
	        	if kobayashi:isFullyScannedBy(player_ship) then
	        		player_ship:addCustomMessage("Weapons","survivors-beamed","Survivors have been beamed aboard.")
	        		kobayashi_state = 'aboard'
	        	else
	        		player_ship:addCustomMessage("Weapons","notscanned","Can't get a transporter lock, make sure the target has been fully scanned.")
	        	end

	        end)
	    else
	    	player_ship:removeCustom("transporters")
	    end
	end

	if station and kobayashi_state == "aboard" then
		local station_range = distance(station, player_ship)
		if station_range < 3000 then

			player_ship:addCustomButton("Weapons","transporters-station","Beam Survivors To Station",function()

	        	endGameMessage(timers, "Survivors were rescued, Hurrah!", "Starfleet")

	        end)
	    else
	    	player_ship:removeCustom("transporters-station")
	    end
	end

	if station and player_ship:isDocked(station) and kobayashi_state == "aboard" then

		endGameMessage(timers, "Survivors were rescued, Hurrah!", "Starfleet")
	end

	-- watch for player being in zones next to neutral zone - once several checked trigger kobayashi
	player_zone = player_ship:getSectorName()
	if patrol_sectors[player_zone] and not patrolled_sectors[player_zone] then
		patrolled_sectors[player_zone] = true
		patrolled_sectors_count = patrolled_sectors_count + 1
	end

	-- once we have seen several sectors start the mission proper
	if kobayashi_state == 'hidden' and patrolled_sectors_count >= 4 then

		-- start a delayed timer (that will be reset if the player enters the neutral zone)
		-- to end the game if no action has been taken (or no other end met)
		addDelayedCallback(timers, "klingon-war", random(300, 520), function()
			endGameMessage(timers, "Crew mutinies and attempts to rescue Kobayashi Maru", "Klingons")
		end)

		kobayashi_state = 'active'
		local player_x, player_y = player_ship:getPosition()

		kobayashi = CpuShip():setCallSign("Kobayashi Maru"):setFaction("Independent"):setTemplate("Tug"):setPosition(player_x + irandom(0, 20000), random(-35000, -50000))
		kobayashi:setRadarSignatureInfo(99, 99, 99):setScanningParameters(3, 2)
		kobayashi:orderIdle():setEnergy(0):setImpulseMaxSpeed(0):setCommsFunction(kobayashiComms)

		-- trigger messages
		openCommsToPlayer(player_ship, timers, kobayashi_state, kobayashi)

		startKobayashiTimer()
	end



end

