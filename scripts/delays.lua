require("more_utils.lua")

-- update timers
function tick(timers, delta)

    -- iterate timers and reduce by delta amount, any that hit zero are called and removed
    for name, timer in pairs(timers) do
      if (timer and timer['active'] and timer['delay'] > 0) then
       	timer['delay'] = timer['delay'] - delta
      	if (timer['delay'] <= 0) then
      		timer['callback']()
          timer['active'] = false
      	end
      end
    end

    return timers
end

-- add timer
function addDelayedCallback(timers, name, delay, callback)

  -- add to array (will replace same name)
  timers[name] = {
    name = name,
    delay = delay,
    callback = callback,
    active = true
	}

	return timers
end

