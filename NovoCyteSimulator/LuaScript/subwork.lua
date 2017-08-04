--require "luanet"
--加载CLR的类型
luanet.load_assembly("NovoCyteSimulator")
SubWork = luanet.import_type("NovoCyteSimulator.LuaScript.LuaInterface.SubWork")
--实例化CLR对象
subwork = SubWork.GetSubWork()
return subwork