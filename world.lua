local celltypes = require('celltypes')
local brush = require('brush')
local utils = require('utils')

local myWorld = {
  map = {{}},
  heightmap = {{}},
  size = {w=10,h=10},
  seed = 0
}

-- Swaps two cells
function myWorld:swapCells (pos1, pos2)
  local tmp = self.map[pos1.x][pos1.y]
  self.map[pos1.x][pos1.y] = self.map[pos2.x][pos2.y]
  self.map[pos2.x][pos2.y] = tmp
end

-- Check if cell is within the boundaries of this world
function myWorld:inWorld(pos)
  return (utils.clamp(1, self.size.w, pos.x) == pos.x and utils.clamp(1, self.size.h, pos.y) == pos.y)
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
  brush:initializeHeightmap(newWorld)
  brush:fillMap(newWorld, celltypes.sand)
  
  --[[
  brush:fillCircle(newWorld, {x=31, y=31}, 5, celltypes.forest)
  brush:fillCircle(newWorld, {x=26, y=34}, 8, celltypes.forest)
  brush:fillCircle(newWorld, {x=26, y=29}, 6, celltypes.forest)
  brush:fillCircle(newWorld, {x=27, y=33}, 5, celltypes.dirt)
  brush:fillCircle(newWorld, {x=26, y=34}, 4, celltypes.water)
  brush:fillCircle(newWorld, {x=36, y=6}, 3, celltypes.forest)
  --]]
  brush:drawLine(newWorld, {x=25, y=40}, {x=115, y=10}, {3,5}, celltypes.water)
  brush:drawLine(newWorld, {x=5, y=5}, {x=25, y=40}, {3,5}, celltypes.water)
  --brush:makeWalls(newWorld, celltypes.mountain)
  
  return newWorld
end

function myWorld:heightColor(pos, cellcolor)
  local height = self.heightmap[pos.x][pos.y]
  local modifier = (height-0.5)*0.8
  return {
    cellcolor[1]+modifier, 
    cellcolor[2]+modifier, 
    cellcolor[3]+modifier
  }
end

return myWorld