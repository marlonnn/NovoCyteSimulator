#!/usr/local/bin/lua
--******************************************************************************
-- error_resume_pressureext.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

--require "work_error_handle"

error_resume_pressureext = error_resume_pressureext or {}

function error_resume_pressureext:init ()
  self.timingName = "error_resume_pressureext"
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
  logger:info("work resume pressureext: init, ttotal: ", ttotal)
  logger:info("StateTo: ", self.stateTo)
end

function error_resume_pressureext:run ()
  logger:info("work resume pressureext: run")
  self:grpTimingProcess()
end

function error_resume_pressureext:quit ()
  logger:info("work resume pressureext: quit")
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

function error_resume_pressureext:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

setmetatable(error_resume_pressureext, {__index = work_error_handle, __newindex = work_error_handle})    -- 继承自work_error表

return error_resume_pressureext

--******************************************************************************
-- No More!
--******************************************************************************
