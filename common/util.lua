local Util = {}

function Util.createBehavior(tab, behavior)
  behavior.__index = behavior
  setmetatable(tab,behavior)
  return tab
end

function Util.getCartesianPlane(size)
  local coordinates = {}
  for y=size, 1, -1 do
    for x=1, size, 1 do
      coordinates[#coordinates+1] = {x=x, y=y}
    end
  end
  return coordinates
end

function Util.getRoutesOfCartesianPlane(size, coordinate, steps,windrose)
  local routes, insert, sort = {}, table.insert, table.sort
  local ref1, ref2, route
  local function findCoordinate(x,y)
    for index, item in ipairs(coordinate) do
      if item.x == x and item.y == y then
      return index end
    end
  end
  for index, item in ipairs(coordinate) do
    route = {}
    for step=1, steps, 1 do
      if (windrose.E) then
        ref1 = item.x + step -- verifica o leste.
        if ref1 <= size then insert(route, findCoordinate(ref1,item.y)) end
      end
      if (windrose.W) then
        ref1 = item.x - step -- verifica o oeste.
        if ref1 >= 1 then insert(route, findCoordinate(ref1,item.y)) end
      end
      if (windrose.N) then
        ref2 = item.y + step -- verifica o norte
        if ref2 <= size then insert(route, findCoordinate(item.x, ref2)) end
      end
      if (windrose.S) then
        ref2 = item.y - step -- verifica o sul
        if ref2 >= 1 then insert(route, findCoordinate(item.x, ref2)) end
      end
      if (windrose.NE) then
        ref1 = item.x + step
        ref2 = item.y + step -- verifica o nordeste
        if ref1 <= size and ref2 <= size then insert(route, findCoordinate(ref1, ref2)) end
      end
      if (windrose.NW) then
        ref1 = item.x - step
        ref2 = item.y + step -- verifica o noroeste
        if ref1 >= 1 and ref2 <= size then insert(route, findCoordinate(ref1, ref2)) end
      end
      if (windrose.SE) then
        ref1 = item.x + step
        ref2 = item.y - step -- verifica o sudeste
        if ref1 <= size and ref2 >= 1 then insert(route, findCoordinate(ref1, ref2)) end
      end
      if (windrose.SW) then
        ref1 = item.x - step
        ref2 = item.y - step -- verifica o sudoeste
        if ref1 >= 1 and ref2 >= 1 then insert(route, findCoordinate(ref1, ref2)) end
      end
      sort(route)
      routes[index] = route
    end
  end
  return routes
end

function Util.findContent(tab,content)
  for index, item in ipairs(tab) do
    if item == content then
      return index;
    end
  end
end

function Util.printt(value,tab)
  tab = tab or ""
  if type(value) == 'table' then
    for index, content in pairs(value) do
      if type(content) == 'table' then
        print(tab, index)
        Util.printt(content,tab .. "\t")
      else
        print(tab,index,content)
      end
    end
  else
    print(value)
  end
end

return Util