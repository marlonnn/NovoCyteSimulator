require "LuaScript\\logging"                         -- ����logģ��
require "LuaScript\\subwork"  
require "LuaScript\\timer" 

logger = logging:console("%level %message\r\n")
logger:setLevel(logging.DEBUG)            -- ���õ��Լ���

logger:info("--------------------------------------------")
logger:info(subwork)
logger:info(tmr)
logger:info("--------------------------------------------")
v, k = tmr:systicks()
logger:info(v, k)