 
local celltypes = require('celltypes')
local cellinfo = require('cellinfo')
local world = require("world")
local utils = require("utils")
require("perlin"):load()

local thisWorld,worldFont,worldCellText
local explorer = {}
local view = {}

-- debug elements 
local debugText,debugFont

-- On start
function love.load(arg)
  if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
  
  -- View
  view.size = {w=64, h=64}
  view.unit = 16 -- Width/Height of a square unit (sprite) in pixels
  view.position = {x=0,y=0} -- Centered (?)
  
  -- Font setup
  worldFont = love.graphics.newFont("res/font/vga8.ttf", view.unit)
  worldCellText = love.graphics.newText(worldFont, "X")
  
  -- Window setup
  love.window.setMode(view.size.w*view.unit, view.size.h*view.unit)
  
  -- World setup  
  local screens = 1
  math.randomseed(os.time())
  thisWorld = world:new({w=screens*view.size.w, h=screens*view.size.h}, math.random()) -- 
  
  -- Entities setup
  explorer.name = "Rackover"
  explorer.position = {x=math.floor(thisWorld.size.w/2),y=math.floor(thisWorld.size.h/2)}
  explorer.character = "☺"
  
  -- Debug
  debugFont = love.graphics.newFont("res/font/tahoma.ttf", view.unit/2)
  debugText = love.graphics.newText(debugFont, "bonjour")
  
  -- Init
  view:refreshView(thisWorld, explorer)
  
end

function love.keypressed(key)
  -- in v0.9.2 and earlier space is represented by the actual space character ' ', so check for both
  if (key == "right") then
    explorer:move(thisWorld, {x=1,y=0})
    
  elseif (key == "left") then
    explorer:move(thisWorld, {x=-1,y=0})
    
  elseif (key == "up") then
    explorer:move(thisWorld, {x=0,y=-1})
    
  elseif (key == "down") then
    explorer:move(thisWorld, {x=0,y=1})
    
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
end

--- Game functions
function explorer:move(thisWorld, vec2_direction)
  
  local futurePosition = {x=vec2_direction.x+self.position.x, y=vec2_direction.y+self.position.y} 
  
  if (utils.clamp(1, thisWorld.size.w, futurePosition.x) ~= futurePosition.x or
      utils.clamp(1, thisWorld.size.h, futurePosition.y) ~= futurePosition.y) then
    return
  end
  
  local futureCell = thisWorld.map[futurePosition.x][futurePosition.y]
  
  if (not cellinfo[futureCell].solid) then
    thisWorld:swapCells(futurePosition, self.position)
    self.position = futurePosition
  end
end

function love.draw()
  local w, h, flags = love.window.getMode( )
  
  love.graphics.clear()
  
  -- Draw background
  love.graphics.setColor(0,0,0,255)
  love.graphics.rectangle("fill", 0, 0, w, h)
  
  -- Draw gridcells on view  
  for x=view.position.x*view.size.w+1, (view.position.x+1)*view.size.w do
    for y=view.position.y*view.size.h+1, (view.position.y+1)*view.size.h do
      drawCell(thisWorld, {x=x, y=y}, view, worldCellText)
    end
  end
  
  -- Draw player
  drawExplorer(explorer, view, worldCellText)
end


---- Draw functions
function view:refreshView(thisWorld, explorer)
  self.position = {
    x= math.floor(((explorer.position.x-1)/thisWorld.size.w)*(thisWorld.size.w/self.size.w)),
    y= math.floor(((explorer.position.y-1)/thisWorld.size.h)*(thisWorld.size.h/self.size.h))
  }
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
  worldCellText:set(cellinfo[cell].letter)
  
  --love.graphics.setColor(0,0,0)
  --love.graphics.rectangle("fill", drawPos.x, drawPos.y, view.unit, view.unit)
  love.graphics.setColor(thisWorld:heightColor({x=x, y=y}, cellinfo[cell].color))
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