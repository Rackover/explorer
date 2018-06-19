local celltypes = require('celltypes')

local world = {
  map = {{}},
  size = {10,10},
  seed = 0
}

-- Generates a new map covered in sand
function world:new(int_size)
  newWorld = {}
  setmetatable(newWorld, self)
  newWorld.map = {{}}
  newWorld.size = int_size
  
  -- Initializing map by filling with sand
  for x=1, newWorld.size do
    for y=1, newWorld.size do
      
      if newWorld.map[x] == nil then
        newWorld.map[x] = {}
      end
      
      newWorld.map[x][y] = celltypes.sand
      
      if (x > 8 and x < 10) then
        newWorld.map[x-1][y] = celltypes.water
        newWorld.map[x-2][y] = celltypes.dirt
        newWorld.map[x-3][y] = celltypes.mountain
        newWorld.map[x-4][y] = celltypes.forest
      end
    end
  end
  
  return newWorld
end

return world