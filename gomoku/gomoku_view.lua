local Screen = {}

function Screen:new(size)
	local instance = {}
	self.__index = Screen
	setmetatable(instance, self)
  instance.size = size
  return instance
end

function Screen:draw(map)
  local output = {}
  local count = 0
  local size = self.size
  local dsize = size*size
  local tonumber = tonumber
  local big = size > 3
  for match in map:gmatch("([%d%.%+%-]+),?") do
    output[#output + 1] = '|' .. ((big and (tonumber(match) < 10) and '0'..match) or match)
    count = count + 1
    output[#output + 1] = ((count % size) == 0  and '|\n') or ''
  end
  local layout = table.concat(output)
  local repValue = (layout:len() / size) - 1
  print(("_"):rep(repValue) .. '\n' .. string.gsub(layout,
    tostring(dsize),big and '  ' or ' ') .. ("¨"):rep(repValue))
end

function Screen:show(result)
  local steps = {}
  if result.success then
    local parentId = result.node.state.id
    repeat
      table.insert(steps,1,parentId)
      parentId = result.steps[parentId].parentId
    until not parentId
  else
    print(result.msg)
    return
  end

  print(result.time)
  print(result.msg .. #steps - 1 .. ' passos')
  print("Na fronteira durante a execução! " .. result.frontier .. ' Nodos')
  for move, content in ipairs(steps) do
    print('move',move-1)
    self:draw(content)
    print("Enter to next move.")
    io.read()
  end
end

function Screen.log(map, cost, level, visited, novisited)
  print( 'map', map, 'cost', cost, 'level', level, 'visited', visited, 'novisited', novisited)
end

return Screen