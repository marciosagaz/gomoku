
local function run(control)
  control:setup()
  while(true) do
    if control:isFinal() then
      return control:setToFinal()
    end
    control:next()
    if control:isTarget() then
      return control:setToTarget()
    end
    control:expandFrontier()
  end
end

return { start=run }
