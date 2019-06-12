-- Name: Star Trek Glorious Battle
-- Description: Testing Star Trek Mod. Created from basic Mission. Variant None -  Use the USS Enterprise D 
-- Type: Basic
-- Variation[Enterprise Refit]: Use the USS Enterprise - Contitution Refit
-- Variation[Prometheus]: Use the USS Blackstone - Prometheus Class
-- Variation[Defiant]: Use the USS Defiant - Defiant Class



function init()
    startposrng=-4500
    endposrng=4500

    
    if getScenarioVariation() == "Defiant" then
		player = PlayerSpaceship():setFaction("Starfleet"):setTemplate("Defiant Class"):setCallSign("Defiant")
	elseif getScenarioVariation() == "Enterprise Refit" then
		player = PlayerSpaceship():setFaction("Starfleet"):setTemplate("Constitution Refit"):setCallSign("Enterprise")
	elseif getScenarioVariation() == "Prometheus" then
		player = PlayerSpaceship():setFaction("Starfleet"):setTemplate("Prometheus Class"):setCallSign("Blackstone")
	else
		player = PlayerSpaceship():setFaction("Starfleet"):setTemplate("Galaxy Class"):setCallSign("Enterprise")
		-- player = PlayerSpaceship():setFaction("Starfleet"):setTemplate("Constitution Refit"):setCallSign("Enterprise")
	end
    
    player:setWarpDrive(true):setShieldsActive(true)
    player:setPosition(random(startposrng, endposrng), random(startposrng, endposrng))
    
    player:addCustomButton("engineering", "CORE_DUMP", "Dump warp core", function()    
		-- Remove Warp drive from ship ("player")
		player:setWarpDrive(false)
		-- Send Message
		player:addCustomMessage("engineering", "CORE_MESSAGE", "Warp core has been dumped.")
		player:removeCustom("CORE_DUMP")
    end)
    


    
    planet1 = Planet():setPosition(7000, 7000):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
    moon1 = Planet():setPosition(7000, 0):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetSurfaceTexture("planets/moon-1.png"):setAxialRotationTime(200.0)
    sun1 = Planet():setPosition(7000, 17000):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,1.0)
    planet1:setOrbit(sun1, 2000)
    moon1:setOrbit(planet1, 1800.0)
    
    SpaceStation():setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setTemplate('Romulan Station'):setFaction("Romulan"):setRotation(random(0, 360)):setCallSign("Romulan Station")
    
    SpaceStation():setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setTemplate('Klingon Station'):setFaction("Klingon"):setRotation(random(0, 360)):setCallSign("Klingon Station")
    SpaceStation():setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setTemplate('Regula Station'):setFaction("Starfleet"):setRotation(random(0, 360)):setCallSign("Regula")
    SpaceStation():setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setTemplate('Terok Nor'):setFaction("Starfleet"):setRotation(random(0, 360)):setCallSign("DS9")
    SpaceStation():setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setTemplate('Starbase'):setFaction("Starfleet"):setRotation(random(0, 360)):setCallSign("Starbase 001")

  
    CpuShip():setTemplate("Ferengi Marauder"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Ferengi"):setCallSign("Ferengi"):orderRoaming()
    
    CpuShip():setTemplate("Defiant Class"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Starfleet"):setCallSign("Valiant"):orderRoaming()
    CpuShip():setTemplate("Prometheus Class"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Starfleet"):setCallSign("Prometheus"):orderRoaming()
    CpuShip():setTemplate("Constitution Refit"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Starfleet"):setCallSign("Constitution"):orderRoaming()
    CpuShip():setTemplate("Intrepid Class"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Starfleet"):setCallSign("Voyager"):orderRoaming()
    CpuShip():setTemplate("Intrepid Class"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Starfleet"):setCallSign("Voyager2"):orderRoaming()
    CpuShip():setTemplate("Galaxy Class"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Starfleet"):setCallSign("Galaxy"):orderRoaming()
    
    CpuShip():setTemplate("Klingon Bird of Death"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Klingons"):setCallSign("BoD"):orderRoaming()
    CpuShip():setTemplate("Klingon Kvek"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Klingons"):setCallSign("Kvek"):orderRoaming()
    CpuShip():setTemplate("Klingon Bloodwing"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Klingons"):setCallSign("Bloodwing"):orderRoaming()
    CpuShip():setTemplate("Klingon Vorcha"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Klingons"):setCallSign("Vorcha"):orderRoaming()
    CpuShip():setTemplate("Klingon Bird Of Prey"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Klingons"):setCallSign("Klingon BoP"):orderRoaming()
    
    CpuShip():setTemplate("Romulan Warbird"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Romulans"):setCallSign("Warbird"):orderRoaming()
    CpuShip():setTemplate("Romulan Bird Of Prey"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Romulans"):setCallSign("Rom BoP"):orderRoaming()
    
    CpuShip():setTemplate("Romulan Warbird"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Romulans"):setCallSign("Warbird2"):orderRoaming()
    CpuShip():setTemplate("Romulan Bird Of Prey"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Romulans"):setCallSign("Rom BoP2"):orderRoaming()
    
    CpuShip():setTemplate("Borg Cube"):setPosition(random(startposrng, endposrng), random(startposrng, endposrng)):setRotation(random(0, 360)):setFaction("Borg"):setCallSign("Cube 0001"):orderRoaming()
    
        for n=1,150 do
			Asteroid():setPosition(random(-50000, 50000), random(-50000, 50000)):setSize(random(100, 500))
			VisualAsteroid():setPosition(random(-50000, 50000), random(-50000, 50000)):setSize(random(100, 500))
        end
    
        for n=1,10 do
			Nebula():setPosition(random(-50000, 50000), random(-50000, 50000))
        end
    
    
    -- autorepair(0)
end

function autorepair(status)
    if status == 0 then
     player:addCustomButton("engineering", "AUTO_REPAIR_ON", "Auto Repair Enable", function()    
		player:removeCustom("AUTO_REPAIR_ON")
		player:commandSetAutoRepair(true)
     end)
    else 
     player:addCustomButton("engineering", "AUTO_REPAIR_OFF", "Auto Repair Disable", function()    
		player:removeCustom("AUTO_REPAIR_OFF")
		player:commandSetAutoRepair(false)
     end)
    end
end

function cleanup()
    --Clean up the current play field. Find all objects and destroy everything that is not a player.
    -- If it is a player, position him in the center of the scenario.
    for _, obj in ipairs(getAllObjects()) do
        if obj.typeName == "PlayerSpaceship" then
            obj:setPosition(random(-100, 100), random(-100, 100))
        else
            obj:destroy()
        end
    end
end

function update(delta)
	--No victory condition
end
