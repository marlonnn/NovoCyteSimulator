#!/usr/local/bin/lua
--******************************************************************************
-- work_idle.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

require "LuaScript\\config"

work_idle = work_idle or {}                 -- ����idle���Ʊ�

local stateTo

function work_idle:check()
  logger:info("work_idle_check:check whether motor at home")
  --local smotor_hs
  --local imotor_hs
  --_, _, smotor_hs = motor:optstate(TimingConst.SMOTOR)              -- ����������Ƿ�ͣ�ڹ�����
  --_, _, imotor_hs = motor:optstate(TimingConst.IMOTOR)              -- ���ע�����Ƿ�ͣ�ڹ�����
  --pmotor_ht       = motor:optstate(TimingConst.PMOTOR)              -- ���ע�����Ƿ�ͣ�ڹ�����
  --
  --if not smotor_hs or not imotor_hs or not pmotor_hs then
    self.stateTo = TimingConst.WORK_MOTORGOHOME
    work:select()
  --else 
  return
  --end

end

function work_idle:init ()                  -- idle��ʼ��
  logger:info("work idle: init")
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.grp = nil
  self.sub = nil
  subwork:stateset(TimingConst.WORK_IDLE, 0, 0)
  subwork:timeset(0, 0)
  motor:config(TimingConst.SMOTOR, 256, 0.65)
  motor:config(TimingConst.IMOTOR, 256, 0.10)
  motor:config(TimingConst.PMOTOR,  16, 0.10)
end

function work_idle:run ()                   -- ִ��idle
  logger:info("work idle: run")
  local ret
  local ctrlTo, ref1, ref2
  local sleeptime = config.sleeptime.idleduration * tmr:tickspermin()             --�������ߵ�ʱ��
  local tstart = tmr:systicks()                                                   --��ѯϵͳ��ǰʱ��ڵ�
  local idleduration = 0
  while true do
    ret = subwork:idlewait(200)
    idleduration = tmr:systicks() - tstart
    if ret == TimingConst.WORK_QUIT_Wait and idleduration >= sleeptime then       --�ж���������ʱ�䳤���Ƿ�ﵽ����ʱ��
	  stateTo =  TimingConst.WORK_SLEEPENTER
      break
    elseif ret ~= TimingConst.WORK_QUIT_Wait and ret ~= TimingConst.WORK_QUIT_AbortOthers then
      void, ctrlTo, ref1, ref2 = subwork:ctrlto()
      stateTo = ctrlTo
      self.subref1 = ref1
      self.subref2 = ref2
      break
    end
  end
end

function work_idle:quit ()                  -- �˳�idle
  motor:config(TimingConst.SMOTOR, 256, 0.65)
  motor:config(TimingConst.IMOTOR, 256, 0.30)
  motor:config(TimingConst.PMOTOR,  16, 0.40)
  logger:info("work idle: quit")
  subwork:Print("work idle: quit");
  subwork.FromLua.State = self.stateTo
end

function work_idle:process ()               -- idle״̬�µĿ�������
  self:check()                              -- �������ǰ��������&ע�����Ƿ�ͣ�ڹ�����
  self:init()                               -- ��ʼ��
  self:run()                                -- ִ��
  if stateTo == TimingConst.WORK_MEASURE then
    self:check()                            -- ��ִ�в�������,���˳�����ǰ���
  end
  self:quit()                               -- �˳�
  self.stateTo = stateTo
  return self.stateTo                       -- ������һ����Ҫִ�е�ʱ��״̬
end

setmetatable(work_idle, {__index = work, __newindex = work})

return work_idle                            -- ����idle���Ʊ�,���ⲿ����

--******************************************************************************
-- No More!
--******************************************************************************
