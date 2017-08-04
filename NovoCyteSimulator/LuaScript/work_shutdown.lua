#!/usr/local/bin/lua
--******************************************************************************
-- work_shutdown.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work_shutdown = work_shutdown or {}

function work_shutdown:init ()
  self.timingName = "shutdown"
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
  logger:info("work shutdown: init, ttotal: ", ttotal)
  logger:info("StateTo: ", self.stateTo)
end

function work_shutdown:run ()
  logger:info("work shutdown: run")
  --self:grpTimingProcess()
end

function work_shutdown:quit ()
  logger:info("work shutdown: quit")
  self.stateTo = TimingConst.WORK_IDLE
  misc.poweroff()
end

function work_shutdown:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

setmetatable(work_shutdown, {__index = work, __newindex = work})    -- 继承自work表

return work_shutdown

--******************************************************************************
-- No More!
--******************************************************************************
