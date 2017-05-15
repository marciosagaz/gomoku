---@module List

-----------------------
--[ import modules ]
-----------------------

local Util = require "util"
local Config = require "configuration"
local Buffer = require "gomoku_buffer"
local View = require "gomoku_view"
local engine = require "engine"
local math = math;
local State = {}

-----------------------
--[ private functions ]
-----------------------

local behavior = {
		__eq = function (state1,state2)
			return state1.match[state2.id]
		end
}

local function rule(first,second)
  return first.cost == second.cost
		and first.state.level < second.state.level
		or first.cost < second.cost
end

local function heuristic(self,state)
	local cost, coord = 0, self.coordinate
	if Config.HEURISTIC.MANHATTAN then
		local startmap, finalmap = state.map, self.final.map
		local abs = math.abs
		local s, f
		for index=1, self.size*self.size, 1 do
			s = coord[startmap[index]]
			f = coord[finalmap[index]]
			cost = cost + abs(s.x - f.x) + abs(s.y - f.y)
		end
	elseif Config.HEURISTIC.OUT_OF_PLACE then
		for index, content in pairs(state.map) do
			if self.final.map[index] ~= content then cost = cost + 1 end
		end
	end
	return cost
end

local function calculateState(self,state)
	return state.level + heuristic(self,state)
end

local function createNewState(state, id, match)
	local unpack = table.unpack or unpack
	return Util.createBehavior({
			map={unpack(state.map)},
			level=(state.level+1),
			id= id or 0,
			match= match or {}
		},behavior)
end


-----------------------
--[ public functions ]
-----------------------

function State:new()
	local instance = {}
	local initialId = table.concat(Config.INITIAL,',')
	local finalId = table.concat(Config.FINAL,',')
	self.__index = State
	setmetatable(instance, self)
	instance.initial = createNewState({map=Config.INITIAL, level=-1}, initialId, {[initialId]=true})
	instance.final = createNewState({map=Config.FINAL, level=-1}, finalId, {[finalId]=true})
	instance.size = Config.SIZE
	instance.coordinate = Util.getCartesianPlane(Config.SIZE)
	instance.routes = Util.getRoutesOfCartesianPlane(Config.SIZE,instance.coordinate)
	instance.emptySpace = Config.SIZE*Config.SIZE
	instance.view = View:new(Config.SIZE)
	instance.visited = {}
	instance.frontier = Buffer:new()
	return instance
end

function State.start()
	engine.start(State:new())
end

function State:setup()
	self.timestart = os.time()
	local seed = { state=self.initial, cost=calculateState(self,self.initial) }
	self.frontier:insert(seed)
  self.visited[seed.state.id] = {level=0}
	self.target = { state=self.final, cost=calculateState(self,self.final) }
	self.counter = 1
end

function State:isFinal()
		return self.frontier:isEmpty()
end

function State:next()
		self.node = self.frontier:remove(1)
		self:register()
end

function State:expandFrontier()
  local state = self.node.state;
	local oldPositionOfEmptySpace = Util.findContent(state.map,self.emptySpace)
	local routes = self.routes[oldPositionOfEmptySpace]
	for _, newPositionOfEmptySpace in ipairs(routes) do
	  local newState = createNewState(state)
		newState.map[newPositionOfEmptySpace] = state.map[oldPositionOfEmptySpace]
		newState.map[oldPositionOfEmptySpace] = state.map[newPositionOfEmptySpace]
		local id = table.concat(newState.map,',')
		if not self.visited[id] then
			newState.id = id
			newState.match[newState.id]=true
			self.visited[newState.id] = {parentId=state.id, level=newState.level}
			self.frontier:insertByRule({ state=newState, cost=calculateState(self,newState) }, rule)
		elseif self.visited[id].level > newState.level then
			newState.id = id
			newState.match[newState.id]=true
			self.visited[newState.id] = {parentId=state.id, level=newState.level}
			self.frontier:insertByRule({ state=newState, cost=calculateState(self,newState) }, rule)
		end
	end
	self.counter = self.counter + 1
end

function State:register()
	local node = self.node
	self.view.log(node.state.id, node.cost, node.state.level, self.counter, #self.frontier.list)
end

function State:isTarget()
	return self.node.state == self.target.state
end

function State:setToTarget()
	self.view:show({
		success=true,
		msg="Sucesso em buscar a resposta! ",
		node=self.node,
		steps=self.visited,
		frontier=self.counter+#self.frontier.list,
		time='time: ' .. os.time()-self.timestart
	})
end

function State:setToFinal()
  self.view:show({
		success=false,
		msg="Falhou em buscar a resposta! Fronteira está vazia!"
  })
end

return State