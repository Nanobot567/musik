
function string.normalize(string)
  return string.gsub(string.gsub(string,"*","**"),"_","__")
end

function string.formatSeconds(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "0:00"
  else
    hours = string.format("%02.f", math.floor(seconds/3600))
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60))
    return mins..":"..secs
  end
end

function string.split(inputstr, sep)
  t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end

  return t
end

function table.getKeys(t)
  local keys = {}

  for k, v in pairs(t) do
    table.insert(keys, k)
  end

  return keys
end


function findSupportedTypes(str)
  local sub = string.sub(str, #str - 3)

  if str ~= nil then
    if sub == ".mp3" or sub == ".pda" then
      return true
    end

    return false
  end
end
