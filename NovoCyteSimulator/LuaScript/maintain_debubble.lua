#!/usr/local/bin/lua
--******************************************************************************
-- maintain_debubble.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

--require "work_maintain"

maintain_debubble = maintain_debubble or {}

function maintain_debubble:init ()
  self.timingName = "maintain_debubble"
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
  logger:info("work debubble: init, ttotal: ", ttotal)
  logger:info("StateTo: ", self.stateTo)
end

function maintain_debubble:run ()
  logger:info("work debubble: run")
  self:grpTimingProcess()
end

function maintain_debubble:quit ()
  logger:info("work debubble: quit")
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

function maintain_debubble:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

setmetatable(maintain_debubble, {__index = work_maintain, __newindex = work_maintain})    -- 继承自work_maintain表

return maintain_debubble

--******************************************************************************
-- No More!
--******************************************************************************
