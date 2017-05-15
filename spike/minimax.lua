
local function evaluateLine(value1, value2, value3)
      local score = 0;

      -- First cell
      if (value1 == 1) then
         score = 1;
      elseif (value1 == -1) then
         score = -1;
      end

      -- Second cell
      if (value2 == 1) then
         if (score == 1) then -- cell1 is mySeed
            score = 10;
         elseif (score == -1) then -- cell1 is oppSeed
            return 0;
         else -- cell1 is empty
            score = 1;
         end
      elseif (value2 == -1) then
         if (score == -1) then -- cell1 is oppSeed
            score = -10;
         elseif (score == 1) then -- cell1 is mySeed
            return 0;
         else -- cell1 is empty
            score = -1;
         end
      end

      -- Third cell
      if (value3 == 1) then
         if (score > 0) then -- cell1 and/or cell2 is mySeed
            score = score * 10;
         elseif (score < 0) then -- cell1 and/or cell2 is oppSeed
            return 0;
         else -- cell1 and cell2 are empty
            score = 1;
         end
      elseif (value3 == -1) then
         if (score < 0) then -- cell1 and/or cell2 is oppSeed
            score = score * 10;
         elseif (score > 1) then -- cell1 and/or cell2 is mySeed
            return 0;
         else -- cell1 and cell2 are empty
            score = -1;
         end
      end
      return score;
   end

local function obterFilhos(node, piece)
  local unpack = table.unpack or unpack
  local childen = {}
  for index, content in ipairs(node) do
    if content == 0 then
      -- print(index)
      local child = {unpack(node)}
      child[index] = piece
      childen[#childen+1]=child
    end
  end
  return childen
end

local function getMap()
  return {
    {{2,3},{4,7},{5,9}},
    {{1,3},{5,8}},
    {{1,2},{6,9},{5,7}},
    {{1,7},{5,6}},
    {{1,9},{2,8},{3,7},{4,6}},
    {{3,9},{4,5}},
    {{1,4},{3,5},{8,9}},
    {{2,5},{7,9}},
    {{1,5},{3,6},{7,8}},
  }
end

local function getMap2()
  return {
    {{2,3},{4,7},{5,9}},
    {{5,8}},
    {{6,9},{5,7}},
    {{5,6}},
    {},
    {},
    {{8,9}},
    {},
    {},
  }
end

local function getHeuritica2(node)
  local score = 0;
  score = score + evaluateLine(node[1],node[2],node[3])
  score = score + evaluateLine(node[4],node[5],node[6])
  score = score + evaluateLine(node[7],node[8],node[9])
  score = score + evaluateLine(node[1],node[4],node[7])
  score = score + evaluateLine(node[2],node[5],node[8])
  score = score + evaluateLine(node[3],node[6],node[9])
  score = score + evaluateLine(node[1],node[5],node[9])
  score = score + evaluateLine(node[2],node[5],node[7])
  return score;
end

local function avalia(value, max)
  if max then
    return (value == 1 and 1) or 0
  else
    return (value == 2 and 1) or 0
  end
end

local function isBreak(value, max)
  if max then
    return value == 2
  else
    return value == 1
  end
end

local function getPeso(value, max)
  if max then
    return ((value == 0) and 0) or (1 * (10^value))
  else
    return ((value == 0) and 0) or (-1 * (10^value))
  end
end

local function getHeuritica(node,max)
  local map = getMap()
  local totalValue = 0
  for index, content in ipairs(node) do
    local point = avalia(content, max)
    local pointValue = 0
    local dValue
    for _, direction in ipairs(map[index]) do
      dValue = point
      for _, c in ipairs(direction) do
        local piece = avalia(node[c], max)
        if isBreak(node[c], max) then
          dValue = 0;
          break
        else
          dValue = dValue + piece
        end
      end
      -- print("dValue", dValue)
      pointValue = pointValue + getPeso(dValue,max)
    end
    -- print(index, pointValue)
    totalValue = totalValue + pointValue
  end
  --print(totalValue)
  -- print('total', totalValue)
  return totalValue
end

local function countZeros(node)
local count = 0
  for _, content in ipairs(node) do
    if content == 0 then
      count = count + 1
    end
  end
  return count
end

local function utilidade(node, max)
  local map = getMap2()
  for index, content in ipairs(node) do
    --if (index > 4) then return false end
    local point = (content == 0 and 0) or (content == 1 and 1) or -1
    for _, direction in ipairs(map[index]) do
      local dValue = point
      for _, c in ipairs(direction) do
        local piece = ((node[c] == 0) and 0) or ((node[c] == 1) and 1) or -1
        dValue = dValue + piece
      end
      if max then
        if (dValue == 3) then
          -- print(table.concat(node), true)
          return countZeros(node)
        end
      else
        if (dValue == -3) then
          -- print(table.concat(node), false)
          return countZeros(node)
        end
      end
    end
  end
  return false
end

local function isFinal(node)
  for _, content in ipairs(node) do
    if content == 0 then return false end
  end
  return true
end

local function hasVictory(node,max)
  return (utilidade(node,max))
end

local function minimax(node, depth, alfa, beta, maximizingPlayer)
  -- print('alfa, beta',alfa, beta,maximizingPlayer)
  if depth == 0 or isFinal(node, maximizingPlayer) then
    -- print(table.concat(node))
    return getHeuritica(node,maximizingPlayer)
  elseif hasVictory(node, maximizingPlayer) then
    --print(utilidade(node,maximizingPlayer))
    return getPeso(utilidade(node,maximizingPlayer),maximizingPlayer)
  end

  if maximizingPlayer then
    local v = -1000000000
    local childen = obterFilhos(node,2)
    for _, child in ipairs(childen) do
      v = math.max(v, minimax(child, (depth - 1), alfa, beta, false))
      alfa = math.max(alfa, v)
      if beta <= alfa then
        break --(* beta cut-off *)
      end
    end
    return alfa
  else
    local v = 1000000000
    local childen = obterFilhos(node,1)
    for _, child in ipairs(childen) do
      v = math.min(v, minimax(child, (depth - 1), alfa, beta, true))
      beta = math.min(beta, v)
      if beta <= alfa then
        break --(* alfa cut-off *)
      end
    end
    return beta
  end
end


local node = {2,0,0,
              2,1,0,
              0,0,1}
local depth = 4
local alfa = -1000000000
local beta = 1000000000
local maximizingPlayer = true

-- print(minimax(node,depth,alfa,beta,maximizingPlayer))
for _, child in ipairs(obterFilhos(node,1)) do
  print('--',_)
  print(minimax(child,depth,alfa,beta,maximizingPlayer))
  -- break
end