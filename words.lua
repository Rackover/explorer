local words = {list=nil, currentWord=nil, sentences=nil}
 
 -- Generates a new map
function words:new(current)
  nw = {}  
  setmetatable(nw, self)
  self.__index = self
    
  nw.list = lines_from("res/txt/dictionnary.txt")
  
  for i=1, #nw.list do
    if (nw.list[i] == string.lower(current)) then
      nw.currentWord = current
      break
    end
  end
  if nw.currentWord == nil then
    local index = math.random(#nw.list)
    nw.currentWord = nw.list[index]
  end
  
  nw.sentences = lines_from("res/txt/sentences.txt")
  
  return nw
end

function words:getNext() 
  for i=1, #self.list do
    if (self.list[i] == string.lower(self.currentWord)) then
      return self.list[i+1]
    end
  end
end
 
-- http://lua-users.org/wiki/FileInputOutput
function file_exists(file)
  return love.filesystem.getInfo(file) ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
  if not file_exists(file) then print("file does not exist") return {} end
  lines = {}
  for line in love.filesystem.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

return words