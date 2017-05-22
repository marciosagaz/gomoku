---@module Buffer

local Buffer = {}

function Buffer:new(array)
	local instance = {}
	setmetatable(instance, self)
	self.__index = Buffer
	instance.list = array or {}
	return instance
end

function Buffer:insert(item,position)
	table.insert(self.list,position or #self.list+1,item)
	return self
end

function Buffer:insertByRule(value, rule)
		local iStart, iEnd, iMid, iState, floor = 1, #self.list, 1, 0, math.floor
		while iStart <= iEnd do
			iMid = floor( (iStart+iEnd)/2 )
			if rule( value, self.list[iMid] ) then
				iEnd,iState = iMid - 1,0
			else
				iStart,iState = iMid + 1,1
			end
		end
		return self:insert(value,(iMid+iState))
	end

function Buffer:remove(position)
	position = position or #self.list
	return table.remove(self.list,position)
end

function Buffer:isEmpty()
	return #self.list == 0
end

function Buffer:getItem(position)
	position = position or #self.list
	return self.list[position]
end

-- function Buffer:sort(regra)
-- 	table.sort(self.list,regra)
-- 	return self
-- end

return Buffer