#!/usr/local/bin/lua
--******************************************************************************
-- maintain_cleaning.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

--require "work_maintain"

maintain_cleaning = maintain_cleaning or {}
setmetatable(maintain_cleaning, {__index = work_maintain})

function maintain_cleaning:init ()
  self.timingName = "maintain_cleaning"
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
  logger:info("work cleaning: init, ttotal: ", ttotal)
  logger:info("StateTo: ", self.stateTo)
end

function maintain_cleaning:run ()
  logger:info("work cleaning: run")
  self:grpTimingProcess()
end

function maintain_cleaning:quit ()
  logger:info("work cleaning: quit")
  self.stateTo = TimingConst.WORK_IDLE
end

function maintain_cleaning:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

return maintain_cleaning

--******************************************************************************
-- No More!
--******************************************************************************
