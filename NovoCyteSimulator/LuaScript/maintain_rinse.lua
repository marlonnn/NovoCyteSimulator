#!/usr/local/bin/lua
--******************************************************************************
-- maintain_rinse.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

--require "work_maintain"

maintain_rinse = maintain_rinse or {}
setmetatable(maintain_rinse, {__index = work_maintain})

function maintain_rinse:init ()
  self.timingName = "maintain_rinse"
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
  logger:info("work rinse: init, ttotal: ", ttotal)
  logger:info("StateTo: ", self.stateTo)
end

function maintain_rinse:run ()
  logger:info("work rinse: run")
  self:grpTimingProcess()
end

function maintain_rinse:quit ()
  logger:info("work rinse: quit")
  self.stateTo = TimingConst.WORK_IDLE
end

function maintain_rinse:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

return maintain_rinse

--******************************************************************************
-- No More!
--******************************************************************************
