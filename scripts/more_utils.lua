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
