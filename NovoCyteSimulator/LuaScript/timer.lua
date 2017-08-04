--require "luanet"
--加载CLR的类型
luanet.load_assembly("NovoCyteSimulator")
MTimer = luanet.import_type("NovoCyteSimulator.LuaScript.LuaInterface.MTimer")
--实例化CLR对象
--tmr = Tmr.GetTimer()
tmr = MTimer.GetTimer()
return tmr