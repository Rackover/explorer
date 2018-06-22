local utils = require('utils')


local entity = {
  position = {x=1, y=1},
  character = "?",
  color = {1, 1, 1},
  entityType = nil,
  dialog='',
  pushable = false,
  solid = true
}

entity.types = {
  key={pushable=true, color={1, 0.8, 0.8}, character="k"},
  door={character="█", color={0, 1, 1}, dialog="The gate.    Needs a key ?"},
  house={character="A", color={0.4, 0.2, 0.2} },
  villager={character="@", color={1, 0.6, 1}},
  portal={solid=false, character="░", color={0, 0, 1}}
}

-- Generates a new map
function entity:new(entityType, position, parameters)
  newEnt = utils.deepcopy(entityType)
  newEnt.entityType = entityType
  setmetatable(newEnt, self)
  self.__index = self
  newEnt.position = position
  
  if (parameters ~= nil) then
    for k,v in pairs(parameters) do
     newEnt[k] = v 
    end
  end
  
  return newEnt
end

function entity:newVillager(position, dialog)
  local color = {0.5+math.random(), math.random(), 0.2+math.random()}
  npc = self:new(self.types.villager, position, {color=color, dialog=dialog})
  
  return npc
end

return entity