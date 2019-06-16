-- Name: External Influences
-- Description: Players police a trade route in the Euripides system as a rebel scheme unfolds
-- Type: Mission
-- Variation[1 Galaxy Class]: One player ship, Galaxy Class
-- Variation[1 Constitution Class]: One player ship, Constitution Class
-- Variation[1 Defiant Class]: One player ship, Defiant Class
-- Variation[2 Crews]: Two player ships
-- Variation[3 Crews]: Three player ships

require("utils.lua")
require("more_utils.lua")
require("delays.lua")

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

klingon_ship_names = shuffle({
  "Aktuh",
  "Akua",
  "Akva",
  "Azetbur",
  "BaHwil'",
  "Baqghol",
  "Bej'joq",
  "Chen'a'meQ",
  "Ch'marq",
  "Daqchov",
  "D'k Tahg",
  "Fragh'ka",
  "Ghanjaq",
  "GhonDoq",
  "Hegh'mar",
  "Hegh'ta",
  "Key'vong",
  "Neng'ta",
  "Tur'Nask",
  "Hegh'ta",
  "Ki'tang",
  "Buruk",
  "Ning'tao",
  "Slivin",
  "Vorn",
  "Y'tem",
  "Klothos",
  "Par'tok",
  "Negh'Var",
  "Hor'Cha",
  "Fek'lhr",
  "Maht-H'a",
  "Qu'Vat",
  "Vor'nak",
  "Toh'Kaht",
  "Vo'taq"
})

-- different freighter types
freighter_types = {
  'Personnel Freighter',
  'Goods Freighter',
  'Garbage Freighter',
  'Equipment Freighter',
  'Fuel Freighter'
}

mining_base_names = shuffle({
  'Alpha',
  'Beta',
  'Gama',
  'Delta',
  'Epsilon',
  'Zeta',
  'Eta',
  'Theta',
  'Iota',
  'Kappa',
  'Lamda'
})

-- modify the starting vars for station comms
trade_hub_comms = {
    friendlyness = 100,
    stock = {
        Homing = 30,
        HVLI = 30,
        Mine = 30,
        Nuke = 5,
        EMP = 0
    },
    weapons = {
        Homing = 60,
        HVLI = 50,
        Mine = 60,
        Nuke = 90,
        EMP = 90
    }
}
mining_station_comms = {
    friendlyness = 100,
    stock = {
        Homing = 10,
        HVLI = 50,
        Mine = 20,
        Nuke = 2,
        EMP = 2
    },
    weapons = {
        Homing = 60,
        HVLI = 50,
        Mine = 60,
        Nuke = 90,
        EMP = 90
    }
}

timers = {}

function gambleAmount(stake)
  if comms_source:getReputationPoints() > stake then
    addCommsReply("Gamble "..stake.." gold-pressed latinum", function()
      comms_source:takeReputationPoints(stake)
      if (random(0, 10) > 7) then
        local winnings = math.floor(stake + (stake*random(1, 3)))
        comms_source:addReputationPoints(winnings)
        setCommsMessage("You win! The bank pays you "..winnings.." latinum.")
        addCommsReply("You are on a roll!", commsGamble)
      else
        setCommsMessage("You lose this time.")
        addCommsReply("You feel your luck changing!", commsGamble)
      end
    end)
  end
end

function commsGamble()

  if comms_source:getReputationPoints() <= 0 then
    setCommsMessage("After checking your credit you are refused entry to the casino.")
  else
    setCommsMessage("You find yourself at a Dabo wheel in the station casino.")
    gambleAmount(1)
    gambleAmount(5)
    gambleAmount(10)
    gambleAmount(25)
    gambleAmount(50)
  end
end

weapon_cost = {
    Homing = 2,
    HVLI = 2,
    Mine = 2,
    Nuke = 15,
    EMP = 10
}

function getWeaponCost(weapon)
    return math.ceil(weapon_cost[weapon])
end

function handleWeaponRestock(player, weapon)
    if not player:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(player:getWeaponStorageMax(weapon) - player:getWeaponStorage(weapon))
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
        if player:getWeaponStorage(weapon) == player:getWeaponStorageMax(weapon) then
            setCommsMessage("You are fully loaded and ready to explode things.")
        else
            setCommsMessage("We generously resupplied you with some " .. weapon .. " charges.\nPut them to good use.")
        end
        addCommsReply("Back", mainBaseCommsStock)
    end
end

function mainBaseCommsStock()
    -- Handle communications while docked with this station.
    setCommsMessage("Good day, officer!\nWhat can we do for you today?")

    if comms_source:getWeaponStorageMax("Homing") > 0 then
        addCommsReply("Do you have spare homing missiles for us? ("..getWeaponCost("Homing").."rep each)", function()
            handleWeaponRestock(comms_source, "Homing")
        end)
    end
    if comms_source:getWeaponStorageMax("HVLI") > 0 then
        addCommsReply("Can you restock us with HVLI? ("..getWeaponCost("HVLI").."rep each)", function()
            handleWeaponRestock(comms_source, "HVLI")
        end)
    end
    if comms_source:getWeaponStorageMax("Mine") > 0 then
        addCommsReply("Please re-stock our mines. ("..getWeaponCost("Mine").."rep each)", function()
            handleWeaponRestock(comms_source, "Mine")
        end)
    end
    if comms_source:getWeaponStorageMax("Nuke") > 0 then
        addCommsReply("Can you supply us with some nukes? ("..getWeaponCost("Nuke").."rep each)", function()
            handleWeaponRestock(comms_source, "Nuke")
        end)
    end
    if comms_source:getWeaponStorageMax("EMP") > 0 then
        addCommsReply("Please re-stock our EMP missiles. ("..getWeaponCost("EMP").."rep each)", function()
            handleWeaponRestock(comms_source, "EMP")
        end)
    end

    addCommsReply("Back", mainBaseComms)
end

function mainBaseComms()

  setCommsMessage("Go ahead "..comms_source:getCallSign().."...")

  addCommsReply("Sitrep please.", function()
    local sitrep = [[In-system situation:

Rebel deliveries made: ]]..rebel_deliveries..[[

Smuggler deliveries made: ]]..smugglers_arrived..[[

Rebels destroyed: ]]..rebels_destroyed..[[

Traders destroyed: ]]..traders_destroyed..[[
      ]]
    sitrep = sitrep.."\n\nEverything is under control.  Situation normal.  Had a slight weapons malfunction.  But uh, everything is perfectly alright now.  We're fine.  We're all fine here now, thank you.  How are you?"
    setCommsMessage(sitrep);
    addCommsReply("Back", mainBaseComms)
  end)

  if comms_source:isDocked(comms_target) then
      addCommsReply("So we're docked huh?", function()
        setCommsMessage("That certainly appears to be the case.")
        addCommsReply("Visit the Quartermaster", mainBaseCommsStock)
        addCommsReply("Find somewhere to drink", function()
          if (random(1, 10) > 3) then
            setCommsMessage("You find a quiet little bar on deck "..math.floor(random(11, 19)).." and keep yourselves to yourselves.")
          elseif (random(1, 10) > 3) and current_act == 2 then
            setCommsMessage("You get chatting to a shady smuggler in a dark and smokey dive bar, he tells you the rebels have managed to get their hands on a stockpile of mines.")
          else
            setCommsMessage("You vaguely remember singing \"You've Lost That Loving Feeling\" in front of a bar full of naval cadets and it has badly hurt your crews reputation.")
            comms_source:takeReputationPoints(20)
          end
          addCommsReply("Back", mainBaseComms)
        end)
        addCommsReply("Find somewhere to gamble", commsGamble)
        addCommsReply("Back", mainBaseComms)
      end)
  else
    addCommsReply("Please send reinforcements! (80 rep)", function()
        if comms_source:getWaypointCount() < 1 then
            setCommsMessage("Negatory "..comms_source:getCallSign()..", you need to set a waypoint before we can send reinforcements.");
            addCommsReply("Back", mainBaseComms)
        else
            setCommsMessage("To which waypoint should we dispatch the reinforcements?");
            addCommsReply("Back", mainBaseComms)
            for n=1,comms_source:getWaypointCount() do
                addCommsReply("WP" .. n, function()
                    if comms_source:takeReputationPoints(80) then
                        ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Intrepid Class"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
                        setCommsMessage("Good call "..comms_source:getCallSign()..", we have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
                        addCommsReply("Back", mainBaseComms)
                    else
                        setCommsMessage("We're not digging your rep "..comms_source:getCallSign()..".");
                        addCommsReply("Back", mainBaseComms)
                    end
                end)
            end
        end
    end)
  end
end

function rebelComms()
  setCommsMessage("We're not interested in anything you have to say "..comms_source:getCallSign());
end

function map()

  -- gas giant and rings
  gas_giant = Planet():setPosition(40000, 0):setPlanetRadius(3000):setPlanetSurfaceTexture("planets/gas-1.png"):setPlanetAtmosphereColor(0.9,0.75,0.6):setCallSign("Euripides")
  placeRandomAroundPoint(Asteroid, 150, 9000, 12000, 40000, 0)
  placeRandomAroundPoint(Asteroid, 300, 14000, 18000, 40000, 0)
  placeRandomAroundPoint(VisualAsteroid, 50, 9000, 12000, 40000, 0)
  placeRandomAroundPoint(VisualAsteroid, 100, 14000, 18000, 40000, 0)

  -- trade hubs
  trade_hubs = {}
  trade_hub_planet = Planet():setPosition(-16761, 8582):setPlanetRadius(1000):setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.3,0.3,1.0):setCallSign("Amphipolis")
  trade_hub = SpaceStation():setPosition(-14761, 10582):setTemplate('Terok Nor'):setFaction("Independent"):setRotation(random(0, 360)):setCallSign("Amphipolis Trade Hub")
  trade_hub.comms_data = trade_hub_comms
  trade_hub:setCommsScript('comms_station_unfriendly.lua')
  table.insert(trade_hubs, trade_hub)

  -- create two additonal hub stations
  trade_hub2 = SpaceStation():setPosition(-1847, 23224):setTemplate('Regula Station'):setFaction("Independent"):setRotation(random(0, 360)):setCallSign("Amphipolis Refuel Station")
  trade_hub3 = SpaceStation():setPosition(29009, 30008):setTemplate('Regula Station'):setFaction("Independent"):setRotation(random(0, 360)):setCallSign("Euripides Weather Station")
  trade_hub2.comms_data = trade_hub_comms
  trade_hub3.comms_data = trade_hub_comms
  trade_hub2:setCommsScript('comms_station_unfriendly.lua')
  trade_hub3:setCommsScript('comms_station_unfriendly.lua')
  table.insert(trade_hubs, trade_hub2)
  table.insert(trade_hubs, trade_hub3)

  -- rebel asteroids
  createObjectsOnLine(30000, 31000, 51000, 40000, 100, Asteroid, 3, 3, 1000)
  createObjectsOnLine(20000, 39000, 48000, 42000, 100, Asteroid, 3, 3, 1000)
  createObjectsOnLine(15000, 45000, 40000, 46000, 100, Asteroid, 3, 3, 1000)
  createObjectsOnLine(30000, 31000, 51000, 40000, 100, VisualAsteroid, 3, 3, 1000)
  createObjectsOnLine(20000, 39000, 48000, 42000, 100, VisualAsteroid, 3, 3, 1000)
  createObjectsOnLine(15000, 45000, 40000, 46000, 100, VisualAsteroid, 3, 3, 1000)

  -- nebula to hide rebel base later
  Nebula():setPosition(47000, 44000)

  -- human base
  human_planet = Planet():setPosition(-20000, -40000):setPlanetRadius(700):setPlanetSurfaceTexture("planets/planet-2.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(1.0,0.1,0.1):setCallSign("Kameiros")
  human_station = SpaceStation():setPosition(-19000, -42000):setTemplate('Starbase'):setFaction("Starfleet"):setRotation(random(0, 360)):setCallSign("Kameiros Military Base")
  human_station:setCommsFunction(mainBaseComms)


  -- asteroids by human base
  createObjectsOnLine(-35000, -39000, -22000, -10000, 100, Asteroid, 3, 3, 1000)
  createObjectsOnLine(-35000, -39000, -22000, -10000, 100, VisualAsteroid, 3, 3, 1000)

  -- nebula south of hub
  createObjectsOnLine(-36000, 35000, 0, 22000, 1000, Nebula, 3, 3, 500)

  -- random central nebula
  placeRandomAroundPoint(Nebula, 3, 10000, 40000, 0, 0)

  -- klingon nebula
  placeRandomAroundPoint(Nebula, 6, 2000, 10000, 15000, -50000)
  placeRandomAroundPoint(Nebula, 12, 10000, 15000, 15000, -50000)

end

function act_1()

  current_act = 1
  rebel_deliveries = 0 -- keep track of every rebel delivery (bolster attack with this)
  traders_destroyed = 0 -- keep track of traders and smugglers killed (bolster attack with this)
  rebels_destroyed = 0
  smugglers_arrived = 0

  -- tables for different objects
  mining_stations = {}
  traders = {}

  -- create array of AI types for freighters
  trader_types = {}
  trader_types_count = (mining_station_count*2)
  for i=1,trader_types_count,1 do -- start with all traders
    if (i <= player_ship_count) then
      table.insert(trader_types, 'rebel')
    elseif (i <= (player_ship_count * 2)) then
      table.insert(trader_types, 'smuggler')
    else
      table.insert(trader_types, 'trader')
    end
  end
  trader_types = shuffle(trader_types)
  trader_type_index = 1 -- dish out roles to each trader

  -- bases within the rings
  for i=1,mining_station_count,1 do

    -- base
    local mining_station = SpaceStation():setTemplate('Small Station'):setFaction("Independent"):setRotation(90):setCallSign("Mining Outpost "..mining_base_names[i])
    setCirclePos(mining_station, 40000, 0, random(0, 360), random(17500, 18100))
    mining_station.comms_data = mining_station_comms
    mining_station:setCommsScript('comms_station_unfriendly.lua')
    table.insert(mining_stations, mining_station)

    local mining_station_x, mining_station_y = mining_station:getPosition()

    -- adjust mining station to always be on the left side arc of the rings (so closer to everything else!)
    if mining_station_x > 40000 then
      mining_station_x = 40000 - (mining_station_x - 40000)
      mining_station:setPosition(mining_station_x, mining_station_y)
    end

    -- adjust any mining stations right at the top to make sure they are a bit closer
    if mining_station_y < -10000 then
      mining_station_y = mining_station_y + 10000
      mining_station_x = mining_station_x - 4000
      mining_station:setPosition(mining_station_x, mining_station_y)
    end

    -- trader docked with each base
    local freighter = createTrader('dock mine', mining_station, mining_station_x-random(2000, 10000), mining_station_y+random(0, 2000), trader_type_index)
    trader_type_index = trader_type_index + 1

    -- traders on there way to each base
    local hub_index = math.floor(random(1, 6))
    if (hub_index > 3) then
      hub_index = 1
    end
    local hub_destination = trade_hubs[hub_index]
    local hub_destination_x, hub_destination_y = hub_destination:getPosition();
    local freighter2 = createTrader('dock hub', hub_destination, hub_destination_x+random(2000, 20000), hub_destination_y+random(-15000, 15000), trader_type_index)
    trader_type_index = trader_type_index + 1

  end -- mining_station_count

  missionMessage("act_1", [[Welcome to the ringed gas giant Euripides.

There are a number of mining stations in the rings of Euripides and your job is to police the commercial traffic in the system.

You have the power to stop and board any freighters and they should comply with your orders but we suspect both smugglers and Federation Sepratists are present in the system and they may choose to run.

Once identified as sepratists you may chase down and destroy them but civilian and even smuggler casualties will not be acceptable, whats more, it will likely fan the flames of rebellion.

Kameiros out.]])
end

function init()

  current_act = 0

  addGMFunction("Act 1", act_1)
  addGMFunction("Act 2", act_2)
  addGMFunction("Act 3", act_3)


  local shipClass = "Constitution Refit"
  local ship2Class = "Constitution Refit"
  local ship3Class = "Constitution Refit"
  if random(0, 100) > 70 then
    ship2Class = "Prometheus Class"
    ship3Class = "Defiant Class"
  else
    ship2Class = "Defiant Class"
    ship3Class = "Prometheus Class"
  end

  -- set some default counts based on the variation
  klingon_ship_names_index = 1
  player_ship_names_index = 1
  player_ship_count = 1
  mining_station_count = 3
  if (getScenarioVariation() == "1 Galaxy Class") then
    shipClass = "Galaxy Class"
  elseif (getScenarioVariation() == "1 Constitution Class") then
    shipClass = "Constitution Refit"
  elseif (getScenarioVariation() == "1 Defiant Class") then
    shipClass = "Defiant Class"
  elseif (getScenarioVariation() == "2 Crews") then
    shipClass = "Constitution Refit"
    player_ship_count = 2
    mining_station_count = 5
  elseif (getScenarioVariation() == "3 Crews") then
    shipClass = "Constitution Refit"
    player_ship_count = 3
    mining_station_count = 7
  end

  map()

  -- player ship
  player_ships = {}
  human_ship = PlayerSpaceship():setFaction("Starfleet"):setTemplate(shipClass):setRotation(random(0, 360)):setCallSign(player_ship_names[player_ship_names_index])
  human_ship:setPosition(random(-29000, -31000), random(-41000, -43000))
  table.insert(player_ships, human_ship)
  player_ship1 = human_ship
  player_ship_names_index = player_ship_names_index + 1

  if player_ship_count > 1 then
    human_ship2 = PlayerSpaceship():setFaction("Starfleet"):setTemplate(ship2Class):setRotation(random(0, 360)):setCallSign(player_ship_names[player_ship_names_index])
    human_ship2:setPosition(random(-29000, -31000), random(-41000, -43000))
    table.insert(player_ships, human_ship2)
    player_ship2 = human_ship2
    player_ship_names_index = player_ship_names_index + 1
  end

  if player_ship_count > 2 then
    human_ship3 = PlayerSpaceship():setFaction("Starfleet"):setTemplate(ship3Class):setRotation(random(0, 360)):setCallSign(player_ship_names[player_ship_names_index])
    human_ship3:setPosition(random(-29000, -31000), random(-41000, -43000))
    table.insert(player_ships, human_ship3)
    player_ship3 = human_ship3
    player_ship_names_index = player_ship_names_index + 1
  end

end

-- util to get the player ship
function getPlayerByCallSign(callsign)

  for player_ship_keys, player_ship in ipairs(player_ships) do
    if (player_ship:getCallSign() == callsign) then
      return player_ship
    end
  end

  return nil
end

function createTrader(state, destination, x, y, type_index)

  local freighter = CpuShip():setTemplate(freighter_types[math.floor(random(1, 5))].." "..math.floor(random(1, 5))):setFaction("Independent"):setPosition(x, y):orderFlyTowards(destination:getPosition())
  freighter:setImpulseMaxSpeed(random(70, 75)) -- make a bit faster than normal
  freighter:setRotationMaxSpeed(9) -- make a bit nibler to avoid getting stuck as easily (I hope)
  freighter:setCommsScript('comms_ship_smuggler.lua')
  freighter.comms_data = {
    callsign = freighter:getCallSign(),
    state = state,
    destination = destination,
    type_index = type_index
  }
  if (freighter.comms_data['type_index'] > trader_types_count) then
    freighter.comms_data['type_index'] = 1
  end
  freighter.comms_data['type'] = trader_types[freighter.comms_data['type_index']]

  table.insert(traders, freighter)

end

-- destroying rebels, traders and smugglers has random impact on each station
function updateStationFriendlyness(type, station)

  local change = random(-20, -10) -- default always a little bad
  if (type == "smuggler") then -- often worse!
    change = random(-30, -10)
  elseif (type == "rebel") then -- sometimes positive
    change = random(-20, 20)
  end

  station.comms_data['friendlyness'] = station.comms_data['friendlyness'] + math.floor(change)

end

--
function updateAllStationFriendlyness(type)

  for key, hub in ipairs(trade_hubs) do
    updateStationFriendlyness(type, trade_hubs[key])
  end

  for key, mine in ipairs(mining_stations) do
    updateStationFriendlyness(type, mining_stations[key])
  end

end

-- any behaviour on an update that is not act specific
function generic_behaviour(act)

  -- watch for destroyed traders (replace and punish/reward)
  for key, trader in ipairs(traders) do
    if not (trader and trader:isValid()) then

      traders[key] = nil -- remove from next pass

      -- if it was being chased blame that player, otherwise ALL players
      -- in future could replace with closest
      local culprits = {}
      if (trader.comms_data['chased_by']) then
        player = getPlayerByCallSign(trader.comms_data['chased_by'])
        table.insert(culprits, player)
      else
        culprits = player_ships
      end

      local message = ""
      local reward = 0
      if (trader.comms_data['type'] == 'rebel') then
        rebels_destroyed = rebels_destroyed + 1
        reward = 60
        message = "We have reports you have destroyed the rebel ship the "..trader.comms_data['callsign']..", good work!"

      elseif (trader.comms_data['type'] == 'smuggler') then
        traders_destroyed = traders_destroyed + 1
        reward = -24
        message = "We have reports you have destroyed the "..trader.comms_data['callsign']..", as a suspected smuggler we will overlook this action but it should be noted this makes for troublesome public relations."
      else
        traders_destroyed = traders_destroyed + 1
        reward = -100
        message = "We have reports you have destroyed the "..trader.comms_data['callsign']..", as an innocent trader this will count against you in your next performance review!"
      end

      updateAllStationFriendlyness(trader.comms_data['type'])

      for culprit_key, culprit in ipairs(culprits) do

        playSoundFile("chirp.ogg")
        human_station:sendCommsMessage(culprit, message);

        if reward > 0 then
          culprit:addReputationPoints(reward)
          culprit:addToShipLog("[REPUTATION] Rebel destroyed, reward "..reward.." reputation.", "Green")
        else
          culprit:takeReputationPoints(reward * -1)
          culprit:addToShipLog("[REPUTATION] Trader destroyed, penalty "..(reward * -1).." reputation.", "Red")
        end
      end

      -- add a replacement, use next type_index
      local destination = mining_stations[math.floor(random(1, mining_station_count))]
      local destination_x, destination_y = destination:getPosition();
      local freighter = createTrader('dock mine', destination, destination_x+random(2000, 6000), destination_y+random(-1000, 1000), trader.comms_data['type_index'] + 1)

    end
  end

  -- watch for destroyed mining stations and adjust count and reindex or just end game
  for key, mining_station in ipairs(mining_stations) do
    if not (mining_station:isValid()) then
      globalMessage(mining_station:getCallSign().." was destroyed, humans lose!")
    end
  end

  -- watch for destroyed hub - end game
  for key, hub in ipairs(trade_hubs) do
    if not (hub:isValid()) then
      globalMessage(hub:getCallSign().." was destroyed, humans lose!")
    end
  end

  -- watch for destroyed human base
  if not (human_station:isValid()) then
    globalMessage(human_station:getCallSign().." was destroyed, humans lose!")
  end

  -- TODO: watch for no human players
  --

  -- check each trader and update missions
  for key, trader in ipairs(traders) do

    if (not trader.comms_data['avoiding']) then

      if (trader.comms_data['state'] == 'running') then
        -- should already be heading away from the player
        local player = getPlayerByCallSign(trader.comms_data['chased_by'])
        local range = distance(trader, player)
        if (range > 60000) then

          -- add a replacement, use next type_index
          if (act > 2) then
            local destination = mining_stations[random(1, mining_station_count)]
            local destination_x, destination_y = destination:getPosition();
            local freighter = createTrader('dock mine', destination, destination_x+random(2000, 6000), destination_y+random(-1000, 1000), trader.comms_data['type_index'] + 1)
          end

          -- remove the old one
          trader:destroy()
          traders[key] = nil

        elseif (trader.comms_data['type'] == 'rebel') and trader.comms_data['loading'] then

          if (trader:getWeaponStorage("HVLI") > 0) then
            trader.comms_data['loaded'] = true
            trader.comms_data['loading'] = false
          end

        elseif (trader.comms_data['type'] == 'rebel') and trader.comms_data['loaded'] then
          -- rebels running will fight until they have no HVLI left

          if (trader:getWeaponStorage("HVLI") <= 0) then

              trader.comms_data['loaded'] = false

            -- work out a position a long way, immediately away from the player
              local player_x, player_y = player:getPosition()
              local trader_x, trader_y = trader:getPosition()
              local angle = angleFromVector(player_x, player_y, trader_x, trader_y)
              local run_x, run_y = vectorFromAngle(angle, 100000)
              trader:orderFlyTowardsBlind(run_x, run_y)
          end
        end

      elseif (trader.comms_data['state'] == 'stopped') then

        -- boarding means waiting for weapons to send away team
        if (trader.comms_data['cargo'] == 'boarding') then

          local player = getPlayerByCallSign(trader.comms_data['stopped_by'])

          -- deal with by type
          if (trader.comms_data['type'] == 'trader') then

            player:addCustomButton("Weapons","awayteam-"..trader:getCallSign(),"Beam Away Team to "..trader:getCallSign(),function()
              player:removeCustom("awayteam-"..trader:getCallSign())
              sendAwayTeam(trader, player)
            end)

          elseif (trader.comms_data['type'] == 'smuggler') then

            -- sometimes run, usually give in
            if (random(1, 10) > 7) then

              -- message back and swith back to running
              trader.comms_data['cargo'] = nil
              trader.comms_data['state'] = 'running'
              trader.comms_data['chased_by'] = player:getCallSign()

              -- work out a position a long way, immediately away from the player
              local player_x, player_y = player:getPosition()
              local trader_x, trader_y = trader:getPosition()
              local angle = angleFromVector(player_x, player_y, trader_x, trader_y)
              local run_x, run_y = vectorFromAngle(angle, 100000)

              -- make it fast as well player ships max is 90 (except fighters)
              trader:setImpulseMaxSpeed(random(80, 100))
              trader:orderFlyTowards(run_x, run_y)

              player_ship:addCustomMessage("Relay",message_id, message)
              player:addCustomMessage("Relay","smugglerrun","Away team reports the "..trader:getCallSign().." is moving away, they have returning to the "..player:getCallSign().." you may persue when ready.")
              player:addToShipLog("[AWAYTEAM] the "..trader:getCallSign().." is moving away, they have returning to the "..player:getCallSign()..".", "Red")

              -- drain the players energy
              local newEnergy = player:getEnergy() - 500
              if (newEnergy < 0) then
                newEnergy = 0
              end
              player:setEnergy(newEnergy)
              local newJumpHeat = player:getSystemHeat("jump")
              newJumpHeat = newJumpHeat + 0.2
              if (newJumpHeat > 1) then
                newJumpHeat = 1
              end
              player:setSystemHeat("jump", newJumpHeat)

            else
              player:addCustomButton("Weapons","awayteam-"..trader:getCallSign(),"Beam Away Team to "..trader:getCallSign(),function()
                player:removeCustom("awayteam-"..trader:getCallSign())
                sendAwayTeam(trader, player)
              end)
            end

          elseif (trader.comms_data['type'] == 'rebel') then

            -- always run and sabotage the players ship

            -- work out a position a long way, immediately away from the player
            local player_x, player_y = player:getPosition()
            local trader_x, trader_y = trader:getPosition()
            local angle = angleFromVector(player_x, player_y, trader_x, trader_y)
            local run_x, run_y = vectorFromAngle(angle, 100000)

            -- make it fast as well player ships max is 90 (except fighters)
            trader:setImpulseMaxSpeed(random(80, 100))

            player_ship:addCustomMessage("Relay",message_id, message)
            player:addCustomMessage("Relay","rebelrun","Away team reports the "..trader:getCallSign().." is moving away, they have returning to the "..player:getCallSign().." you may persue when ready.")
            player:addToShipLog("[AWAYTEAM] the "..trader:getCallSign().." is moving away, they have returning to the "..player:getCallSign()..".", "Red")

            -- drain the players energy
            local newEnergy = player:getEnergy() - 800
            if (newEnergy < 0) then
              newEnergy = 0
            end
            player:setEnergy(newEnergy)
            local newJumpHeat = player:getSystemHeat("jump")
            newJumpHeat = newJumpHeat + 0.5
            if (newJumpHeat > 1) then
              newJumpHeat = 1
            end
            player:setSystemHeat("jump", newJumpHeat)

            -- change faction and scan
            trader:setFaction("Federation Sepratists")
            trader:setCommsFunction(rebelComms)
            trader:setScannedByFaction("Starfleet", true)

            -- beef up rebel ships with some weapons
            trader:setShields(55, 55)
            trader:setBeamWeapon(0, 45, 0, 1000, 8, 6)
            trader:setWeaponTubeCount(1) -- Amount of torpedo tubes, and loading time of the tubes.
            trader:setWeaponTubeDirection(0, 0):setWeaponTubeExclusiveFor(0, "HVLI")
            trader:setWeaponStorageMax("HVLI", 2)
            trader:setWeaponStorage("HVLI", 2)

            local range = distance(trader, player)
            if (range > 20000) then
              trader:orderFlyTowards(run_x, run_y)
            else
              trader.comms_data['loading'] = true
              trader.comms_data['loaded'] = false
              trader:orderAttack(player)
            end

            -- message back and swith back to running
            trader.comms_data['cargo'] = nil
            trader.comms_data['state'] = 'running'
            trader.comms_data['chased_by'] = player:getCallSign()
            traders[key] = trader

          end

        elseif (trader.comms_data['cargo'] == 'checking') then

          -- do nothing, this is now set-up by the weapons special button
          -- add a variable delay here

        end

      elseif (trader.comms_data['state'] == 'dock mine' or trader.comms_data['state'] == 'dock hub') then

        -- has it arrived, is it close?
        if (trader:isDocked(trader.comms_data['destination'])) then

          -- always clear cargo check
          trader.comms_data['cargo'] = nil

          -- check for rebel delivery
          if (trader.comms_data['type'] == 'rebel') then
            rebel_deliveries = rebel_deliveries + 1 -- base should be able to report this
          else
            if (trader.comms_data['type'] == 'smuggler') then
              smugglers_arrived = smugglers_arrived + 1
            end

            -- cycle trader type when arriving UNLESS REBEL
            trader.comms_data['type_index'] = trader.comms_data['type_index'] + 1
            if (trader.comms_data['type_index'] > trader_types_count) then
              trader.comms_data['type_index'] = 1
            end
            trader.comms_data['type'] = trader_types[trader.comms_data['type_index']]
          end

          -- arrived, so set new destination
          if (trader.comms_data['state'] == 'dock mine') then
            trader.comms_data['state'] = 'dock hub'
            local hub_index = math.floor(random(1, 6))
            if (hub_index > 3) then
              hub_index = 1
            end
            trader.comms_data['destination'] = trade_hubs[hub_index]
          else
            trader.comms_data['state'] = 'dock mine'
            trader.comms_data['destination'] = mining_stations[math.floor(random(1, mining_station_count))]
          end

          trader:orderFlyTowards(trader.comms_data['destination']:getPosition())

          if (act > 2) then
            trader:destroy()
            traders[key] = nil
          end

        elseif (distance(trader, trader.comms_data['destination']) < 10000) then
          trader:orderDock(trader.comms_data['destination'])
        end

      end
    end

  end -- each trader

  -- collision avoidance - if trader within x distance of another trader the
  -- one further north turns north until more distance acheived
  for key, trader in ipairs(traders) do
    for other_key, other_trader in ipairs(traders) do

      if key ~= other_key then

           if (not trader.comms_data['avoiding']) and (distance(trader, other_trader) < 1000) then

            local trader_x, trader_y = trader:getPosition()
            local other_trader_x, other_trader_y = other_trader:getPosition()
            if trader_y < other_trader_y then
              trader.comms_data['avoiding'] = other_key

              trader:orderFlyTowards(trader_x - 100, trader_y - 1600)

              -- only send the second trader away IF they are further than x from dock target
              if (distance(other_trader, other_trader.comms_data['destination']) > 4000) then
                other_trader.comms_data['avoiding'] = key
                other_trader:orderFlyTowards(other_trader_x + 100, other_trader_y + 1600)
              end
            end

          elseif (trader.comms_data['avoiding'] == other_key) and (distance(trader, other_trader) > 1000) then
            trader.comms_data['avoiding'] = nil

            if trader.comms_data['destination'] then
              if (distance(trader, trader.comms_data['destination']) < 50000) then
                trader:orderDock(trader.comms_data['destination'])
              else
                trader:orderFlyTowards(trader.comms_data['destination']:getPosition())
              end
            end
          end
      end
    end
  end


end

function sendAwayTeam(trader, player)

  playSoundFile("transporter.ogg")
  trader.comms_data['cargo'] = 'checking'

  local delay = math.random(10, 60)
  local delayEstimate = math.floor(delay + math.random(-10, 10))
  local checking_message_id = 'checking-message-' .. tostring(math.random(1, 99999))

  player:addCustomInfo("Weapons","awayteamestimate","Mission estimate " .. tostring(delayEstimate) .. " seconds.")

  addDelayedCallback(timers, checking_message_id, delay, function()

    player:removeCustom("Weapons","awayteamestimate")

    if (trader.comms_data['type'] == 'trader') then

      playSoundFile("chirp.ogg")
      trader.comms_data['cargo'] = 'ok'
      player:addCustomMessage("Relay","awayteamdone","Away team reports no contraband aboard the "..trader:getCallSign()..", you may clear them to leave.")
      player:addToShipLog("[AWAYTEAM] the "..trader:getCallSign().." has no contraband, they have returning to the "..player:getCallSign()..".", "White")

    elseif (trader.comms_data['type'] == 'smuggler') then

        playSoundFile("chirp.ogg")
        trader.comms_data['cargo'] = 'contraband'
        player:addCustomMessage("Relay","awayteamdone","Away team reports we have found contraband aboard the "..trader:getCallSign()..
        [[, we have taken their captain into custody and attached a inhibitor to their ship, clear them to head home when you are ready.]])
        player:addToShipLog("[AWAYTEAM] the "..trader:getCallSign().." has contraband aboard, they have returning to the "..player:getCallSign()..". We have taken their captain into custody and attached a inhibitor to their ship, clear them to head home when you are ready.", "White")

    end
  end)
end

-- create klingon fleet and suplement with rebels
function act_3()

  -- enemy forces modified by
  -- rebel_deliveries
  -- traders_destroyed
  -- smugglers_arrived

  current_act = 3
  klingon_ships = {}

  local klingon_x = 17769
  local klingon_y = -50639

  -- 1 big Klingons, plus 1 smaller per player
  klingon_flagship = CpuShip():setFaction("Klingons"):setTemplate("Klingon Kvek"):setPosition(klingon_x, klingon_y):orderAttack(human_station):setCallSign(klingon_ship_names[klingon_ship_names_index])
  klingon_ship_names_index = klingon_ship_names_index + 1
  table.insert(klingon_ships, klingon_flagship)

  for player_ship_keys, player_ship in ipairs(player_ships) do

    local player_position_x, player_position_y = player_ship:getPosition()
    local klingon_support = CpuShip():setFaction("Klingons"):setTemplate("Klingon Bloodwing"):setPosition(player_position_x + random(-15000, 15000), player_position_y + random(-15000, 15000)):orderAttack(player_ship):setCallSign(klingon_ship_names[klingon_ship_names_index])
    klingon_ship_names_index = klingon_ship_names_index + 1
    table.insert(klingon_ships, klingon_support)
  end

  for n=1,rebel_deliveries do
    CpuShip():setFaction("Klingons"):setTemplate("Klingon Bird Of Prey"):setPosition(klingon_x + random(-5000, 25000), klingon_y + random(-5000, 25000)):orderDefendTarget(klingon_flagship):setCallSign(klingon_ship_names[klingon_ship_names_index])
    klingon_ship_names_index = klingon_ship_names_index + 1
  end
  for n=1,traders_destroyed do
    CpuShip():setFaction("Federation Sepratists"):setTemplate("WX-Lindworm"):setPosition(klingon_x + random(-5000, 25000), klingon_y + random(-5000, 25000)):orderDefendTarget(klingon_flagship):setCallSign(klingon_ship_names[klingon_ship_names_index])
    klingon_ship_names_index = klingon_ship_names_index + 1
  end
  for n=1,smugglers_arrived do
    CpuShip():setFaction("Federation Sepratists"):setTemplate("MU52 Hornet"):setPosition(klingon_x + random(-5000, 25000), klingon_y + random(-5000, 25000)):orderDefendTarget(klingon_flagship):setCallSign(klingon_ship_names[klingon_ship_names_index])
    klingon_ship_names_index = klingon_ship_names_index + 1
  end

  -- send mission update
missionMessage("act_3", [[We have intelligence that suggests the Rebels have been funded and supported by the Klingon Empire!

They have most likely been using the rebel faction for their own end and we suspect an attack is imminent.

Get yourself back to base as soon as you can, expect a fight when you get here.

Kameiros out.]])

end

-- create rebel base
function act_2()

    current_act = 2

    -- enemy forces modified by
    -- rebel_deliveries
    ambush_waves = 2 + rebel_deliveries
    ambush_ships = {}
    ambush_ships_count = 0

    -- spawn rebel base
    rebel_base = SpaceStation():setPosition(47000, 44000):setTemplate('Klingon Station'):setFaction("Federation Sepratists"):setRotation(random(0, 360)):setCallSign("Rebel Base")
    rebel_base:setCommsFunction(rebelComms)

    -- mines
    createObjectsOnLine(31000, 31000, 51000, 40000, 500, Mine, 2, 6, 1600)
    createObjectsOnLine(20000, 39000, 48000, 42000, 500, Mine, 2, 6, 1600)
    createObjectsOnLine(15000, 45000, 40000, 46000, 500, Mine, 2, 6, 1600)
    createObjectsOnLine(42000, 58000, 58000, 42000, 500, Mine, 1, 12, 800)

    -- send mission update
  missionMessage("act_2", [[We have been monitoring Rebel communications and identified their system headquarters.

Immediately cease all patrol duties and proceed to sector ]]..rebel_base:getSectorName()..[[.

On arrival search for and destroy the Rebel base.

Kameiros out.]])

end


-- message players with mission specific info, also add to ship log
function missionMessage(message_id, message)

  -- delay mission messages
  addDelayedCallback(timers, message_id, 5, function()

    for player_ship_keys, player_ship in ipairs(player_ships) do

    -- print("missionMessage:")
    -- print("Relay  = " .. tostring(player_ship:hasPlayerAtPosition("relayOfficer")))
    -- print("Operations  = " .. tostring(player_ship:hasPlayerAtPosition("operationsOfficer")))
    -- print("single  = " .. tostring(player_ship:hasPlayerAtPosition("singlePilot")))

    if (player_ship:hasPlayerAtPosition("Relay")) then
      playSoundFile("chirp.ogg")
      player_ship:addCustomMessage("Relay",message_id, message)
      player_ship:addToShipLog("["..human_station:getCallSign().."] "..message, "Yellow")
    elseif (player_ship:hasPlayerAtPosition("Operations")) then
      playSoundFile("chirp.ogg")
      player_ship:addCustomMessage("Operations",message_id, message)
      player_ship:addToShipLog("["..human_station:getCallSign().."] "..message, "Yellow")
    elseif (player_ship:hasPlayerAtPosition("single")) then
      playSoundFile("chirp.ogg")
      player_ship:addCustomMessage("single",message_id, message)
      player_ship:addToShipLog("["..human_station:getCallSign().."] "..message, "Yellow")
    else
      addDelayedCallback(timers, message_id .. '-delayed', 5, function()
        missionMessage(message_id, message)
      end)
    end

  end

  end)

end

function update(delta)
  -- cp scripts/* ./EmptyEpsilon.app/Contents/Resources/scripts/ && cp scripts/* ~/Dropbox/ee-dist/EmptyEpsilon.app/Contents/Resources/scripts/ && EmptyEpsilon.app/Contents/MacOS/EmptyEpsilon

  -- print("update = " .. current_act .. " tick = " .. delta)

  timers = tick(timers, delta)

  -- acti independent stuff
  if current_act > 0 then
    generic_behaviour(current_act)
  end

  -- watch for starting act 1
  if (current_act == 0) then
    act_1()
  end

  -- act 1
  if (current_act == 1) then

    -- print("rebels_destroyed = " .. rebels_destroyed)
    -- print("rebel_deliveries = " .. rebel_deliveries)
    -- keep count of rebels destroyed and rebels delivered
    if rebels_destroyed + rebel_deliveries >= 6 then

      act_2() -- only switches act if messages can be sent to all players
    end

  end

  -- act 2
  if (current_act == 2) then

    -- check if the rebel station has been destroyed
    if not rebel_base:isValid() then
      act_3()
    end

    -- check for destroyed rebel ambush ships
    for ambush_ship_key, ambush_ship in ipairs(ambush_ships) do
      if ambush_ship and not ambush_ship:isValid() then
        ambush_ships_count = ambush_ships_count -1
        ambush_ships[ambush_ship_key] = nil
      end
    end

    -- if we have ambushs remaning and no ambush ships check for player ships within ambush area
    if ambush_waves > 0 and ambush_ships_count <= player_ship_count then

      -- iterate player ships and check distance
      for player_ship_keys, player_ship in ipairs(player_ships) do
        if distance(player_ship, rebel_base) < 20000 then

          -- spawn an ambush
          playSoundFile("decloak.ogg")
          if ambush_ships_count == 0 then
            ambush_waves = ambush_waves -1
            local ambush_x = 37794
            local ambush_y = 33117
            if random(1, 10) > 7 then
              local ambush_x = 29085
              local ambush_y = 399914
            elseif random(1, 10) > 7 then
              local ambush_x = 30493
              local ambush_y = 46403
            end
            ambush_x = ambush_x + random(-500, 500)
            ambush_y = ambush_y random(-500, 500)

            ambush_ships_count = ambush_ships_count + 2

            rebel_fighter1 = CpuShip():setFaction("Klingons"):setTemplate("Klingon Bird Of Prey"):setPosition(ambush_x,ambush_y):orderAttack(player_ship1):setCallSign(klingon_ship_names[klingon_ship_names_index])
            klingon_ship_names_index = klingon_ship_names_index + 1
            rebel_fighter2 = CpuShip():setFaction("Klingons"):setTemplate("Klingon Bird Of Prey"):setPosition(ambush_x+500,ambush_y+500):orderAttack(player_ship1):setCallSign(klingon_ship_names[klingon_ship_names_index])
            klingon_ship_names_index = klingon_ship_names_index + 1

            table.insert(ambush_ships, rebel_fighter1)
            table.insert(ambush_ships, rebel_fighter2)
            if player_ship_count == 2 then
              ambush_ships_count = ambush_ships_count + 1
              rebel_fighter3 = CpuShip():setFaction("Federation Sepratists"):setTemplate("Klingon Bird Of Prey"):setPosition(ambush_x-500,ambush_y+500):orderAttack(player_ship2):setCallSign(klingon_ship_names[klingon_ship_names_index])
              klingon_ship_names_index = klingon_ship_names_index + 1
              table.insert(ambush_ships, rebel_fighter3)
            elseif player_ship_count == 3 then
              ambush_ships_count = ambush_ships_count + 2
              rebel_fighter3 = CpuShip():setFaction("Federation Sepratists"):setTemplate("Klingon Bird Of Prey"):setPosition(ambush_x-500,ambush_y+500):orderAttack(player_ship3):setCallSign(klingon_ship_names[klingon_ship_names_index])
              klingon_ship_names_index = klingon_ship_names_index + 1
              rebel_fighter4 = CpuShip():setFaction("Federation Sepratists"):setTemplate("Klingon Bird Of Prey"):setPosition(ambush_x+500,ambush_y-500):orderAttack(player_ship3):setCallSign(klingon_ship_names[klingon_ship_names_index])
              klingon_ship_names_index = klingon_ship_names_index + 1
              table.insert(ambush_ships, rebel_fighter3)
              table.insert(ambush_ships, rebel_fighter4)
            end
          end

        end
      end
    end


  end

  -- act 3
  if (current_act == 3) then

    -- check for no klingon ships
    local klingon_ship_count = 0
    for klingon_ship_key, klingon_ship in ipairs(klingon_ships) do
      if klingon_ship and klingon_ship:isValid() then
        klingon_ship_count = klingon_ship_count + 1
      end
    end

    if klingon_ship_count == 0 then
      victory("Starfleet")
    end

  end



  collectgarbage()
end
