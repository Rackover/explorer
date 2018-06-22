local celltypes = require('celltypes')

local cellinfo = {
    [celltypes.dirt] = { letter = ".", color = {0.8, 0.8, 0.3}, solid=false },
    [celltypes.forest] = { letter = '¥', color = {0.5, 0.8, 0}, solid=false },
    [celltypes.mountain] = { letter = 'M', color = {0.4, 0.4, 0.4}, solid=true },
    [celltypes.water] = { letter = '~', color = {0.5, 0.6, 0.8}, solid=true },
    
    
    [celltypes.mud] = { letter = ',', color = {0.5, 0.6, 0.8}, solid=false },
    [celltypes.grass] = { letter = ':', color = {0.2, 0.6, 0.3}, solid=false },
    [celltypes.rock] = { letter = '-', color = {0.3, 0.3, 0.3}, solid=false },
    [celltypes.sand] = { letter = '_', color = {0.5, 0.6, 0.8}, solid=true },
    
    [celltypes.grove] = { letter = '♣', color = {0.5, 0.6, 0.8}, solid=true },
    [celltypes.pine] = { letter = '¥', color = {0.5, 0.6, 0.8}, solid=true },
    [celltypes.swamp] = { letter = ';', color = {0.5, 0.6, 0.8}, solid=true },
    
    [celltypes.peak] = { letter = '△', color = {0.5, 0.6, 0.8}, solid=true },
    [celltypes.icepeak] = { letter = '^', color = {0.5, 0.6, 0.8}, solid=true },
    
    [celltypes.deepwater] = { letter = 'u', color = {0.5, 0.6, 0.8}, solid=true },
}
  
return cellinfo