local celltypes = {
  dirt=1,
  forest=3,
  mountain=7,
  water=15,
  
  
  mud=2,
  grass=4,
  rock=8,
  sand=16,
  
  grove=6,
  pine=10,
  swamp=18,
  
  peak=14,
  icepeak=22,
  
  deepwater=30
}

function celltypes:isPrimary(celltype)
  if (celltype == self.dirt or
      celltype == self.mountain or
      celltype == self.forest or
      celltype == self.water) then
    return true
  end
  return false
end

return celltypes