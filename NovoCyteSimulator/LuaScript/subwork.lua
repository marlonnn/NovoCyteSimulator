--require "luanet"
--����CLR������
luanet.load_assembly("NovoCyteSimulator")
SubWork = luanet.import_type("NovoCyteSimulator.LuaScript.LuaInterface.SubWork")
--ʵ����CLR����
subwork = SubWork.GetSubWork()
return subwork