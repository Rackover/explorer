local celltypes = require('celltypes')
local cellinfo = require('cellinfo')
local utils = require('utils')
local perlin = require('perlin')

local myWorld = {
  map = {{}},
  heightmaps = {},
  size = {w=10,h=10},
  seed = 0,
  entities = {}
}

-- Swaps two cells
function myWorld:swapCells (pos1, pos2)
  local tmp = self.map[pos1.x][pos1.y]
  self.map[pos1.x][pos1.y] = self.map[pos2.x][pos2.y]
  self.map[pos2.x][pos2.y] = tmp
end

-- Check if cell is within the boundaries of this world
function myWorld:inWorld(pos)
  return (
    utils.clamp(1, self.size.w, pos.x) == pos.x and 
    utils.clamp(1, self.size.h, pos.y) == pos.y)
end

-- Generates a new map
function myWorld:new(vec2_size, seed)
  newWorld = {}
  setmetatable(newWorld, self)
  self.__index = self
  newWorld.map = {{}}
  newWorld.heightmap = {{}}
  newWorld.size = vec2_size
  newWorld.seed = seed
  
  -- Initializing map by filling with sand
  newWorld:initializeHeightmaps()
  newWorld:fillMap(celltypes.dirt)
  newWorld:makeOnHeight(celltypes.forest, 0.5)
  newWorld:makeOnHeight(celltypes.mountain, 0.7)
  
  --[[
  brush:fillCircle(newWorld, {x=26, y=34}, 8, celltypes.forest)
  brush:fillCircle(newWorld, {x=26, y=29}, 6, celltypes.forest)
  brush:fillCircle(newWorld, {x=27, y=33}, 5, celltypes.dirt)
  brush:fillCircle(newWorld, {x=26, y=34}, 4, celltypes.water)
  brush:fillCircle(newWorld, {x=36, y=6}, 3, celltypes.forest)
  --]]
  newWorld:createRiver()
  
  newWorld:fillCircle({x=math.floor(newWorld.size.w/2), y=math.floor(newWorld.size.h/2)}, 5, celltypes.forest)
  newWorld:fillCircle({x=math.floor(newWorld.size.w/2), y=math.floor(newWorld.size.h/2)}, 4, celltypes.grass)
  newWorld:fillCircle({x=math.floor(newWorld.size.w/2), y=math.floor(newWorld.size.h/2)}, 3, celltypes.dirt)
  
  --newWorld:createVillage({x=newWorld.size.w/4+math.random(newWorld.size.w/2), y=newWorld.size.h/4+math.random(newWorld.size.h/2)} )
  
  --brush:makeWalls(newWorld, celltypes.mountain)
  
  return newWorld
end

function myWorld:heightColor(pos, celltype)
  local cellcolor = cellinfo[celltype].color
  if (not celltypes:isPrimary(celltype)) then
    return cellcolor
  end
  local height = self.heightmaps[celltype][pos.x][pos.y]
  local modifier = (height-0.5)*0.8
  return {
    cellcolor[1]+modifier, 
    cellcolor[2]+modifier, 
    cellcolor[3]+modifier
  }
end

------
-- TERRAFORMING FUNCTIONS
------

function myWorld:fillCircle(pos, radius, celltype)
  -- We're going to make a square, and for each cell of this square, calculate distance between square center
  -- This is how we'll draw a circle. That's extremely unoptimized, but terribly easy to code

  local square = {
    x1= utils.clamp(1, self.size.w, pos.x-radius), 
    y1= utils.clamp(1, self.size.h, pos.y-radius), 
    x2= utils.clamp(1, self.size.w, pos.x+radius), 
    y2= utils.clamp(1, self.size.h, pos.y+radius)
  }
  for x=square.x1, square.x2 do
    for y=square.y1, square.y2 do
      local distance = math.sqrt((x-pos.x)^2 + (y-pos.y)^2)
      if (distance < radius) then
        if (self:inWorld({x=x, y=y})) then
          self.map[x][y] = celltype
        end
      end
    end
  end
end

function myWorld:addCircle(pos, radius, celltype)
  local square = {
    x1= utils.clamp(1, self.size.w, pos.x-radius), 
    y1= utils.clamp(1, self.size.h, pos.y-radius), 
    x2= utils.clamp(1, self.size.w, pos.x+radius), 
    y2= utils.clamp(1, self.size.h, pos.y+radius)
  }
  for x=square.x1, square.x2 do
    for y=square.y1, square.y2 do
      local distance = math.sqrt((x-pos.x)^2 + (y-pos.y)^2)
      if (distance < radius) then
        self.map[x][y] = self.map[x][y]+celltype
      end
    end
  end
end
 
function myWorld:affect(pos)
  local cell = self.map[pos.x][pos.y]
  if (cell == celltypes.forest) then self.map[pos.x][pos.y] = celltypes.grass end
  if (cell == celltypes.grass) then self.map[pos.x][pos.y] = celltypes.dirt end
  --if (cell == celltypes.water) then world.map[pos.x][pos.y] = celltypes.mud end
  --if (cell == celltypes.mountain) then world.map[pos.x][pos.y] = celltypes.rock end
end
 
function myWorld:noiseAt(pos, celltype)
  local noise = (
    math.floor(
      perlin:noise(
        pos.x+self.seed*celltype, pos.y+self.seed*celltype, 1
      )*50
    )+50
  )/100

  return noise
end

function myWorld:initializeHeightmaps()
  for k,v in pairs(celltypes) do
    if (celltypes:isPrimary(v)) then
      self.heightmaps[v] = {}
      
      for x=1, self.size.w do
        for y=1, self.size.h do
          if self.heightmaps[v][x] == nil then
            self.heightmaps[v][x] = {}
          end
          self.heightmaps[v][x][y] = self:noiseAt({x=x, y=y}, v)
        end
      end
    end
  end
end

function myWorld:fillMap(celltype)
  for x=1, self.size.w do
    for y=1, self.size.h do
      if self.map[x] == nil then
        self.map[x] = {}
      end
      self.map[x][y] = celltype
    end
  end
end

function myWorld:makeWalls(celltype)
  math.randomseed(self.seed)
  for x=1, self.size.w do
    self:fillCircle({x=x, y=1}, math.random(6), celltype)
    self:fillCircle({x=x, y=self.size.h}, math.random(6), celltype)
  end
  for y=1, self.size.h do
    self:fillCircle({x=1, y=y}, math.random(6), celltype)
    self:fillCircle({x=self.size.w, y=y}, math.random(6), celltype)
  end
end

function myWorld:drawLine(pos1, pos2, radius, celltype)
  --[[
  if (pos2.x < pos1.x) then
    local a = pos1.x
    pos1.x = pos2.x
    pos2.x = a
  --]]
  if(pos2.x == pos1.x) then
    pos2.x = pos1.x+1
  end
  local deltax = pos2.x - pos1.x
  local deltay = pos2.y - pos1.y
  local deltaerr = math.abs(deltay / deltax)    -- Assume deltax != 0 (line is not vertical),
       -- note that this division needs to be done in a way that preserves the fractional part
  local err = 0.0 -- No error at start
  local y = pos1.y
  for x=pos1.x, pos2.x do
    if (type(radius) == "table") then
      self:fillCircle({x=x, y=y}, math.random(radius[1], radius[2]), celltype)
    elseif (radius > 0) then
      self:fillCircle({x=x, y=y}, radius, celltype)
    else 
      self.map[x][y] = celltype
    end
   err = err + deltaerr
   
   while err >= 0.5 do
       y = y + utils.sign(deltay)
       err = err - 1
    end
  end
end

function myWorld:makeOnHeight(celltype, threshold)
  for x=1, self.size.w do
    for y=1, self.size.h do
      local hm = self.heightmaps[celltype][x][y]
      if hm > threshold then
        self.map[x][y] = celltype
      end
    end
  end
end

function myWorld:createRiver()
  math.randomseed(self.seed)
  local direction = math.random(1,2)
  local startPoint, endPoint
  if (direction == 1) then -- Vertical river
    startPoint = {
      x = math.random(1, self.size.w),
      y = -1
    }
    endPoint = {
      x = math.random(1, self.size.w),
      y = self.size.h+1
    }
  elseif (direction == 2) then -- Horizontal river
    startPoint = {
      x = -1,
      y = math.random(1, self.size.h)
    }
    endPoint = {
      x = self.size.w+1,
      y = math.random(1, self.size.h)
    }
  end
  -- Creating points in the river to make it zigzag
  local pointsAmount = math.random(4, 8)
  local points = {startPoint}
  local maxOffset = 8
  for i=1,pointsAmount do
    local offset = math.random(maxOffset)
    local pos = {}
    if (direction == 1) then -- vertical
      pos = {
        x=math.floor(startPoint.x-offset+maxOffset/2), 
        y=math.floor(startPoint.y + (endPoint.y-startPoint.y)*(i/pointsAmount))
      }
    elseif (direction == 2) then
      pos = {
        x=math.floor(startPoint.x + (endPoint.x-startPoint.x)*(i/pointsAmount)), 
        y=math.floor(startPoint.y-offset+maxOffset/2)
      }
    end
    table.insert(points, pos)
  end
  table.insert(points, endPoint)
  -- Drawing the lines for the river
  local randomSkip = math.random(2, #points-1) -- Skipping one point randomly to create a bridge
  for i, v in ipairs(points) do
    if (i > 1 and i < #points) then
      local p1, p2
      p1 =points[i-1]
      p2 =points[i]
      if (p1.x > p2.x) then
        p1 = points[i]
        p2 = points[i-1]
      end
      if (randomSkip ~= i) then
        self:drawLine(p1, p2, {3,5}, celltypes.water)
      end
    end
  end  
end

return myWorld