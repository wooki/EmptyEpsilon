-- given a vector (relative to a 0,0 point) what is the angle in degrees
--
-- AngleFromVector(x, y)
--   dx: delta between the x position of two objects
--   dy: delta between the y position of two objects
--
-- Example: For an object 1000 units away to the East you would call with
-- AngleFromVector(1000, 0) and it would return an Angle of 90 degrees
function angleFromVector(x1, y1, x2, y2)
    return (math.atan2(x2, y2) - math.atan2(x1, y1) ) * 180 / math.pi
end

-- util for shuffling a table into a random order
function shuffle(tbl)
  local size = #tbl
  for i = size, 1, -1 do
    local rand = math.random(size)
    tbl[i], tbl[rand] = tbl[rand], tbl[i]
  end
  return tbl
end

function table_print(tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, key .. " = {\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end