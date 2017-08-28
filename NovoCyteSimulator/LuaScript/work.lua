--#!/usr/local/bin/lua
--******************************************************************************
-- work.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work = work or {}                         -- ��������work��

require "LuaScript\\TimingConst"                     -- ���볣����
require "LuaScript\\config"
require "LuaScript\\timing"                          -- ����ʱ���
require "LuaScript\\logging"                         -- ����logģ��
require "LuaScript\\work_record"                     -- ����״̬�����¼ģ��
require "LuaScript\\novoerror"                       -- ������������ж�ģ��
require "LuaScript\\work_startup"                    -- ���뿪����ʼ�����̿��Ʊ�
require "LuaScript\\work_idle"                       -- ����������̿��Ʊ�
require "LuaScript\\work_measure"                    -- ����������̿��Ʊ�
require "LuaScript\\work_maintain"                   -- ����ά�����̿��Ʊ�
require "LuaScript\\work_shutdown"                   -- ����ػ����̿��Ʊ�
require "LuaScript\\work_initpriming"                -- �����״ι�ע���Ʊ�
require "LuaScript\\work_drain"                      -- �����ſ����̿��Ʊ�
require "LuaScript\\work_decontamination"            -- �����������̿��Ʊ�
require "LuaScript\\work_error_handle"               -- ��������Զ��������̿��Ʊ�
require "LuaScript\\work_error_diagnosis"            -- �������������̿��Ʊ�
require "LuaScript\\work_sleepenter"                 -- ����������߿��Ʊ�
require "LuaScript\\work_sleep"                      -- �������߿��Ʊ�
require "LuaScript\\work_sleepexit"                  -- �����˳����߿��Ʊ�
require "LuaScript\\work_motorgohome"                -- ���븴λ���̿��Ʊ�
require "LuaScript\\motor"  
require "LuaScript\\valve"  
require "LuaScript\\subwork"  
require "LuaScript\\timer"  


logger = logging:console("%level %message\r\n")
logger:setLevel(logging.DEBUG)            -- ���õ��Լ���
--subwork:timingversionset(timing.version)  -- ���õ�ǰ�ܵ�����ʱ��汾
--tmr = subwork.GetTimer()
local work_list = {                       -- ����ʱ�����ת����
  [TimingConst.WORK_STARTUP]          = work_startup,         -- ��Ӧ����ִ������
  [TimingConst.WORK_IDLE]             = work_idle,            -- ��Ӧ��������
  [TimingConst.WORK_MEASURE]          = work_measure,         -- ��Ӧ��������
  [TimingConst.WORK_MAINTAIN]         = work_maintain,        -- ��Ӧά������
  [TimingConst.WORK_SHUTDOWN]         = work_shutdown,        -- ��Ӧ�ػ�����
  [TimingConst.WORK_ERRORHANDLE]      = work_error_handle,    -- ��Ӧ����������
  [TimingConst.WORK_ERRORDIAGNOSIS]   = work_error_diagnosis, -- ��Ӧ�����������
  [TimingConst.WORK_INITPRIMING]      = work_initpriming,     -- ��Ӧ�״ι�ע����
  [TimingConst.WORK_DRAIN]            = work_drain,           -- ��Ӧ�ſ�����
  [TimingConst.WORK_DECONTAMINATION]  = work_decontamination, -- ��Ӧ��������
  [TimingConst.WORK_SLEEPENTER]       = work_sleepenter,      -- ��Ӧ��������
  [TimingConst.WORK_SLEEP]            = work_sleep,           -- ��Ӧ����
  [TimingConst.WORK_SLEEPEXIT]        = work_sleepexit,       -- ��Ӧ�˳�����
  [TimingConst.WORK_MOTORGOHOME]      = work_motorgohome,     -- ��Ӧ��λ����
  [TimingConst.WORK_STOP]             = work_stop,            -- ��Ӧ�޷���������
  __default                           = work_idle
}
setmetatable(work_list, {__index = function (t, k)
  return rawget(t, "__default")
end})

function work:select()            -- ѡ����һִ������
  self.stateTo = work_list[self.stateTo]:process()
  return self.stateTo
end

function work:init()
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.grp = timing[self.timingName]            -- ����ʱ�������grpʱ������
  self.sub = nil
  local tstart = tmr.systicks()
  local ttotal = self:timecalc()
  subwork:stateset(self.stateTo, 0, 0)
  subwork:timeset(tstart, ttotal)
end

function work:itemGet()           -- ��ʱ���б��ȡʱ��ڵ�
  local item
  local shadowCall = self.shadowCall
  self.subCnt = self.subCnt + 1   -- ʱ��ڵ������
  if shadowCall then              -- �Ƿ���Ӱ�ӽڵ����
    self.shadowCall = nil
    item = shadowCall(self)       -- ͨ���޸Ĵ���Ӱ�ӽڵ�
    return item                   -- ����һ��Ӱ�ӽڵ�
  end

  local sub = self.sub            -- ��ʱ���ȡ�ڵ�
  local index = self.subIdx
  self.subIdx = self.subIdx + 1   -- ʱ��ڵ�������
  if sub.idx then index = sub.idx[index] end            -- ��ȡ�ڵ�����

  item = sub.sub[index]           -- ��ȡʱ����еĽڵ�

  return item
end

function work:itemRun(item)       -- ����ʱ��ڵ�
  local ret
  local xmotor
  local omega
  local info
  --subwork:Print(motor.Motors[1]:reset())
  -- ������
  info = "[VALVES]: "
  if item.valve then              -- �жϵ�ǰ�ڵ�valveֵ�Ƿ�Ϊnil
    info = info .. "<ON> " .. table.concat(item.valve, ' ')
    ret = valve.on(unpack(item.valve))            -- ���valveֵΪ��nil,����Ӧ�ķ�
  else
    info = info .. "<OFF>"
    ret = valve.off()                                   -- ���valveֵΪnil,��ر����е�valve
  end
  logger:info(info)
  subwork:Print("Vales set end")

  -- ������������
  if item.smotor then                                   -- �ж�ʱ��ڵ����������������Ƿ�Ϊnil
    info = "[SMOTOR]: "
    xmotor = item.smotor
    --subwork:Print("smotor start")
	--subwork:Print(xmotor)
	if type(xmotor) == "table" then                     -- ���smotor���õ���table����
      if xmotor.op == TimingConst.MOTOR_RUN then        -- ���ִ�е���run����
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("SMOTOR missing parameter")
		--subwork:Print("SMOTOR missing parameter")
        end
        info = info .. string.format("<RUN> %.2fr, %.2frpm", xmotor.rounds, omega) -- ��ӡ��Ӧ������Ϣ,�����ڵ���
        motor:run(TimingConst.SMOTOR, xmotor.rounds, omega)    -- ִ��run����
		--subwork:Print(string.format("[SMOTOR]: <RUN> %.2fr, %.2frpm", xmotor.rounds, omega))
      elseif xmotor.op == TimingConst.MOTOR_CHSPEED then-- ���ִ�е��Ǳ��ٲ���
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("SMOTOR missing parameter")
		--subwork:Print("SMOTOR missing parameter")
        end
        info = info .. string.format("<CHSPEED> %.2frpm", omega)
        motor:chspeed(TimingConst.SMOTOR, omega)        -- ִ�б��ٶ���
      elseif xmotor.op == TimingConst.MOTOR_RESET then  -- ���ִ�е��Ǹ�λ����
        info = info .. "<RESET>"
        motor:reset(TimingConst.SMOTOR)                 -- ִ�и�λ����
      elseif xmotor.op == TimingConst.MOTOR_STOP then   -- ���ִ�е���ֹͣ����
        info = info .. "<STOP>"
        motor:stop(TimingConst.SMOTOR)                  -- ִ��ֹͣ����
		--subwork:Print("----work SMOTOR motor stop----")
      end
    elseif type(xmotor) == "function" then              -- ���smotor���õ���function����
      info = info .. "<CALL>"
      xmotor()                                          -- �����Զ��庯��
    else                                                -- ���smotor���õ�����������
      info = info .. "<NIL>"
    end
    logger:info(info)
  end
  --subwork:Print("smotor end ")

  -- ע�����������
  if item.imotor then                                   -- �ж�ʱ��ڵ���ע������������Ƿ�Ϊnil
    info = "[IMOTOR]: "
    xmotor = item.imotor
    --subwork:Print("imotor start")
	--subwork:Print(xmotor)
	if type(xmotor) == "table" then                     -- ���imotor���õ���table����
      subwork:Print(xmotor.op)
	  if xmotor.op == TimingConst.MOTOR_RUN then        -- ���ִ�е���run����
        if xmotor.omega then
        omega = xmotor.omega
	    --subwork:Print(omega)
        else
        error("IMOTOR missing parameter")
        end
        info = info .. string.format("<RUN> %.2fr, %.2frpm", xmotor.rounds, omega)
        motor:run(TimingConst.IMOTOR, xmotor.rounds, omega)    -- ִ��run����
		--subwork:Print(string.format("[IMOTOR]: <RUN> %.2fr, %.2frpm", xmotor.rounds, omega))
      elseif xmotor.op == TimingConst.MOTOR_CHSPEED then-- ���ִ�е��Ǳ��ٲ���
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("IMOTOR missing parameter")
        end
        info = info .. string.format("<CHSPEED> %.2frpm", omega)
        motor:chspeed(TimingConst.IMOTOR, omega)        -- ִ�б��ٶ���
		--subwork:Print(string.format("[IMOTOR]: <CHSPEED> %.2frpm", omega))
      elseif xmotor.op == TimingConst.MOTOR_RESET then  -- ���ִ�е��Ǹ�λ����
        info = info .. "<RESET>"
        motor:reset(TimingConst.IMOTOR)                 -- ִ�и�λ����
      elseif xmotor.op == TimingConst.MOTOR_STOP then   -- ���ִ�е���ֹͣ����
        info = info .. "<STOP>"
        motor:stop(TimingConst.IMOTOR)                  -- ִ��ֹͣ����
      end
    elseif type(xmotor) == "function" then              -- ���smotor���õ���function����
      info = info .. "<CALL>"
      xmotor()                                          -- �����Զ��庯��
    else                                                -- ���smotor���õ�����������
      info = info .. "<NIL>"
    end
    logger:info(info)
  end
  --subwork:Print("imotor end")
  -- �䶯�õ������
  if item.pmotor then                                   -- �ж�ʱ��ڵ����䶯�õ�������Ƿ�Ϊnil
    info = "[PMOTOR]: "
    xmotor = item.pmotor
	--subwork:Print("pmotor start")
	--subwork:Print(xmotor)
    if type(xmotor) == "table" then                     -- ���pmotor���õ���table����
      --subwork:Print(xmotor.op)
	  if xmotor.op == TimingConst.MOTOR_RUN then        -- ���ִ�е���run����
        if xmotor.omega then
        omega = xmotor.omega
		--subwork:Print(omega)
        else
        error("PMOTOR missing parameter")
		--subwork:Print("PMOTOR missing parameter")
        end
        info = info .. string.format("<RUN> %.2fr, %.2frpm", xmotor.rounds, omega)
		motor:run(TimingConst.PMOTOR, xmotor.rounds, omega)    -- ִ��run����
		--subwork:Print(string.format("[PMOTOR]: <RUN> %.2fr, %.2frpm", xmotor.rounds, omega))
      elseif xmotor.op == TimingConst.MOTOR_CHSPEED then-- ���ִ�е��Ǳ��ٲ���
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("PMOTOR missing parameter")
		--subwork:Print("PMOTOR missing parameter")
        end
        info = info .. string.format("<CHSPEED> %.2frpm", omega)
        motor:chspeed(TimingConst.PMOTOR, omega)        -- ִ�б��ٶ���
		--subwork:Print(string.format("[PMOTOR]: <CHSPEED> %.2frpm", omega))
      elseif xmotor.op == TimingConst.MOTOR_RESET then  -- ���ִ�е��Ǹ�λ����
        info = info .. "<RESET>"
        motor:reset(TimingConst.PMOTOR)                 -- ִ�и�λ����
      elseif xmotor.op == TimingConst.MOTOR_STOP then   -- ���ִ�е���ֹͣ����
        info = info .. "<STOP>"
        motor:stop(TimingConst.PMOTOR)                  -- ִ��ֹͣ����
		--subwork:Print("----work PMOTOR motor stop----")
      end
    elseif type(xmotor) == "function" then              -- ���smotor���õ���function����
      info = info .. "<CALL>"
      xmotor()                                          -- �����Զ��庯��
    else                                                -- ���smotor���õ�����������
      info = info .. "<NIL>"
    end
    logger:info(info)
  end
  --subwork:Print("pmotor end")
end

function work:subTimingInit()                           -- subʱ�����̿��Ƴ�ʼ��
  logger:info("subTimingInit:", self.grpIdx)
  self.subIdx = 1
  if self.subBeginHook then self:subBeginHook() end     -- �Ƿ���Ҫ��ʼ���ص�
end

function work:subTimingRun()                            -- subʱ������ִ��
  local sub = self.sub                                  -- ��ȡ��ǰsubʱ������
  local idx = 1                                         -- subʱ��ڵ������
  local ret
  if sub.idx then
  logger:info("subTimingRun: ", sub.sub.name, sub.idx.name)
  else
  logger:info("subTimingRun: ", sub.sub.name)
  end
  repeat
    local item = self:itemGet()                         -- ��subʱ�������л��һ���ڵ�
    --subwork:Print(item)
	if not item then
      self.quittype = TimingConst.WORK_QUIT_Normal
      break
    end                          -- �����õĽڵ�Ϊnil,Ҳ����˵����ʱ���β,���˳�
    if item.beginhook then
      item.beginhook(self, item)
    end
    item.ticks = math.ceil(item.ticks)
    if sub.idx then
    logger:info(string.format("-> idx:%3d[0x%02x], ticks:%4d", idx, sub.idx[idx], item.ticks))
    else
    logger:info(string.format("-> idx:%3d[0x%02x], ticks:%4d", idx, idx, item.ticks))
    end
	--subwork:Print("item run")
    self:itemRun(item)                                  -- ִ�л�õĽڵ�
    --subwork:Print("item run end")
	subwork:alarmstart(item.ticks)
	--subwork:Print("alarm start")
    while true do
      ret = subwork:alarmwait(item.awaketicks or 100)
      if ret == TimingConst.WORK_QUIT_Abort then 
        subwork:Print("abort")
		self.quittype = ret
        return self.quittype                            -- �������쳣��������ǰ����
      end
      if ret ~= TimingConst.WORK_QUIT_Wait then 
	    --subwork:Print("not equal work quit wait")
		break 
		end
      if item.awakehook then
        ret = item.awakehook(self)
        if ret ~= TimingConst.WORK_QUIT_Wait then break end
      end
    end
    self.quittype = ret
    if item.endhook then
	  --subwork:Print("--end hook--")
      item.endhook(self, item)
    end
    idx = idx + 1                                       -- ��һ���ڵ�
  	--subwork:Print(ret)
  until ret ~= TimingConst.WORK_QUIT_Next
end

function work:subTimingQuit()                           -- subʱ�������˳�
  if self.subEndHook then self:subEndHook() end         -- �Ƿ���Ҫ�˳��ص�
  logger:info("subTimingQuit:", self.grpIdx)
end

function work:subTimingProcess()                        -- ����subʱ�����̵�ִ�й���
  self:subTimingInit()                                  -- ��ʼ��
  self:subTimingRun()                                   -- ����
  self:subTimingQuit()                                  -- ����
end

function work:grpTimingInit()                           -- grpʱ�����̿��Ƴ�ʼ��
  logger:info("grpTimingInit")
  if self.grpBeginHook then self:grpBeginHook() end     -- �Ƿ���Ҫ��ʼ���ص�
end

function work:grpTimingRun()                            -- grpʱ������ִ��
  local grp = self.grp
  --subwork:Print(grp)
  logger:info("grpTimingRun: ", grp.name)
  while self.grpIdx <= #grp do                          -- ѭ��grp��ÿһ��subʱ��
	self.sub = grp[self.grpIdx]                         -- ��õ�ǰ��subʱ��

    self:subTimingProcess()                             -- ִ��subʱ������
    if self.quittype ~= TimingConst.WORK_QUIT_Normal then break end

    if self.sub.ishand then break end

    self.grpIdx = self.grpIdx + 1                       -- ��һ��sub
    self.grpCnt = self.grpCnt + 1
  end
end

function work:grpTimingQuit()                           -- grpʱ�������˳�
  if self.grpEndHook then self:grpEndHook() end         -- �Ƿ���Ҫ�˳��ص�
  --subwork:Print("work: grpTimingQuit")
  logger:info("grpTimingQuit")
  --logger:warn("quittype: ", self.quittype)

  if self.quittype ~= TimingConst.WORK_QUIT_Normal then
    self:itemRun(timing.allstop[1])
  end
end

function work:grpTimingProcess()                        -- ����grpʱ�����̵�ִ�й���
  self:grpTimingInit()                                  -- ��ʼ��
  self:grpTimingRun()                                   -- ����
  self:grpTimingQuit()                                  -- ����
end

function work:timecalc()
  local grp = self.grp
  local grpIdx = self.grpIdx or 1
  local index, subIdx
  local item
  local ticks = 0

  self.istimecalc = true
  while grpIdx <= #grp do
    local sub = grp[grpIdx]
    subIdx = 1
    while true do
      index = subIdx
      subIdx = subIdx + 1
      if sub.idx then index = sub.idx[index] end        -- ��ȡ�ڵ�����
      item = sub.sub[index]                             -- ��ȡʱ����еĽڵ�
      if item then
        if item.beginhook then
          item.beginhook(self, item)
        end
        ticks = ticks + item.ticks
      else break end
    end
    if sub.ishand then break end
    grpIdx = grpIdx + 1
  end
  self.istimecalc = false

  return ticks
end

function work.Step(step, set)
  --return (set<<16)|step     --INT16U,�ಽ��������,���ֽ�0��ʾִ�����,1��ʾִ����;���ֽڱ�ʾִ�еĲ���
    --return math.ldexp(set, 16) + set     --INT16U,�ಽ��������,���ֽ�0��ʾִ�����,1��ʾִ����;���ֽڱ�ʾִ�еĲ���
	return set * 2^16 + set 
end

function work:setstate()
	work.stateTo = subwork.ToLua.Stateto
	logger:info("state to: ------------------->")
	logger:info(work.stateTo)
	work:select()
	return true
end

return work

--work.stateTo, work.subref1, work.subref2, work.isrecordnil = work_record:stateget()
--work.stateTo, work.subref1, work.subref2 = subwork.ctrlto()
--work.stateTo = TimingConst.WORK_STARTUP
--while true do
  --work:select()
--end

-- work.stateTo = TimingConst.WORK_STARTUP                 -- Ĭ������Ϊ������ʼ��״̬
--[[
local work_prompt = "  [1]: Startup\r\n  [2]: Idle\r\n  [3]: Measure\r\n  [4]: Maintain\r\n  [5]: Error\r\n  [6]: Sleep\r\n  [7]: Shutdown\r\n  [8]: InitPriming\r\n  [9]: Drain\r\n  [0]: Exit\r\n"
local maintain_prompt = "  [1]: Debubble\r\n  [2]: Cleaning\r\n  [3]: Rinse\r\n  [4]: ExtRinse\r\n  [5]: Priming\r\n  [6]: Unclog\r\n  [7]: Backflush\r\n  [0]: Exit\r\n"

while true do
  io.write(work_prompt .. "Please Select: ")
  local input
  repeat input = io.read("*number") until input

  print(input)
  if input==1 then
    work.stateTo = TimingConst.WORK_STARTUP
  elseif input==2 then
    work.stateTo = TimingConst.WORK_IDLE
  elseif input==3 then
    work.stateTo = TimingConst.WORK_MEASURE
  elseif input==4 then
    work.stateTo = TimingConst.WORK_MAINTAIN
    while true do
      io.write(maintain_prompt .. "Please Select: ")
      local sel = io.read("*number")
      print(sel)
      if sel==1 then
        work.maintainTo = TimingConst.MAINTAIN_DEBUBBLE
        break
      elseif sel==2 then
        work.maintainTo = TimingConst.MAINTAIN_CLEANING
        break
      elseif sel==3 then
        work.maintainTo = TimingConst.MAINTAIN_RINSE
        break
      elseif sel==4 then
        work.maintainTo = TimingConst.MAINTAIN_EXTRINSE
        break
      elseif sel==5 then
        work.maintainTo = TimingConst.MAINTAIN_PRIMING
        break
      elseif sel==6 then
        work.maintainTo = TimingConst.MAINTAIN_UNCLOG
        break
      elseif sel==7 then
        work.maintainTo = TimingConst.MAINTAIN_BACKFLUSH
        break
      elseif sel==0 then
        input = nil
        break
      else
        logger:info("\r\n\27[1;31mERROR INPUT.\27[m")
        input = nil
      end
    end
  elseif input==5 then
  elseif input==5 then
    work.stateTo = TimingConst.WORK_ERRORHANDLE
  elseif input==6 then
    work.stateTo = TimingConst.WORK_SLEEP
  elseif input==7 then
    work.stateTo = TimingConst.WORK_SHUTDOWN
  elseif input==8 then
    work.stateTo = TimingConst.WORK_INITPRIMING
  elseif input==9 then
    work.stateTo = TimingConst.WORK_DRAIN
  elseif input==0 then
    break
  else
    logger:info("\r\n\27[1;31mERROR INPUT.\27[m")
    input = nil
  end
  if input then
    logger:info(work.stateTo)
    work:select()
  end
end
--]]

--******************************************************************************
-- No More!
--******************************************************************************
