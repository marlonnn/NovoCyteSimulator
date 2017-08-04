logging = require "LuaScript\\logging"
local logger = logging:new(
  function(self, level, message)
    return true
  end
)
logger:setLevel(logging.OFF)
logger:info("MESSAGE!!!")

local logger = logging:new(
  function(self, level, message)
    print(level, message)
    return true
  end
)
logger:setLevel(logging.WARN)
logger:info("This is a info message!!!")
logger:debug("This is a debug message!!!")
logger:warn("This is a warning message!!!")
logger:error("This is a error message!!!")
logger:fatal("This is a fatal message!!!")

local logger = logging:console("test%s.log", "%Y-%m-%d")
logger:setLevel(logging.DEBUG)
logger:info("This is a info message!!!")
logger:debug("This is a debug message!!!")
logger:warn("This is a warning message!!!")
logger:error("This is a error message!!!")
logger:fatal("This is a fatal message!!!")

--[[
local logger = logging:file("test%s.log", "%Y-%m-%d")
logger:info("logging.file test")
logger:debug("debugging...")
logger:error("error!")
print("File Logging OK")
--]]