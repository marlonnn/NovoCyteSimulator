#!/usr/local/bin/lua
--******************************************************************************
-- work_sleepexit.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work_sleepexit = work_sleepexit or {}

function work_sleepexit:init ()
  self.timingName = "sleep_exit"
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.grp = timing[self.timingName]
  self.sub = nil
  local tstart = tmr.systicks()
  local ttotal = self:timecalc()
  subwork.stateset(self.stateTo, 0, 0)
  subwork.timeset(tstart, ttotal)
  logger:info("work sleepexit: init, ttotal: ", ttotal)
  logger:info("StateTo: ", self.stateTo)
end

function work_sleepexit:run ()
  logger:info("work sleepexit: run")
  self:grpTimingProcess()
end

function work_sleepexit:quit ()
  logger:info("work sleepexit: quit")
  if self.quittype ~= TimingConst.WORK_QUIT_AbortShutdown then
    self.stateTo = TimingConst.WORK_IDLE
  else
    local ctrlTo, ref1, ref2 = subwork.ctrlto()
    self.stateTo = ctrlTo
    self.subref1 = ref1
    self.subref2 = ref2
  end
end

function work_sleepexit:process ()                -- startup状态下的控制流程
  self:init()                                   -- 初始化
  self:run()                                    -- 执行
  self:quit()                                   -- 退出
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo                           -- 返回下一个将要执行的时序状态
end

setmetatable(work_sleepexit, {__index = work, __newindex = work})    -- 继承自work表

return work_sleepexit                             -- 返回startup控制表,供外部调用

--******************************************************************************
-- No More!
--******************************************************************************
