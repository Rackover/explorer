local celltypes = require('celltypes')

local cellinfos = {
    [celltypes.sand] = { letter = "-", color = {0.8, 0.8, 0.3}, solid=false },
    [celltypes.dirt] = { letter = '~', color = {0.3, 0.2, 0.2}, solid=false },
    [celltypes.forest] = { letter = '¥', color = {0.5, 0.8, 0}, solid=false },
    [celltypes.mountain] = { letter = '^', color = {0.4, 0.4, 0.4}, solid=true },
    [celltypes.water] = { letter = 'w', color = {0.5, 0.6, 0.8}, solid=true }
}

return cellinfos