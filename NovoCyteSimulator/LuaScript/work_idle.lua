#!/usr/local/bin/lua
--******************************************************************************
-- work_idle.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

require "LuaScript\\config"

work_idle = work_idle or {}                 -- 创建idle控制表

local stateTo

function work_idle:check()
  logger:info("work_idle_check:check whether motor at home")
  --local smotor_hs
  --local imotor_hs
  --_, _, smotor_hs = motor:optstate(TimingConst.SMOTOR)              -- 检查样本针是否停在光耦中
  --_, _, imotor_hs = motor:optstate(TimingConst.IMOTOR)              -- 检查注射器是否停在光耦中
  --pmotor_ht       = motor:optstate(TimingConst.PMOTOR)              -- 检查注射器是否停在光耦中
  --
  --if not smotor_hs or not imotor_hs or not pmotor_hs then
    self.stateTo = TimingConst.WORK_MOTORGOHOME
    work:select()
  --else 
  return
  --end

end

function work_idle:init ()                  -- idle初始化
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

function work_idle:run ()                   -- 执行idle
  logger:info("work idle: run")
  local ret
  local ctrlTo, ref1, ref2
  local sleeptime = config.sleeptime.idleduration * tmr:tickspermin()             --进入休眠的时间
  local tstart = tmr:systicks()                                                   --查询系统当前时间节点
  local idleduration = 0
  while true do
    ret = subwork:idlewait(200)
    idleduration = tmr:systicks() - tstart
    if ret == TimingConst.WORK_QUIT_Wait and idleduration >= sleeptime then       --判断仪器空闲时间长度是否达到休眠时间
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

function work_idle:quit ()                  -- 退出idle
  motor:config(TimingConst.SMOTOR, 256, 0.65)
  motor:config(TimingConst.IMOTOR, 256, 0.30)
  motor:config(TimingConst.PMOTOR,  16, 0.40)
  logger:info("work idle: quit")
  subwork:Print("work idle: quit");
  subwork.FromLua.State = self.stateTo
end

function work_idle:process ()               -- idle状态下的控制流程
  self:check()                              -- 进入待机前检查加样针&注射器是否停在光耦中
  self:init()                               -- 初始化
  self:run()                                -- 执行
  if stateTo == TimingConst.WORK_MEASURE then
    self:check()                            -- 若执行测试流程,则退出待机前检查
  end
  self:quit()                               -- 退出
  self.stateTo = stateTo
  return self.stateTo                       -- 返回下一个将要执行的时序状态
end

setmetatable(work_idle, {__index = work, __newindex = work})

return work_idle                            -- 返回idle控制表,供外部调用

--******************************************************************************
-- No More!
--******************************************************************************
