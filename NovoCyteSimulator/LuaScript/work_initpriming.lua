#!/usr/local/bin/lua
--******************************************************************************
-- work_initpriming.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work_initpriming = work_initpriming or {}

function work_initpriming:init ()
  self.timingName = "initpriming"
  self.grp = timing[self.timingName]            -- 根据时序名获得grp时序引用
  subwork.stateset(self.stateTo, 0, 0)          -- 设置首次灌注状态,等待上位机命令
  logger:info("work initpriming: init")
end

function work_initpriming:run ()                      -- 执行initpriming
  logger:info("work initpriming: run")
  while true do
    local ret = subwork.idlewait(200)
    if     ret == TimingConst.WORK_QUIT_Normal then
      self.stateTo, self.subref1, self.subref2 = subwork.ctrlto()
      if self.subref1 > #self.grp then
        subwork.stateset(TimingConst.WORK_IDLE, 0, 0)
        self.isrecordnil = false
        work_record:stateset(TimingConst.WORK_IDLE, 0, 0)
        self.stateTo = TimingConst.WORK_STARTUP
        return self.stateTo
      else
        self.grpIdx = self.subref1
        self.subIdx = 1
        self.grpCnt = 1
        self.subCnt = 1
        self.sub = nil
        local tstart = tmr.systicks()
        local ttotal = self:timecalc()
        subwork.timeset(tstart, ttotal)
        subwork.stateset(self.stateTo, self.Step(self.grpIdx,TimingConst.WORK_DOING), 0)
        work_record:stateset(self.stateTo, self.subref1, self.subref2)
        self:grpTimingProcess()
        subwork.stateset(self.stateTo, self.Step(self.grpIdx,TimingConst.WORK_DONE), 0)
        work_record:stateset(self.stateTo, self.subref1 + 1, self.subref2)
      end
    elseif ret == TimingConst.WORK_QUIT_AbortShutdown then return
    end
  end
end

function work_initpriming:quit ()
  logger:info("work initpriming: quit")
  --if self.quittype ~= TimingConst.WORK_QUIT_Normal then
  --end
end

function work_initpriming:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

setmetatable(work_initpriming, {__index = work, __newindex = work})    -- 继承自work表

return work_initpriming

--******************************************************************************
-- No More!
--******************************************************************************
