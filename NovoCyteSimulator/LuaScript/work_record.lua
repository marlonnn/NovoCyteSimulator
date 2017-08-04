work_record = work_record or {}

function work_record:stateget()
  local record_file = io.open("FLASH:/record_file.lua",'r')
  local ctrlTo, ref1, ref2, isnil
  if record_file then
    ctrlTo = tonumber(record_file:read("*l"))
    ref1   = tonumber(record_file:read("*l"))
    ref2   = tonumber(record_file:read("*l"))
    if ref1 ~= 0 then
      isnil  = true
    else 
      isnil  = false
    end
    logger:info("read state successful: ", ctrlTo, ref1, ref2)
    record_file:close()
  else
    logger:info("no record file !")
    ctrlTo,ref1,ref2 = subwork.ctrlto()
    isnil  = false
  end
  return ctrlTo, ref1, ref2, isnil
end

function work_record:stateset(ctrlTo,ref1,ref2)
  local record_file = assert(io.open("FLASH:/record_file.lua",'w'))
  record_file:write(ctrlTo,"\n",ref1,"\n",ref2)
  logger:info("write state successful: ", ctrlTo, ref1, ref2)
  record_file:close()
  return ctrlTo, ref1, ref2
end

--[[
function work_record:delete()
  local filename = "FLASH:/record_file.lua"
  os.remove(filename)
  return
end
--]]

return work_record