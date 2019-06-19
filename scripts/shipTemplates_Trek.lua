--[[ Stations --]]
template = ShipTemplate():setName("Romulan Station"):setModel("space_station_8"):setType("station")
template:setHull(120)
template:setShields(250)
template:setRadarTrace("radar_st-rom.png")

template = ShipTemplate():setName("Klingon Station"):setModel("space_station_8"):setType("station")
template:setHull(120)
template:setShields(250)
template:setRadarTrace("radar_st-kli.png")

template = ShipTemplate():setName("Regula Station"):setModel("space_station_7"):setType("station")
template:setHull(120)
template:setShields(250)
template:setRadarTrace("radar_st-fed.png")

template = ShipTemplate():setName("Terok Nor"):setModel("space_station_6"):setType("station")
template:setHull(300)
template:setShields(800, 800, 800)
template:setRadarTrace("radar_st_ds9.png")

template = ShipTemplate():setName("Starbase"):setModel("space_station_5"):setType("station")
template:setHull(500)
template:setShields(800, 800, 800, 800)
-- template:setRadarTrace("radar_st-rom.png")
-- template:setRadarTrace("radar_st_station.png")
template:setRadarTrace("earth_spacedock.png")


-- ================
template = ShipTemplate():setName("Defiant Class"):setClass("Frigate", "Cruiser: Anti-fighter"):setModel("Defiant"):setType("playership")
template:setDescription([[Small, Fast and Armed to the teeth. The Defiant Class starship was instrumental in the Dominon Wars at DS9 ]])
--                 ID Number, Arc, Dir, Range, CycleTime, Dmg
template:setRadarTrace("radar_st-defiant.png")
template:setBeam(0, 40, 0, 1200.0, 2, 4)
template:setBeam(1, 40, 180, 800.0, 4, 4)

template:setTubes(2, 10) -- Amount of torpedo tubes, and loading time of the tubes.
template:setHull(200)
template:setShields(80, 80)
template:setSpeed(95, 20, 20)
template:setWarpSpeed(1000)
template:setJumpDrive(false)
template:setCloaking(true)
template:setWeaponStorage("Homing", 0)
template:setWeaponStorage("Nuke", 0)
template:setWeaponStorage("Mine", 3)
template:setWeaponStorage("EMP", 0)
template:setWeaponStorage("HLVI", 20)
template:setTubeDirection(0, 0):setWeaponTubeExclusiveFor(1, "HLVI")
template:setTubeDirection(180, 0):setWeaponTubeExclusiveFor(1, "Mine")

--   01234  -X-
--    . | | .     0
--    | | | | |     1    Y
--    . | | .     2


-- AddRoom - X, Y, Length, Height
-- AddRoomSystem - X, Y, Length, Height, "System Name"
-- addDoor - X, Y, [Doors on top (true) / on right (false)]

-- ,"Maneuver"
-- ,"Impulse"
-- ,"MissileSystem"
-- ,"RearShield"
-- , "Warp"
-- , "JumpDrive"
-- ,"Reactor"
-- , "FrontShield"
-- , "BeamWeapons"


template:addRoomSystem(1, 0, 1, 1,"Maneuver");
template:addRoomSystem(2, 0, 1, 1, "BeamWeapons");



template:addRoomSystem(0, 1, 1, 1,"RearShield");
template:addRoomSystem(1, 1, 1, 1, "Warp");
template:addRoomSystem(2, 1, 1, 1, "JumpDrive");
template:addRoomSystem(3, 1, 1, 1,"Reactor");
template:addRoomSystem(4, 1, 1, 1, "FrontShield");
template:addRoomSystem(1, 2, 1, 1,"Impulse");
template:addRoomSystem(2, 2, 1, 1, "MissileSystem");

template:addDoor(1, 1, false);
template:addDoor(2, 1, false);
template:addDoor(3, 1, false);
template:addDoor(4, 1, false);

template:addDoor(1, 1, true);
template:addDoor(2, 1, true);
template:addDoor(2, 2, true);
template:addDoor(1, 2, true);






-- ================
template = ShipTemplate():setName("Constitution Refit"):setClass("Frigate", "Cruiser"):setModel("EnterpriseA"):setType("playership")
template:setDescription([[Upgraded Constitution Class Starship which was made famous by the crew of the Enterprise A]])
template:setRadarTrace("radar_st-fedship.png")
--template = ShipTemplate():setName("TSN Scout"):setModel("artemisscout"):setType("playership")
--                 ID Number, Arc, Dir, Range, CycleTime, Dmg

-- int index, float arc, float direction, float range, float cycle_time, float damage)
template:setBeam(0, 120, 0, 1200.0, 6.0, 12)

template:setHull(200)
template:setShields(100, 100)
template:setSpeed(90, 12, 20)
template:setWarpSpeed(800)
template:setJumpDrive(false)
template:setCloaking(false)
template:setCombatManeuver(100, 75)

template:setWeaponStorage("Homing", 12)
template:setWeaponStorage("Mine", 2)
template:setWeaponStorage("EMP", 2)
template:setWeaponStorage("HLVI", 0)
template:setTubes(3, 10.0)
template:setTubeDirection(0, 0):weaponTubeDisallowMissle(0, "Mine")
template:setTubeDirection(1, 0):weaponTubeDisallowMissle(1, "Mine")
template:setTubeDirection(2, 180):setWeaponTubeExclusiveFor(2, "Mine")

--   01234  -X-
--    . . | | |     0
--    | | | | |     1    Y
--    . . | | |     2


-- AddRoom - X, Y, Length, Height
-- AddRoomSystem - X, Y, Length, Height, "System Name"
-- addDoor - X, Y, [Doors on top (true) / on right (false)]

-- ,"Maneuver"
-- ,"Impulse"
-- ,"MissileSystem"
-- ,"RearShield"
-- , "Warp"
-- , "JumpDrive"
-- ,"Reactor"
-- , "FrontShield"
-- , "BeamWeapons"


-- 0, 0
-- 1, 0
template:addRoomSystem(2, 0, 1, 1,"Maneuver");
template:addDoor(3, 0,false);
template:addRoom(3, 0, 1, 1);
template:addDoor(4, 0,false);
template:addRoomSystem(4, 0, 1, 1, "BeamWeapons");


template:addRoomSystem(0, 1, 1, 1,"RearShield");
template:addDoor(1, 1, false);
template:addRoomSystem(1, 1, 1, 1, "Warp");
template:addDoor(2, 1, false);
template:addRoomSystem(2, 1, 1, 1, "JumpDrive");
template:addDoor(3, 1,true);
template:addDoor(3, 1, false);
template:addRoomSystem(3, 1, 1, 1,"Reactor");
template:addDoor(4, 1, true);
template:addRoomSystem(4, 1, 1, 1, "FrontShield");

-- 0, 2
-- 1, 2
template:addRoomSystem(2, 2, 1, 1,"Impulse");
template:addDoor(3, 2, false);
template:addDoor(3, 2, true);
template:addRoom(3, 2, 1, 1);
template:addDoor(4, 2, false);
template:addDoor(4, 2, true);
template:addRoomSystem(4, 2, 1, 1,"MissileSystem");

-- ================

template = ShipTemplate():setName("Galaxy Class"):setClass("Corvette", "Cruiser"):setModel("EnterpriseD"):setType("playership")
template:setDescription([[A large starship with over 1000 crew members]])
template:setRadarTrace("radar_st-galaxy.png")
--                 ID Number, Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 180, 0, 1200.0, 4.0, 14)
template:setBeam(1, 180,  180, 800.0, 4.0, 12)

template:setHull(250)
template:setShields(120, 120)
template:setSpeed(90, 10, 20)
template:setWarpSpeed(1000)
template:setJumpDrive(false)
template:setCloaking(false)
template:setCombatManeuver(100, 75)

template:setWeaponStorage("Homing", 16)
template:setWeaponStorage("Nuke", 4)
template:setWeaponStorage("Mine", 8)
template:setWeaponStorage("EMP", 6)
template:setWeaponStorage("HLVI", 0)

template:setTubes(3, 10.0)
template:setTubeDirection(0, 0):weaponTubeDisallowMissle(0, "Mine")
template:setTubeDirection(1, 0):weaponTubeDisallowMissle(1, "Mine")
template:setTubeDirection(2, 180):weaponTubeDisallowMissle(2, "Nuke")

--    0123456789  X

--    .,.,.,.,.,| | |                        0
--    .,.,.,.,| | | | |                       1
--    | | | | | | | | | |                    2
--    .,| | | | | | | | |                   3   Y
--    | | | | | | | | | |                    4
--    .,.,.,.,| | | | |                      5
--    .,.,.,.,.,| | |                        6



-- AddRoom - X, Y, Length, Height
-- AddRoomSystem - X, Y, Length, Height, "System Name"
-- addDoor - X, Y, [Doors on top (true) / on right (false)]

-- ,"Maneuver" +
-- ,"Impulse" +
-- ,"MissileSystem"
-- ,"RearShield" +
-- , "Warp" +
-- , "JumpDrive" +
-- ,"Reactor" +
-- , "FrontShield" +
-- , "BeamWeapons"


template:addRoomSystem(5, 0, 3, 1 ,"Maneuver"); -- Maneuver (3 across)
template:addRoom(4, 1, 2, 1); -- Hall (2 across)
template:addRoom(6, 1, 1, 5);  -- Long hall
template:addRoomSystem(7, 1, 2, 2, "BeamWeapons"); -- Beam Weapons (2 across, 2 down )
template:addRoom(0, 2, 1, 1);
template:addRoomSystem(1, 2, 1, 3,"RearShield"); -- Rear Shields (3 Down)
template:addRoomSystem(2, 2, 1, 3 , "Warp"); -- Warp (3 down)
template:addRoomSystem(3, 2, 1, 3, "JumpDrive"); -- Jump (3 down)
template:addRoomSystem(4, 2, 2, 3,"Reactor"); -- Reactor (2 across, 3 down )
template:addRoomSystem(9, 2, 1, 3, "FrontShield"); -- Front Shields (3 down)
template:addRoom(7, 3, 2, 1);
template:addRoom(0, 4, 1, 1);
template:addRoomSystem(7,4, 2, 2,"MissileSystem"); --MissileSystem (2down 2 across)
template:addRoom(4, 5, 2, 1); -- Hall (2 across)
template:addRoomSystem(5, 6, 3, 1,"Impulse"); -- (3 across)


template:addDoor(1, 2, false); --
template:addDoor(3, 2, false);
template:addDoor(6, 1, false);
template:addDoor(1, 4, false); --
template:addDoor(9, 3, false); --
template:addDoor(3, 4, false);
template:addDoor(2, 3, false);
template:addDoor(4, 3, false);
template:addDoor(6, 5, false);
template:addDoor(7, 3, false);

template:addDoor(6, 1, true);
template:addDoor(6, 6, true);
template:addDoor(7, 4, true);
template:addDoor(4, 2, true);
template:addDoor(5, 5, true);
template:addDoor(7, 3, true);


template = ShipTemplate():setName("Prometheus Class"):setClass("Corvette", "Cruiser"):setModel("Prometheus"):setType("playership")
template:setDescription([[A large starship that can split into 3 different warp capable ships. All decks have holographic generators.]])
template:setRadarTrace("radar_st-fedship.png")
--                 ID Number, Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 120, 0, 1200.0, 6.0, 12)
template:setBeam(1, 120,  180, 800.0, 6.0, 10)

template:setHull(180)
template:setShields(100, 100)
template:setSpeed(99, 10, 20)
template:setWarpSpeed(1000)
template:setJumpDrive(false)
template:setCloaking(false)
template:setWeaponStorage("Homing", 20)
template:setWeaponStorage("Nuke", 0)
template:setWeaponStorage("Mine", 5)
template:setWeaponStorage("EMP", 10)
template:setWeaponStorage("HLVI", 0)

template:setTubes(3, 10.0)
template:setTubeDirection(0, 0):weaponTubeDisallowMissle(0, "Mine")
template:setTubeDirection(1, 0):weaponTubeDisallowMissle(1, "Mine")
template:setTubeDirection(2, 180):setWeaponTubeExclusiveFor(2, "Mine")


--    0123456789012  X


--    .,| | | | | |                        0
--    | | | | | | | | | |                  1
--    | | | | | | | | | | | | |                 2   Y
--    | | | | | | | | | |                  3
--    .,| | | | | |                     4

-- AddRoom - X, Y, Length, Height
-- AddRoomSystem - X, Y, Length, Height, "System Name"
-- addDoor - X, Y, [Doors on top (true) / on right (false)]

-- ,"Maneuver" +
-- ,"Impulse" +
-- ,"MissileSystem"
-- ,"RearShield" +
-- , "Warp" +
-- , "JumpDrive" +
-- ,"Reactor" +
-- , "FrontShield" +
-- , "BeamWeapons"

template:addRoomSystem(2, 0, 3, 1 ,"Warp"); -- Warp (3 across)
template:addRoomSystem(6, 0, 1, 2 ,"MissileSystem");
template:addRoomSystem(6, 3, 1, 2 ,"BeamWeapons");
template:addRoomSystem(3, 1, 1, 3 ,"Maneuver"); -- Maneuver (3 down)
template:addRoomSystem(2, 1, 1, 3 ,"Impulse");
template:addRoomSystem(0, 2, 2, 1,"RearShield");
template:addRoomSystem(2, 4, 3, 1 ,"JumpDrive");
template:addRoomSystem(5, 2, 3, 1 ,"Reactor");
template:addRoomSystem(10, 2, 2, 1 ,"FrontShield");


template:addRoom(1, 1, 1, 1);
template:addRoom(1, 3, 1, 1);
template:addRoom(4, 1, 1, 3);
template:addRoom(5, 0, 1, 2);
template:addRoom(5, 3, 1, 2);
template:addRoom(7, 1, 2, 1);
template:addRoom(7, 3, 2, 1);
template:addRoom(8, 2, 2, 1);
-- Doors

template:addDoor(1, 2,true);
template:addDoor(1, 3,true);

template:addDoor(5, 0,false);
template:addDoor(6, 0,false);

template:addDoor(2, 1,true);
template:addDoor(2, 1,false);
template:addDoor(4, 1,false);
template:addDoor(5, 1,false);
template:addDoor(7, 1,false);

template:addDoor(3, 2,false);
template:addDoor(2, 4,true);

template:addDoor(2, 1,true);
template:addDoor(2, 3,false);
template:addDoor(5, 2,false);
template:addDoor(8, 2,true);
template:addDoor(8, 2,false);
template:addDoor(8, 3,true);
template:addDoor(10, 2,false);

template:addDoor(2, 3,false);
template:addDoor(4, 3,false);
template:addDoor(5, 3,false);
template:addDoor(7, 3,false);


template:addDoor(5, 4,false);
template:addDoor(6, 4,false);


-- =====================
-- Non Player ships (so far)

template = ShipTemplate():setName("Intrepid Class"):setClass("Frigate", "Cruiser"):setModel("intrepid")
template:setRadarTrace("radar_st-intrepid.png")
template:setDescription([[Smaller Starship with moving nacelles. USS Intrepid & USS Voyager]])
template:setHull(70)
template:setShields(60,60)
template:setSpeed(90, 15, 25)
template:setTubes(1, 15.0)
template:setWarpSpeed(800)
template:setWeaponStorage("Homing", 8)
template:setTubeDirection(0, 0):setWeaponTubeExclusiveFor(1, "Homing")
template:setBeam(0, 100, 0, 1200.0, 6.0, 7)
template:setBeam(1, 100, 180, 800.0, 6.0, 6)

-- =====================
-- =====================
-- independent

template = ShipTemplate():setName("Ferengi Marauder"):setClass("Frigate", "Cruiser"):setModel("ferengi-marauder")
template:setRadarTrace("radar_st-fer.png")
template:setDescription([[Species with a lust for Profit]])
template:setHull(50)
template:setShields(20)
template:setSpeed(60, 15, 25)
template:setTubes(1, 15.0)
template:setWeaponStorage("Homing", 5)
template:setTubeDirection(0, 0):setWeaponTubeExclusiveFor(1, "Homing")
template:setBeam(0, 90, 0, 600.0, 8.0, 6)

-- =====================
-- Enemies

template = ShipTemplate():setName("Borg Cube"):setClass("Borg", "Cube"):setModel("BorgCube")
template:setRadarTrace("RadarArrow.png")
template:setDescription([[Bio/Technology Hybrid made up of many species.]])
template:setHull(300)
template:setShields(300)
template:setSpeed(50, 50, 50)
template:setTubes(0, 15.0)
template:setBeam(0, 90, 0, 1000.0, 5.0, 10)
template:setBeam(1, 90, 90, 1000.0, 5.0, 10)
template:setBeam(2, 90,  180, 1000.0, 5.0, 10)
template:setBeam(3, 90,  270, 1000.0, 5.0, 10)


template = ShipTemplate():setName("Klingon Bird of Death"):setClass("Klingon", "Cruiser"):setModel("BirdOfDeath")
template:setRadarTrace("radar_st-klingonship.png")
template:setDescription([[Klingon]])
template:setHull(90)
template:setShields(200)
template:setSpeed(80, 15, 25)
template:setTubes(2, 15.0)
template:setWeaponStorage("Homing", 10)
template:setTubeDirection(1, 10):setWeaponTubeExclusiveFor(1, "Homing")
template:setTubeDirection(2,-10):setWeaponTubeExclusiveFor(2, "Homing")
template:setBeam(0, 80, 0, 1000.0, 7.0, 8)
template:setBeam(1, 80,  180, 800.0, 8.0, 6)


template = ShipTemplate():setName("Klingon Kvek"):setClass("Klingon", "Cruiser"):setModel("Kvek")
template:setRadarTrace("radar_st-klingonship.png")
template:setDescription([[Klingon]])
template:setHull(120)
template:setShields(200)
template:setSpeed(80, 15, 15)
template:setTubes(2, 12.0)
template:setWeaponStorage("Homing", 18)
template:setTubeDirection(1, 10):setWeaponTubeExclusiveFor(1, "Homing")
template:setTubeDirection(2,-10):setWeaponTubeExclusiveFor(2, "Homing")
template:setBeam(0, 80, -20, 1000.0, 10.0, 8)
template:setBeam(1, 80, 20, 1000.0, 10.0, 8)
template:setBeam(2, 80,  180, 800.0, 6.0, 8)

template = ShipTemplate():setName("Klingon Bloodwing"):setClass("Klingon", "Cruiser"):setModel("Bloodwing")
template:setRadarTrace("radar_st-klingonship.png")
template:setDescription([[Klingon]])
template:setHull(90)
template:setShields(150)
template:setSpeed(80, 15, 15)
template:setTubes(2, 15.0)
template:setWeaponStorage("Homing", 10)
template:setTubeDirection(1, 10):setWeaponTubeExclusiveFor(1, "Homing")
template:setTubeDirection(2,-10):setWeaponTubeExclusiveFor(2, "Homing")
template:setBeam(0, 80, 0, 1000.0, 7.0, 8)
template:setBeam(1, 80,  180, 800.0, 7.0, 8)

template = ShipTemplate():setName("Klingon Vorcha"):setClass("Klingon", "Cruiser"):setModel("Vorcha")
template:setRadarTrace("radar_st-klingonship.png")
template:setDescription([[Klingon]])
template:setHull(90)
template:setShields(200)
template:setSpeed(80, 15, 15)
template:setTubes(2, 15.0)
template:setWeaponStorage("Homing", 10)
template:setTubeDirection(1, 10):setWeaponTubeExclusiveFor(1, "Homing")
template:setTubeDirection(2,-10):setWeaponTubeExclusiveFor(2, "Homing")
template:setBeam(0, 80, 0, 1000.0, 8.0, 10)
template:setBeam(1, 60,  180, 800.0, 8.0, 10)


template = ShipTemplate():setName("Klingon Bird Of Prey"):setClass("Klingon", "Cruiser"):setModel("KlingBirdOfPrey")
template:setRadarTrace("radar_st-birdofprey.png")
template:setDescription([[Klingon]])
template:setHull(80)
template:setShields(90)
template:setSpeed(80, 25, 25)
template:setTubes(1, 20.0)
template:setWeaponStorage("Homing", 7)
template:setTubeDirection(1, 0):setWeaponTubeExclusiveFor(1, "Homing")
template:setBeam(0, 80, -20, 800.0, 8.0, 6)
template:setBeam(1, 80, 20, 800.0, 8.0, 6)
template:setBeam(1, 80,  180, 600.0, 5.0, 6)

template = ShipTemplate():setName("Romulan Warbird"):setClass("Romulan", "Cruiser"):setModel("Warbird")
template:setRadarTrace("radar_st-rom.png")
template:setDescription([[Romulan]])
template:setHull(80)
template:setShields(250)
template:setSpeed(50, 15, 25)
template:setTubes(3, 15.0)
template:setWeaponStorage("Homing", 30)
template:setTubeDirection(1, 1):setWeaponTubeExclusiveFor(1, "Homing")
template:setTubeDirection(2,-1):setWeaponTubeExclusiveFor(2, "Homing")
template:setBeam(0, 80, 0, 1000.0, 7.0, 10)
template:setBeam(1, 80,  180, 1000.0, 7.0, 10)

template = ShipTemplate():setName("Romulan Bird Of Prey"):setClass("Romulan", "Cruiser"):setModel("RomBirdOfPrey")
template:setRadarTrace("radar_st-rom.png")
template:setDescription([[Romulan]])
template:setHull(80)
template:setShields(100)
template:setSpeed(50, 15, 25)
template:setTubes(3, 15.0)
template:setWeaponStorage("Homing", 10)
template:setTubeDirection(1, 1):setWeaponTubeExclusiveFor(1, "Homing")
template:setTubeDirection(2,-1):setWeaponTubeExclusiveFor(2, "Homing")
template:setBeam(0, 80, 0, 500.0, 5.0, 6)
template:setBeam(1, 80,  180, 500.0, 5.0, 6)