
local function run(control)
  control:setup()
  while(true) do
    
    -- obterDados()
  -- if avaliarDados()
    -- atualizaAlfaBeta()
  --     remove() ou poda()
  -- else
  --   expandePilha()
    if control:isFinal() then
      return control:setToFinal()
    end
    control:next()
    control:register();
    if control:isTarget() then
      return control:setToTarget()
    end
    control:expandFrontier()
  end
end

return { start=run }
