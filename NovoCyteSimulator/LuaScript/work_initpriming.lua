#!/usr/local/bin/lua
--******************************************************************************
-- work_initpriming.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work_initpriming = work_initpriming or {}
setmetatable(work_initpriming, {__index = work})

function work_initpriming:init ()
  self.timingName = "initpriming"
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.grp = timing[self.timingName]            -- 根据时序名获得grp时序引用
  self.sub = nil
  local tstart = tmr.systicks()
  local ttotal = self:timecalc()
  subwork:stateset(self.stateTo, 0, 0)
  subwork:timeset(tstart, ttotal)
  logger:info("work initpriming: init, ttotal: ", ttotal)
  logger:info("StateTo: ", self.stateTo)
end

function work_initpriming:run ()
  logger:info("work initpriming: run")
  self:grpTimingProcess()
end

function work_initpriming:quit ()
  logger:info("work initpriming: quit")
  self.stateTo = TimingConst.WORK_IDLE
end

function work_initpriming:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

return work_initpriming

--******************************************************************************
-- No More!
--******************************************************************************
