-- Name: Trader/Smuggler ship comms
-- Description: Allows player to force the ship to be stopped and searched,
-- when marines are sent (cargo=boarding) the mission must be responsible
-- for waiting for comms to be inactive then switching the cargo to ok or
-- contraband and sending a comms message back.
-- the mission could then switch the ship to run etc. instead!

function rebelComms()
  setCommsMessage("We're not interested in anything you have to say "..comms_source:getCallSign());
end


function stoppedMenu()

  if (comms_target.comms_data['cargo'] == nil) then

    -- if close, now allow marines to board
    if (range < 3000) then

      addCommsReply("Transporting an away team to check your cargo "..comms_target:getCallSign(), function()

        comms_target.comms_data['cargo'] = 'boarding'
        setCommsMessage([[Roger, will comply. ]]..comms_target:getCallSign()..[[ out.]]);

      end)

    else
      -- not close enough, so break-off comms until closer
      addCommsReply("Standby for our approach to transporter range, "..player:getCallSign().." out", function()

        setCommsMessage("Roger "..player:getCallSign()..", "..comms_target:getCallSign().." out");
      end)

    end

  elseif (comms_target.comms_data['cargo'] == 'boarding') then

    setCommsMessage("Standing by for your away team "..player:getCallSign()..", "..comms_target:getCallSign().." out.");

  elseif (comms_target.comms_data['cargo'] == 'checking') then

    setCommsMessage("Away team report they are aboard the "..comms_target:getCallSign().." and conduction a cargo inspection, please be patient.");

  end

  -- always allow them to Continue
  addCommsReply("Go on your way "..comms_target:getCallSign()..", "..player:getCallSign().." out", function()

    -- reward the player for sending them on their way
    if (comms_target.comms_data['cargo'] == 'ok') then
      comms_target:setImpulseMaxSpeed(random(70, 75))
      comms_target.comms_data['cargo'] = 'ok-rewarded'
      player:addReputationPoints(12)
      player:addToShipLog("[REPUTATION] Trader cargo checked, reward 12 reputation.", "Green")
    elseif (comms_target.comms_data['cargo'] == 'contraband') then
      comms_target:setImpulseMaxSpeed(random(60, 65))
      comms_target.comms_data['cargo'] = 'ok-rewarded'
      player:addReputationPoints(24)
      player:addToShipLog("[REPUTATION] Smuggler cargo checked, reward 24 reputation.", "Green")
    end

    comms_target.comms_data['state'] = comms_target.comms_data['original_state']
    comms_target.comms_data['stopped_by'] = nil
    -- comms_target.comms_data['cargo'] = nil
    comms_target:orderFlyTowards(comms_target.comms_data['destination']:getPosition())

    setCommsMessage("Thank you "..player:getCallSign()..", "..comms_target:getCallSign().." out");

  end)

end

-- check chance of running (dependent on type)
function willRun(trader)

  local rnd = random(1, 10)

  if (trader.comms_data['type'] == 'trader') then
    return (rnd > 3)
  elseif (trader.comms_data['type'] == 'smuggler') then
    return (rnd > 3)
  elseif (trader.comms_data['type'] == 'rebel') then
    return (rnd > 3)
  else
    return false
  end
end


function mainMenu()

  -- range is important
  range = distance(comms_target, player)

  -- depends on state
  if (comms_target.comms_data['state'] == 'running') then

    if (range < 3000) then

      -- sensibly stop for you
      comms_target.comms_data['state'] = 'stopped'
      comms_target.comms_data['stopped_by'] = player:getCallSign()
      comms_target:orderIdle()

      setCommsMessage("Ok, Ok! We're standing down. Send your thugs aboard when you're close enough "..player:getCallSign()..".");
      stoppedMenu()

    else
      setCommsMessage("Give up the chase "..player:getCallSign()..", you'll never catch us!");
      addCommsReply("Continue chasing.", mainMenu)

    end

  elseif (comms_target.comms_data['state'] == 'stopped') then

    if (comms_target.comms_data['cargo'] ~= nil and (comms_target.comms_data['cargo'] == 'ok' or comms_target.comms_data['cargo'] == 'contraband')) then
      setCommsMessage("Standing by for clearance to leave "..player:getCallSign()..".");
      stoppedMenu()
    else
      setCommsMessage("We're holding position for you "..player:getCallSign()..", in your own time.");
      stoppedMenu()
    end

  else -- is neither running or stopped

    setCommsMessage("This is "..comms_target:getCallSign()..", what do you want "..player:getCallSign().."?")

    if (comms_target.comms_data['cargo'] ~= nil and (comms_target.comms_data['cargo'] == 'ok-rewarded' or comms_target.comms_data['cargo'] == 'ok' or comms_target.comms_data['cargo'] == 'contraband')) then

      setCommsMessage("You've already checked us "..player:getCallSign()..", give us a break!");

    else
      -- request stop
      addCommsReply("Hold position while we approach.", function()

        -- sometimes they run!
        if (willRun(comms_target)) then

          comms_target.comms_data['original_state'] = comms_target.comms_data['state']
          comms_target.comms_data['state'] = 'running'
          comms_target.comms_data['chased_by'] = player:getCallSign()

          -- work out a position a long way, immediately away from the player
          local player_x, player_y = player:getPosition()
          local trader_x, trader_y = comms_target:getPosition()
          local angle = angleFromVector(player_x, player_y, trader_x, trader_y)
          local run_x, run_y = vectorFromAngle(angle, 100000)

          -- make it fast as well player ships max is 90 (except fighters)
          comms_target:setImpulseMaxSpeed(random(80, 100))
          comms_target:orderFlyTowards(run_x, run_y)

          local range = distance(comms_target, player)

          -- rebels who are close will always reveal
          if comms_target.comms_data['type'] == 'rebel' and range < 10000 then
            -- change faction and scan
              comms_target:setFaction("Federation Sepratists")
              comms_target:setCommsFunction(rebelComms)
              comms_target:setScannedByFaction("Starfleet", true)

              -- beef up rebel ships with some weapons
              comms_target:setShields(55, 55)
              comms_target:setBeamWeapon(0, 45, 0, 1000, 8, 6)
              comms_target:setWeaponTubeCount(1) -- Amount of torpedo tubes, and loading time of the tubes.
              comms_target:setWeaponTubeDirection(0, 0):setWeaponTubeExclusiveFor(0, "HVLI")
              comms_target:setWeaponStorageMax("HVLI", 5)
              comms_target:setWeaponStorage("HVLI", random(1, 5))

              comms_target.comms_data['loading'] = true
              comms_target.comms_data['loaded'] = false
              comms_target:orderAttack(player)

              setCommsMessage("Long live the Rebellion!");
          else
            setCommsMessage("Go to hell "..player:getCallSign().."! We're just trying to make a living!");
          end

        else
          -- sensibly stop for you
          comms_target.comms_data['original_state'] = comms_target.comms_data['state']
          comms_target.comms_data['state'] = 'stopped'
          comms_target.comms_data['stopped_by'] = player:getCallSign()
          comms_target:orderIdle()

          setCommsMessage("Roger "..player:getCallSign()..", holding position.");

          stoppedMenu()
        end

      end)
    end

  end

  return true
end
mainMenu()
