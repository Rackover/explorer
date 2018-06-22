local utils = {}

function utils.clamp (min, max, val)
  return math.min(max, math.max(min, val))
end

function utils.lerp( t, a, b )
    return a + t * (b - a)
end

function utils.sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

function utils.prime(n)
    for i = 2, n^(1/2) do
        if (n % i) == 0 then
            return false
        end
    end
    return true
end

function utils.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[utils.deepcopy(orig_key)] = utils.deepcopy(orig_value)
        end
        setmetatable(copy, utils.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function utils.wordInt(str)
  local number = tonumber("0x"..string.sub(love.data.encode("string", "hex", love.data.hash("md5", str)), 27))
  return number
end

return utils