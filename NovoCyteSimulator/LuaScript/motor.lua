--require "luanet"
--����CLR������
luanet.load_assembly("NovoCyteSimulator")
MotorManager = luanet.import_type("NovoCyteSimulator.LuaInterface.MotorManager")
--ʵ����CLR����
motor = MotorManager.GetMotorManager()
return motor