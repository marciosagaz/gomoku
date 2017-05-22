---@module List

-----------------------
--[ import modules ]
-----------------------

local Util = require "util"
local Config = require "configuration"
local View = require "gomoku_view"
local engine = require "engine"
local math = math;
local State = {}

-----------------------
--[ private functions ]
-----------------------

local function getPeso(value, extra, max)
    if max then
      if value == 5 then
        return 400000000 + extra
      elseif value == 4 then
        return 3500000 + extra
      elseif value == 3 then
        return 23000 + extra
      elseif value == 2 then
        return 100 + extra
      elseif value == 1 then
        return 1 + extra
      else
        return extra
      end
    else
      if value == -5 then
        return -400000000 - extra
      elseif value == -4 then
        return -3500000 - extra
      elseif value == -3 then
        return -23000 - extra
      elseif value == -2 then
        return -100 - extra
      elseif value == -1 then
        return -1 - extra
      else
        return 0 - extra
      end
    end
end

local function countZeros(node, position)
  local count = 0
  for index, content in ipairs(node) do
      if content == 0 then
        count = count + 1
        if position and position == count then return index end
      end
  end
  return count
end

local function getInput(coordinate)
	local x, y
	print('Digite a posição x:')
	x = tonumber(io.read());
	print('Digite a posição y:')
	y = tonumber(io.read());
	for index, content in ipairs(coordinate) do
		if (content.x == x and content.y == y) then
			return index
		end
	end
end

local function getMapValue()
  local map = {
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,2,2,2,2,2,2,2,2,2,2,2,2,2,1,
    1,2,3,3,3,3,3,3,3,3,3,3,3,2,1,
    1,2,3,4,4,4,4,4,4,4,4,4,3,2,1,
    1,2,3,4,5,5,5,5,5,5,5,4,3,2,1,
    1,2,3,4,5,6,6,6,6,6,5,4,3,2,1,
    1,2,3,4,5,6,7,7,7,6,5,4,3,2,1,
    1,2,3,4,5,6,7,8,7,6,5,4,3,2,1,
    1,2,3,4,5,6,7,7,7,6,5,4,3,2,1,
    1,2,3,4,5,6,6,6,6,6,5,4,3,2,1,
    1,2,3,4,5,5,5,5,5,5,5,4,3,2,1,
    1,2,3,4,4,4,4,4,4,4,4,4,3,2,1,
    1,2,3,3,3,3,3,3,3,3,3,3,3,2,1,
    1,2,2,2,2,2,2,2,2,2,2,2,2,2,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
  }

  return map
end

-----------------------
--[ public functions ]
-----------------------

function State:new()
	local instance = {}
	local windrose = {E=true,W=false,S=true,N=false, NE=false, NW=false, SE= true, SW=true}
	local step = 4
	self.__index = State
	setmetatable(instance, self)
	instance.size = Config.SIZE
	instance.coordinate = Util.getCartesianPlane(Config.SIZE)
	instance.routes = Util.getRoutesOfCartesianPlane(Config.SIZE,instance.coordinate,step,windrose)
	instance.initial = Util.getEmptyMap(Config.SIZE)
	instance.view = View:new(Config.SIZE)
	instance.depth = 0
	instance.alfa = -100000000000
	instance.beta = 100000000000
	instance.maximizingPlayer = true
  instance.mapValue = getMapValue(Config.SIZE)
	return instance
end

function State.start()
	engine.start(State:new())
end

function State:setup(minimax)
	self.minimax = minimax
	self:play()
end

function State:play()
  local count = 0
	while not self:hasVictory(self.initial) do
    if (count == 1 or count == 10 or count == 15 or count == 20) then
      self.depth = self.depth + 1
      print('---------------------------------------------------',self.depth)
    end
    count = count + 1
		local position, best, value = 0
    if (self.depth ~= 0) then
      for index, child in ipairs(self:obterFilhos(self.initial,1)) do
        value = self.minimax(child,self.depth,self.alfa,self.beta,self.maximizingPlayer)
        print(value,index)
        best = math.max(value, best or value)
        if (best == value) then position = index end
      end
    else
      position = 113
    end
		position = countZeros(self.initial,position,self)
		print(position)
		self.initial[position] = 1
		self.view:draw(table.concat(self.initial,','))
    if (self:hasVictory(self.initial)) then break end
		position = getInput(self.coordinate)
		print(position)
		self.initial[position] = 2
		self.view:draw(table.concat(self.initial,','))
	end
end

function State:getHeuritica(node,maxi)
  local map = self.routes
  local totalValue = 0
  local cutPoint
  for index, content in ipairs(node) do
      local point = (content == 0 and 0) or (content == 1 and 1) or -1
      cutPoint = point
      local pointValue = 0
      local dValue
      for _, direction in ipairs(map[index]) do
        dValue = point
        for _, c in ipairs(direction) do
          local piece = (node[c] == 0 and 0) or (node[c] == 1 and 1) or -1
          if cutPoint == 0 then
            cutPoint = piece
            dValue = dValue + piece
          elseif cutPoint == 0 and piece == 0 then
            dValue = 0;
            break
          elseif ((cutPoint == 1 and piece == -1) or  (piece == 1 and cutPoint == -1)) then
            dValue = 0;
            break
          else
            dValue = dValue + piece
          end
        end
        pointValue = pointValue + getPeso(dValue,self.mapValue[index],maxi)
      end
      totalValue = totalValue + pointValue
  end
  return totalValue
end

function State:obterFilhos(node, piece)
  local unpack = table.unpack or unpack
  local childen = {}
  for index, content in ipairs(node) do
      if content == 0 then
        local child = {unpack(node)}
        child[index] = piece
        childen[#childen+1]=child
      end
  end
  return childen
end

function State:utilidade(node)
  local map = self.routes
  local lvalue = 0
  for index, content in ipairs(node) do
    local point = (content == 0 and 0) or (content == 1 and 1) or -1
    for _, direction in ipairs(map[index]) do
      if (point == 0) then break end
      local dValue = point
      for _, c in ipairs(direction) do
        local piece = ((node[c] == 0) and 0) or ((node[c] == 1) and 1) or -1
        dValue = dValue + piece
      end
      if (dValue == 5) then
          lvalue = 400000000
      elseif (dValue == -5) then
          lvalue = -400000000
      end
    end
  end
  return ((lvalue ~= 0) and lvalue) or false
end

function State.isFinal(node)
  for _, content in ipairs(node) do
    if content == 0 then return false end
  end
  return true
end

function State:hasVictory(node,max)
  local value = (self:utilidade(node,max))
	return value
end

return State