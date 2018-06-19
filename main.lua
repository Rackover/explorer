-- ZONE 
local celltypes = require('celltypes')
local cellinfo = require('cellinfo')
local world = require("world")

local thisWorld,explorer,view,worldFont,worldCellText

-- debug elements 
local debugText,debugFont

-- On start
function love.load(arg)
  if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
  
  -- View
  view = {}
  view.size = 63
  view.unit = 16 -- Width/Height of a square unit (sprite) in pixels
  view.position = {x=0,y=0} -- Centered (?)
  
  -- Font setup
  worldFont = love.graphics.newFont("res/font/vga8.ttf", view.unit)
  worldCellText = love.graphics.newText(worldFont, "X")
  
  -- Window setup
  love.window.setMode(view.size*view.unit, view.size*view.unit)
  
  -- World setup  
  thisWorld = world:new(15*view.size)
  
  -- Entities setup
  explorer = {}
  explorer.name = "Rackover"
  explorer.position = {x=3,y=3}
  explorer.character = "☺"
  
  -- Debug
  debugFont = love.graphics.newFont("res/font/tahoma.ttf", view.unit/2)
  debugText = love.graphics.newText(debugFont, "bonjour")
  
  
end

function love.keypressed(key)
  -- in v0.9.2 and earlier space is represented by the actual space character ' ', so check for both
  if (key == " " or key == "space") then
    shoot()
  end
end

function love.update(dt)
  
  view.position = {
    x= math.floor((explorer.position.x/thisWorld.size)*(thisWorld.size/view.size)) +1,
    y= math.floor((explorer.position.y/thisWorld.size)*(thisWorld.size/view.size)) +1
  }
  
  --[[
  -- keyboard actions for our hero
  if love.keyboard.isDown("left") then
    hero.x = hero.x - hero.speed*dt
  elseif love.keyboard.isDown("right") then
    hero.x = hero.x + hero.speed*dt
  end

  --]]
end

function love.draw()
  local w, h, flags = love.window.getMode( )
  
  love.graphics.clear()
  
  -- Draw background
  love.graphics.setColor(255,255,255,255)
  love.graphics.rectangle("fill", 0, 0, w, h)
  
  -- Draw gridcells on view  
  for x=view.position.x, view.position.x+view.size do
    for y=view.position.y, view.position.y+view.size do
      
      drawCell(thisWorld, {x=x, y=y}, view, worldCellText)
            
      --love.graphics.setColor(0,0,0)
      --debugText:set( tostring(x).."|"..tostring(y))
      --love.graphics.draw(debugText, drawPos.x1, drawPos.y1)
    end
  end
  
  -- Draw player
  drawExplorer(explorer, view, worldCellText)
  
  --love.graphics.setColor(128,0,255)
  --love.graphics.rectangle("fill", 0,0,10,10)
end


---- Draw functions
function drawExplorer(explorer, view, worldCellText)
  local x = explorer.position.x
  local y = explorer.position.y
  local drawPos = {
      x=(x-view.position.x)*view.unit,
      y=(y-view.position.y)*view.unit,
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
  local cell = thisWorld.map[x][y]
  local drawPos = {
      x=(x-view.position.x)*view.unit,
      y=(y-view.position.y)*view.unit,
  }
  worldCellText:set(cellinfo[cell].letter)
  
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill", drawPos.x, drawPos.y, view.unit, view.unit)
  love.graphics.setColor(cellinfo[cell].color)
  love.graphics.draw(worldCellText, drawPos.x, drawPos.y)
end


-- Collision detection function.
-- Checks if a and b overlap.
-- w and h mean width and height.
function CheckCollision(ax1,ay1,aw,ah, bx1,by1,bw,bh)
  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end
--]]

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