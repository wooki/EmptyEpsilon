
-- update timers
function tick(timers, delta)
	-- print("tick=" .. delta)
    -- iterate timers and reduce by delta amount, any that hit zero are called and removed
    for name, timer in ipairs(timers) do
      if (timer and timer['delay'] > 0) then
       print("timer=" .. timer['name'])
      	timer['delay'] = timer['delay'] - delta
      	print("timer " .. timer['name'] .. " = " .. timer['delay'])
      	if (timer['delay'] <= 0) then
      		timer['callback']()
      		timers[timer['name']] = nil
      	end
      end
    end
    return timers
end

-- add timer
function addDelayedCallback(timers, name, delay, callback)

	-- add to array
	table.insert(timers, {
	    name = name,
	    delay = delay,
	    callback = callback
  	})
  	return timers
end
