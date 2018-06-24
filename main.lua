io.stdout:setvbuf("no")

local utf8 = require("utf8")

local celltypes = require('celltypes')
local cellinfo = require('cellinfo')
local world = require("world")
local utils = require("utils")
local words = require("words")
local entity = require("entity")
local dialog = require("dialog")

require("perlin"):load()

local thisWorld,worldFont,worldCellText
local explorer = {}
local entities = {}
local view = {}
local theseWords = {}
local screens = 5 -- the world will be screens² sized

local chooseWord = true -- The player is still choosing the word, and not actually ingame
local typedWord = ''
local authorizedChars = "azertyuiopqsdfghjklmwxcvbn"
local displayLabel = true

-- debug elements 
local debugText,debugFont

-- On start
function love.load(arg)
  --if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
  
  -- View
  view.size = {w=15, h=15}
  view.unit = 16 -- Width/Height of a square unit (sprite) in pixels
  view.position = {x=0,y=0} -- Centered (?)
  
  -- Font setup
  worldFont = love.graphics.newFont("res/font/vga8.ttf", view.unit)
  worldCellText = love.graphics.newText(worldFont, "X")
  
  -- Window setup
  love.window.setMode(view.size.w*view.unit, view.size.h*view.unit, {fullscreen=false})
  
  -- Debug
  debugFont = love.graphics.newFont("res/font/tahoma.ttf", view.unit/2)
  debugText = love.graphics.newText(debugFont, "bonjour")
  
end

function love.textinput( text )
  if (chooseWord) then
    text = string.lower(text)
    if (string.len(typedWord) < 9 and 
        string.find(authorizedChars, text) ~= nil and
        string.find(authorizedChars, text) <= string.len(authorizedChars)
        ) then
      typedWord = typedWord..text
    end
  end
end

function love.keypressed(key)
  -- in v0.9.2 and earlier space is represented by the actual space character ' ', so check for both
  
  if (chooseWord) then
    if (key == "backspace") then
      typedWord = string.sub(typedWord, 1, string.len(tostring(typedWord))-1)
    elseif (key == "return") then
      chooseWord = false
      theseWords = words:new(typedWord)
      initializeGame()
      view:refreshView(thisWorld, explorer)
    end
    return
  end
  if (key == "right") then
    explorer:move({x=1,y=0})
    
  elseif (key == "left") then
    explorer:move({x=-1,y=0})
    
  elseif (key == "up") then
    explorer:move({x=0,y=-1})
    
  elseif (key == "down") then
    explorer:move({x=0,y=1})
    
  elseif (key == "escape") then
    os.exit()
    
  end
  
  view:refreshView(thisWorld, explorer)
  
end

function love.update(dt)
  
  --[[
  -- keyboard actions for our hero
  if love.keyboard.isDown("left") then
    hero.x = hero.x - hero.speed*dt
  elseif love.keyboard.isDown("right") then
    hero.x = hero.x + hero.speed*dt
  end

  --]]
  dialog:update(dt)
end

--- Game functions
function explorer:move(vec2_direction)
  
  local futurePosition = {x=vec2_direction.x+self.position.x, y=vec2_direction.y+self.position.y} 
  
  if (utils.clamp(1, thisWorld.size.w, futurePosition.x) ~= futurePosition.x or
      utils.clamp(1, thisWorld.size.h, futurePosition.y) ~= futurePosition.y) then
    return
  end
  
  local futureCell = thisWorld.map[futurePosition.x][futurePosition.y]
  
  if (cellinfo[futureCell].solid) then -- Return is facing a solid cell
    return
  end
  
  for k,v in pairs(entities) do
    local ent = v
    if (futurePosition.x == ent.position.x and
        futurePosition.y == ent.position.y) then
      if (not ent.pushable and ent.solid) then
        if (ent.dialog ~= "") then
          self:interact(futurePosition)
        end
        return  -- Return if facing an unpushable object
      end
      -- If pushable, let's check if the next cell is solid
      local nextPosition = {x=futurePosition.x+vec2_direction.x, y=futurePosition.y+vec2_direction.y}
      if (not thisWorld:inWorld(nextPosition)) then
         -- The player is trying to push object ouf of the map, swap them
        ent.position.x = explorer.position.x
        ent.position.y = explorer.position.y
        explorer.position.x = futurePosition.x
        explorer.position.y = futurePosition.y
        return 
      end
      local nextCell = thisWorld.map[nextPosition.x][nextPosition.y]
      local nextCellIsOccupied = false
      for l,w in pairs(entities) do
        if (w.position.x == nextPosition.x and
            w.position.y == nextPosition.y and
            w.solid and
            (
            ent.entityType ~= ent.types.key or
            w.entityType ~= ent.types.door
            )) then
          ent.position.x = explorer.position.x
          ent.position.y = explorer.position.y
          explorer.position.x = futurePosition.x
          explorer.position.y = futurePosition.y
          return
        end
      end      
    
      if (cellinfo[nextCell].solid or nextCellIsOccupied) then 
        if (nextCell == celltypes.water) then
          -- the player pushed it in the water!
          entities[k] = nil
          
          explorer.position.x = futurePosition.x
          explorer.position.y = futurePosition.y
          dialog:start("Oh!It's underwater now...")
          return
        end
         -- The player is trying to push object into solid - let's swap them
        ent.position.x = explorer.position.x
        ent.position.y = explorer.position.y
        explorer.position.x = futurePosition.x
        explorer.position.y = futurePosition.y
        return
      end
      
      -- If we managed to get up to here, it's time to push !
      if (ent.pushable) then
        ent.position = nextPosition
      end
    end
  end
  
  thisWorld:swapCells(futurePosition, self.position)
  thisWorld:affect(self.position)
  self.position = futurePosition
  dialog:terminate()
  displayLabel = false
  
  updateEntities(thisWorld, entities)
end



function explorer:interact(futurePosition)    
  if (dialog.ongoing) then
    dialog:terminate()
    return
  end
  for k,v in pairs(entities) do
    if (v.position.x == futurePosition.x and 
        v.position.y == futurePosition.y and 
        v.dialog ~= "") then
      dialog:start(v.dialog)
    end
  end
end

function explorer:on(pos) 
  if (pos.x == self.position.x and
      pos.y == self.position.y) then
    return true
  end
  return false
end

function updateEntities(thisWorld, entities)
  for k,v in pairs(entities) do
    local ent = v
    
    -- DOOR opening with KEY
    if (ent.entityType == entity.types.door) then
      for l,w in pairs(entities) do
        if (w.position.x == ent.position.x and
            w.position.y == ent.position.y and
            w.entityType == entity.types.key) then
          entities[k] = nil
          entities[l] = nil
          table.insert(entities, entity:new(entity.types.portal, w.position))
        end
      end
    end
    
    -- PORTAL next level
    if (ent.entityType == entity.types.portal and
        explorer:on(ent.position)) then
      warpTo(theseWords, theseWords:getNext())
    end
  end
end

function warpTo(theseWords, word)
  local seed = utils.wordInt(word)
  theseWords.currentWord = word
  initializeGame()
end

--- INITIALIZE GAME
function initializeGame()
  thisWorld = world:new({w=screens*view.size.w, h=screens*view.size.h}, utils.wordInt(theseWords.currentWord)) -- 
  math.randomseed(thisWorld.seed)
  
  -- Entities setup
  explorer.name = "Rackover"
  explorer.position = {x=math.floor(thisWorld.size.w/2),y=math.floor(thisWorld.size.h/2)+1}
  explorer.character = "☺"
  
  -- Entities
  entities = {}
  
  -- Create the door
  table.insert(entities, entity:new(entity.types.door, {x=explorer.position.x, y=explorer.position.y-1}))
  
  -- ((here for debugging only, creating a portal))
 
  -- Put keys in the world
  for i=1,3 do
    local pos = {x=math.random(thisWorld.size.w), y=math.random(thisWorld.size.h)}
    while (cellinfo[thisWorld.map[pos.x][pos.y]].solid) do
      pos = {x=math.random(thisWorld.size.w), y=math.random(thisWorld.size.h)}
    end
    table.insert(entities, entity:new(entity.types.key, pos))
  end
  
  -- Put npcs  in the world
  for i=1,1+math.random(4) do
    local pos = {x=math.random(thisWorld.size.w), y=math.random(thisWorld.size.h)}
    while (cellinfo[thisWorld.map[pos.x][pos.y]].solid) do
      pos = {x=math.random(thisWorld.size.w), y=math.random(thisWorld.size.h)}
    end
    table.insert(entities, entity:newVillager(pos, dialog:getSentence(theseWords)))
  end
 
  displayLabel = true
end

-------
-- Draw
-------

function love.draw()
  local w, h, flags = love.window.getMode( )
  
  love.graphics.clear()
  
  -- Draw background
  love.graphics.setColor(0,0,0,255)
  love.graphics.rectangle("fill", 0, 0, w, h)
  
  
  if (chooseWord) then
    local str = "Where do you want to go ?"
    local breaks = 0
    
    love.graphics.setColor(255,255,255)
    for i=1,#str do
      
      if (i*view.unit - (view.size.w)*view.unit*breaks > (view.size.w-2)*view.unit) then
        breaks = breaks+1
      end
      
      if (string.sub(str,i,i) ~= " ") then
        worldCellText:set(string.sub(str, i, i))
        love.graphics.draw(worldCellText, i*view.unit - (view.size.w-2)*view.unit*breaks, view.unit + breaks*view.unit)
      else
        worldCellText:clear()
      end
    end
    
    local str = ("=> "..tostring(typedWord))
    for i=1,#str do
      if (string.sub(str,i,i) ~= " ") then
        worldCellText:set(string.sub(str, i, i))
        love.graphics.draw(worldCellText, i*view.unit, view.unit*3 + breaks*view.unit)
      else
        worldCellText:clear()
      end
    end
    
    return
  end
  
  -- Draw gridcells on view  
  for x=view.position.x*view.size.w+1, (view.position.x+1)*view.size.w do
    for y=view.position.y*view.size.h+1, (view.position.y+1)*view.size.h do
      drawCell(thisWorld, {x=x, y=y}, view, worldCellText)
    end
  end
  
  -- Draw entities
  for k,v in pairs(entities) do
    drawEntity(v, view, worldCellText)
  end
  
  -- Draw player, always in last
  drawExplorer(explorer, view, worldCellText)
  
  -- Label 
  if (displayLabel) then
    drawLabel(theseWords.currentWord)
  end
  
  -- Hud elements
  if (dialog.ongoing) then
    dialog:draw(view, worldCellText)
  end
  
end


---- Draw functions
function view:refreshView(thisWorld, explorer)
  self.position = {
    x= math.floor(((explorer.position.x-1)/thisWorld.size.w)*(thisWorld.size.w/self.size.w)),
    y= math.floor(((explorer.position.y-1)/thisWorld.size.h)*(thisWorld.size.h/self.size.h))
  }
end

function drawLabel(str)
  
  local str = "One day,on your trip to        "..str.."..."
  
  if (math.floor(screens/2) == view.position.x and
      math.floor(screens/2) == view.position.y) then 
      
    -- Drawing label if player is not at the bottom of the screen
    local y=(explorer.position.y-view.position.y*view.size.h-1)
    
    if (y < view.size.h-3) then
      
      love.graphics.setColor(0,0,0)
      love.graphics.rectangle("fill", 0, (view.size.w-3)*view.unit, view.unit*view.size.w, 3*view.unit)
      love.graphics.setColor(255,255,255)
  
      local skips = 0
      
      for i=1,#str do
        
        local breaks = 0
        local pos = i
        
        while (pos > view.size.h) do
          breaks = breaks +1
          pos = pos - view.size.h
        end
        
        if (string.sub(str,i,i) ~= " ") then
          worldCellText:set(string.sub(str, i, i))
          love.graphics.draw(worldCellText, (pos-skips-1)*view.unit, view.unit*(view.size.h-3) + breaks*view.unit)
        else
          if (pos == 1 and breaks < 2) then
            skips = skips +1
          end
          worldCellText:clear()
        end
      end
    end    
  end
end

function drawEntity(entity, view, worldCellText)
  local x = entity.position.x
  local y = entity.position.y
  local drawPos = {
      x=(x-view.position.x*view.size.w-1)*view.unit,
      y=(y-view.position.y*view.size.h-1)*view.unit
  }
  worldCellText:set(entity.character)
  
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill", drawPos.x, drawPos.y, view.unit, view.unit)
  love.graphics.setColor(entity.color)
  love.graphics.draw(worldCellText, drawPos.x, drawPos.y)
end

function drawExplorer(explorer, view, worldCellText)
  local x = explorer.position.x
  local y = explorer.position.y
  local drawPos = {
      x=(x-view.position.x*view.size.w-1)*view.unit,
      y=(y-view.position.y*view.size.h-1)*view.unit
  }
  worldCellText:set(explorer.character)
  
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill", drawPos.x, drawPos.y, view.unit, view.unit)
  love.graphics.setColor(255,255,255)
  love.graphics.draw(worldCellText, drawPos.x, drawPos.y)
end

function drawCell(thisWorld, pos, view, worldCellText)
  local x = pos.x
  local y = pos.y
  if (not thisWorld:inWorld({x=x, y=y})) then
    return
  end
  local cell = thisWorld.map[x][y]
  local drawPos = {
      x=(x-view.position.x*view.size.w-1)*view.unit,
      y=(y-view.position.y*view.size.h-1)*view.unit
  }
  local letter = '?'
  local color = {1,0,1}
  
  if (cellinfo[cell] ~= nil) then
    letter = cellinfo[cell].letter
    color = cellinfo[cell].color
  else
    print(tostring(cell)..' has no cellinfo')
  end
  worldCellText:set(letter)
  
  --love.graphics.setColor(0,0,0)
  --love.graphics.rectangle("fill", drawPos.x, drawPos.y, view.unit, view.unit)
  love.graphics.setColor(thisWorld:heightColor({x=x, y=y}, cell))
  love.graphics.draw(worldCellText, drawPos.x, drawPos.y)
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end