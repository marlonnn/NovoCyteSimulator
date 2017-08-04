#!/usr/local/bin/lua
--******************************************************************************
-- maintain_unclog.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

----require "work_maintain"

maintain_unclog = maintain_unclog or {}

function maintain_unclog:init ()
  self.timingName = "maintain_unclog"
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.grp = timing[self.timingName]            -- 根据时序名获得grp时序引用
  self.sub = nil
  local tstart = tmr.systicks()
  local ttotal = self:timecalc()
  subwork:stateset(self.stateTo, self.subref1, 0)
  subwork:timeset(tstart, ttotal)
  logger:info("work unclog: init, ttotal: ", ttotal)
  logger:info("StateTo: ", self.stateTo)
end

function maintain_unclog:run ()
  logger:info("work unclog: run")
  self:grpTimingProcess()
end

function maintain_unclog:quit ()
  logger:info("work unclog: quit")
  --[[
  if self.quittype ~= TimingConst.WORK_QUIT_AbortShutdown then
    self.stateTo = TimingConst.WORK_IDLE
  else 
    local ctrlTo, ref1, ref2 = subwork.ctrlto()
    self.stateTo = ctrlTo
    self.subref1 = ref1
    self.subref2 = ref2
  end
  --]]
end

function maintain_unclog:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

setmetatable(maintain_unclog, {__index = work_maintain, __newindex = work_maintain})    -- 继承自work_maintain表

return maintain_unclog

--******************************************************************************
-- No More!
--******************************************************************************
