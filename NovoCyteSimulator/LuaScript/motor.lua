--require "luanet"
--加载CLR的类型
luanet.load_assembly("NovoCyteSimulator")
MotorManager = luanet.import_type("NovoCyteSimulator.LuaInterface.MotorManager")
--实例化CLR对象
motor = MotorManager.GetMotorManager()
return motor