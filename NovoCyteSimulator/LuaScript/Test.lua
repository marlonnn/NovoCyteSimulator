require "LuaScript\\logging"                         -- 导入log模块
require "LuaScript\\subwork"  
require "LuaScript\\timer" 

logger = logging:console("%level %message\r\n")
logger:setLevel(logging.DEBUG)            -- 设置调试级别

logger:info("--------------------------------------------")
logger:info(subwork)
logger:info(tmr)
logger:info("--------------------------------------------")
v, k = tmr:systicks()
logger:info(v, k)