--require "luanet"
--����CLR������
luanet.load_assembly("NovoCyteSimulator")
MTimer = luanet.import_type("NovoCyteSimulator.LuaScript.LuaInterface.MTimer")
--ʵ����CLR����
--tmr = Tmr.GetTimer()
tmr = MTimer.GetTimer()
return tmr