local control

local function minimax(node, depth, alfa, beta, maximizingPlayer)
  control.iterationMax = control.iterationMax + 1
  if control:hasVictory(node, maximizingPlayer) then
    return control:utilidade(node,maximizingPlayer)
  elseif depth == 0 or control.isFinal(node, maximizingPlayer) then
    return control:getHeuritica(node,maximizingPlayer)
  end

  if maximizingPlayer then
    local v = -100000000000
    local childen = control:obterFilhos(node,2)
    for _, child in ipairs(childen) do
      v = math.max(v, minimax(child, (depth - 1), alfa, beta, false))
      alfa = math.max(alfa, v)
      if beta <= alfa then
        break --(* beta cut-off *)
      end
    end
    return alfa
  else
    local v = 100000000000
    local childen = control:obterFilhos(node,1)
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

local function run(_control)
  control = _control
  control:setup(minimax)
end

return { start=run }
