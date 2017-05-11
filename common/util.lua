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

function Util.getRoutesOfCartesianPlane(size, coordinate)
  local routes, insert, sort = {}, table.insert, table.sort
  local value, route
  local function findCoordinate(x,y)
    for index, item in ipairs(coordinate) do
      if item.x == x and item.y == y then
      return index end
    end
  end
  for index, item in ipairs(coordinate) do
    route = {}
    value = item.x + 1
    if value <= size then insert(route, findCoordinate(value,item.y)) end
      value = item.x - 1
    if value >= 1 then insert(route, findCoordinate(value,item.y)) end
      value = item.y + 1
    if value <= size then insert(route, findCoordinate(item.x, value)) end
      value = item.y - 1
    if value >= 1 then insert(route, findCoordinate(item.x, value)) end
    sort(route)
    routes[index] = route
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