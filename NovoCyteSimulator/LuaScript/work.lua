--#!/usr/local/bin/lua
--******************************************************************************
-- work.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work = work or {}         -- ��������work��

require "LuaScript\\TimingConst"   -- ���볣����
require "LuaScript\\config"
require "LuaScript\\timing"        -- ����ʱ���
require "LuaScript\\logging"       -- ����logģ��

require "LuaScript\\work_startup"  -- ���뿪����ʼ�����̿��Ʊ�
require "LuaScript\\work_idle"     -- ����������̿��Ʊ�
require "LuaScript\\work_measure"
require "LuaScript\\work_maintain"
require "LuaScript\\work_error"
require "LuaScript\\work_initpriming"
require "LuaScript\\work_drain"
require "LuaScript\\work_decontamination"
require "LuaScript\\motor"         -- ����motor����ģ��
require "LuaScript\\valve"         -- ����valve����ģ��
require "LuaScript\\tmr"
require "LuaScript\\subwork"

logger = logging:console("%level %message\r\n")
logger:setLevel(logging.DEBUG)

local work_list = {     -- ����ʱ�����ת����
  [TimingConst.WORK_STARTUP]          = work_startup,   -- ��Ӧ����ִ������
  [TimingConst.WORK_IDLE]             = work_idle,      -- ��Ӧ��������
  [TimingConst.WORK_MEASURE]          = work_measure,
  [TimingConst.WORK_MAINTAIN]         = work_maintain,
  [TimingConst.WORK_ERROR]            = work_error,
  [TimingConst.WORK_INITPRIMING]      = work_initpriming,
  [TimingConst.WORK_DRAIN]            = work_drain,
  [TimingConst.WORK_DECONTAMINATION]  = work_decontamination,
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

  -- ������������
  if item.smotor then                                   -- �ж�ʱ��ڵ����������������Ƿ�Ϊnil
    info = "[SMOTOR]: "
    xmotor = item.smotor
    if type(xmotor) == "table" then                     -- ���smotor���õ���table����
      if xmotor.op == TimingConst.MOTOR_RUN then        -- ���ִ�е���run����
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("SMOTOR missing parameter")
        end
        info = info .. string.format("<RUN> %.2fr, %.2frpm", xmotor.rounds, omega) -- ��ӡ��Ӧ������Ϣ,�����ڵ���
        motor.run(TimingConst.SMOTOR, xmotor.rounds, omega)    -- ִ��run����
      elseif xmotor.op == TimingConst.MOTOR_CHSPEED then-- ���ִ�е��Ǳ��ٲ���
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("SMOTOR missing parameter")
        end
        info = info .. string.format("<CHSPEED> %.2frpm", omega)
        motor.chspeed(TimingConst.SMOTOR, omega)        -- ִ�б��ٶ���
      elseif xmotor.op == TimingConst.MOTOR_RESET then  -- ���ִ�е��Ǹ�λ����
        info = info .. "<RESET>"
        motor.reset(TimingConst.SMOTOR)                 -- ִ�и�λ����
      elseif xmotor.op == TimingConst.MOTOR_STOP then   -- ���ִ�е���ֹͣ����
        info = info .. "<STOP>"
        motor.stop(TimingConst.SMOTOR)                  -- ִ��ֹͣ����
      end
    elseif type(xmotor) == "function" then              -- ���smotor���õ���function����
      info = info .. "<CALL>"
      xmotor()                                          -- �����Զ��庯��
    else                                                -- ���smotor���õ�����������
      info = info .. "<NIL>"
    end
    logger:info(info)
  end

  -- ע�����������
  if item.imotor then                                   -- �ж�ʱ��ڵ���ע������������Ƿ�Ϊnil
    info = "[IMOTOR]: "
    xmotor = item.imotor
    if type(xmotor) == "table" then                     -- ���imotor���õ���table����
      if xmotor.op == TimingConst.MOTOR_RUN then        -- ���ִ�е���run����
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("IMOTOR missing parameter")
        end
        info = info .. string.format("<RUN> %.2fr, %.2frpm", xmotor.rounds, omega)
        motor.run(TimingConst.IMOTOR, xmotor.rounds, omega)    -- ִ��run����
      elseif xmotor.op == TimingConst.MOTOR_CHSPEED then-- ���ִ�е��Ǳ��ٲ���
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("IMOTOR missing parameter")
        end
        info = info .. string.format("<CHSPEED> %.2frpm", omega)
        motor.chspeed(TimingConst.IMOTOR, omega)        -- ִ�б��ٶ���
      elseif xmotor.op == TimingConst.MOTOR_RESET then  -- ���ִ�е��Ǹ�λ����
        info = info .. "<RESET>"
        motor.reset(TimingConst.IMOTOR)                 -- ִ�и�λ����
      elseif xmotor.op == TimingConst.MOTOR_STOP then   -- ���ִ�е���ֹͣ����
        info = info .. "<STOP>"
        motor.stop(TimingConst.IMOTOR)                  -- ִ��ֹͣ����
      end
    elseif type(xmotor) == "function" then              -- ���smotor���õ���function����
      info = info .. "<CALL>"
      xmotor()                                          -- �����Զ��庯��
    else                                                -- ���smotor���õ�����������
      info = info .. "<NIL>"
    end
    logger:info(info)
  end

  -- �䶯�õ������
  if item.pmotor then                                   -- �ж�ʱ��ڵ����䶯�õ�������Ƿ�Ϊnil
    info = "[PMOTOR]: "
    xmotor = item.pmotor
    if type(xmotor) == "table" then                     -- ���pmotor���õ���table����
      if xmotor.op == TimingConst.MOTOR_RUN then        -- ���ִ�е���run����
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("PMOTOR missing parameter")
        end
        info = info .. string.format("<RUN> %.2fr, %.2frpm", xmotor.rounds, omega)
        motor.run(TimingConst.PMOTOR, xmotor.rounds, omega)    -- ִ��run����
      elseif xmotor.op == TimingConst.MOTOR_CHSPEED then-- ���ִ�е��Ǳ��ٲ���
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("PMOTOR missing parameter")
        end
        info = info .. string.format("<CHSPEED> %.2frpm", omega)
        motor.chspeed(TimingConst.PMOTOR, omega)        -- ִ�б��ٶ���
      elseif xmotor.op == TimingConst.MOTOR_RESET then  -- ���ִ�е��Ǹ�λ����
        info = info .. "<RESET>"
        motor.reset(TimingConst.PMOTOR)                 -- ִ�и�λ����
      elseif xmotor.op == TimingConst.MOTOR_STOP then   -- ���ִ�е���ֹͣ����
        info = info .. "<STOP>"
        motor.stop(TimingConst.PMOTOR)                  -- ִ��ֹͣ����
      end
    elseif type(xmotor) == "function" then              -- ���smotor���õ���function����
      info = info .. "<CALL>"
      xmotor()                                          -- �����Զ��庯��
    else                                                -- ���smotor���õ�����������
      info = info .. "<NIL>"
    end
    logger:info(info)
  end
end

function work:subTimingInit()                           -- subʱ�����̿��Ƴ�ʼ��
  logger:info("subTimingInit:", self.grpIdx)
  self.subIdx = 1
  if self.subBeginHook then self:subBeginHook() end     -- �Ƿ���Ҫ��ʼ���ص�
end

function work:subTimingRun()                            -- subʱ������ִ��
  local sub = self.sub                                  -- ��ȡ��ǰsubʱ������
  local idx = 1                                         -- subʱ��ڵ������
  if sub.idx then
  logger:info("subTimingRun: ", sub.sub.name, sub.idx.name)
  else
  logger:info("subTimingRun: ", sub.sub.name)
  end
  while true do
    local item = self:itemGet()                         -- ��subʱ�������л��һ���ڵ�
    if not item then break end                          -- �����õĽڵ�Ϊnil,Ҳ����˵����ʱ���β,���˳�
    if sub.idx then
    logger:info(string.format("-> idx:%3d[0x%02x], ticks:%4d", idx, sub.idx[idx], item.ticks))
    else
    logger:info(string.format("-> idx:%3d[0x%02x], ticks:%4d", idx, idx, item.ticks))
    end
    if item.beginhook then
      item.beginhook(self, item)
    end
    self:itemRun(item)                                  -- ִ�л�õĽڵ�
    subwork:alarmstart(item.ticks)
    subwork:alarmwait(0)
    if item.endhook then
      item.endhook(self, item)
    end
    idx = idx + 1                                       -- ��һ���ڵ�
  end
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
  --self.grp = timing[self.timingName]                    -- ����ʱ�������grpʱ������
  --self.grpIdx = 1
  --self.grpCnt = 1
  if self.grpBeginHook then self:grpBeginHook() end     -- �Ƿ���Ҫ��ʼ���ص�
end

function work:grpTimingRun()                            -- grpʱ������ִ��
  local grp = self.grp
  logger:info("grpTimingRun: ", grp.name)
  while self.grpIdx <= #grp do                          -- ѭ��grp��ÿһ��subʱ��
    self.sub = grp[self.grpIdx]                         -- ��õ�ǰ��subʱ��

    self:subTimingProcess()                             -- ִ��subʱ������

    self.grpIdx = self.grpIdx + 1                       -- ��һ��sub
    self.grpCnt = self.grpCnt + 1
  end
end

function work:grpTimingQuit()                           -- grpʱ�������˳�
  if self.grpEndHook then self:grpEndHook() end         -- �Ƿ���Ҫ�˳��ص�
  logger:info("grpTimingQuit")
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
  
  while grpIdx <= #grp do
    local sub = grp[grpIdx]
    subIdx = 1
    while true do
      index = subIdx
      subIdx = subIdx + 1
      if sub.idx then index = sub.idx[index] end        -- ��ȡ�ڵ�����
      item = sub.sub[index]                             -- ��ȡʱ����еĽڵ�
      -- todo add shadow ticks
      if item then ticks = ticks + item.ticks
      else break end
    end
    if sub.ishand then break end
    grpIdx = grpIdx + 1
  end
  return ticks
end

function work:setstate()
	work.stateTo = subwork.ToLua.Stateto
	logger:info(work.stateTo)
	work:select()
	return true
end

return work

--work.stateTo = TimingConst.WORK_STARTUP                 -- Ĭ������Ϊ������ʼ��״̬
--work.stateTo = TimingConst.WORK_MAINTAIN
--work.stateTo = TimingConst.WORK_MEASURE;
--work.maintainTo = TimingConst.MAINTAIN_DEBUBBLE
--work.stateTo = TimingConst.WORK_IDLE
--logger:info(work.stateTo)
--work:select()
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
    work.stateTo = TimingConst.WORK_ERROR
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
