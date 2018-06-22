local dialog = {
  ongoing = false,
  content = ''
}

local typewriter = 0
local lines = 2

-- Table elements
local elements = {}
elements[0] = {}
elements[1] = {}
elements[0][0] = "╔"
elements[0][1] = "╚"
elements[1][0] = "╗"
elements[1][1] = "╝"
elements['h'] = "═"
elements['v'] = "║" --║

function dialog:start(content)
  dialog.content = content
  dialog.ongoing = true
  typewriter = 0
end

function dialog:terminate()
  dialog.ongoing = false
end

function dialog:draw(view, worldCellText)
  local top = (view.size.h-lines-2)*view.unit
  
  -- first draw table box and elements
  love.graphics.setColor({0,0,0})
  love.graphics.rectangle("fill", 0, top, (view.size.w)*view.unit, (lines+2)*view.unit)
  
  love.graphics.setColor({0.75,0.75,0.75})
  worldCellText:set(elements[0][0])
  love.graphics.draw(worldCellText, 0, top)
  worldCellText:set(elements[0][1])
  love.graphics.draw(worldCellText, 0, (view.size.h-1)*view.unit)
  worldCellText:set(elements[1][0])
  love.graphics.draw(worldCellText, (view.size.w-1)*view.unit, top)
  worldCellText:set(elements[1][1])
  love.graphics.draw(worldCellText, (view.size.w-1)*view.unit, (view.size.h-1)*view.unit)
  
  for i = 1,view.size.w-2 do
    worldCellText:set(elements['h'])
    love.graphics.draw(worldCellText, i*view.unit, top)
    love.graphics.draw(worldCellText, i*view.unit, (view.size.h-1)*view.unit)
  end
  
  for i = top/view.unit+1, view.size.h-2 do
    worldCellText:set(elements['v'])
    love.graphics.draw(worldCellText, 0, i*view.unit)
    love.graphics.draw(worldCellText, (view.size.w-1)*view.unit, i*view.unit)
  end
  
  -- Draw text
  local skips = 0
  for i = 1, math.ceil(typewriter) do
    local x = (i-skips)*view.unit
    local y = top+view.unit
    local letter = string.sub(self.content, i, i)
    
    while (x > (view.size.w-2)*view.unit) do
      y = y + view.unit
      x = x - (view.size.w-2)*view.unit
    end
    
    local draw = true
    if (letter ~= " ") then
      worldCellText:set(letter)
    elseif (x ~= view.unit) then
      worldCellText:clear()
    else
      skips = skips +1 
      draw = false
    end
    
    if (draw) then
      love.graphics.draw(worldCellText, x, y)
    end
  end
  
end

function dialog:update(dt)
  if (typewriter < #self.content) then
    typewriter = typewriter + dt*20
  end
end

function dialog:getSentence(words)
  local wl = words.list
  local sl = words.sentences
  
  local string = string.gsub(sl[math.random(#sl)], "#", words.currentWord)
  
  return string
end

return dialog