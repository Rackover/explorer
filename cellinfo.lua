local celltypes = require('celltypes')

local cellinfos = {
    [celltypes.sand] = { letter = ".", color = {0.8, 0.8, 0.3}, solid=false },
    [celltypes.dirt] = { letter = ',', color = {0.6, 0.4, 0.4}, solid=false },
    [celltypes.forest] = { letter = '¥', color = {0.5, 0.8, 0}, solid=false },
    [celltypes.mountain] = { letter = 'M', color = {0.4, 0.4, 0.4}, solid=true },
    [celltypes.water] = { letter = 'O', color = {0.5, 0.6, 0.8}, solid=true }
}

return cellinfos