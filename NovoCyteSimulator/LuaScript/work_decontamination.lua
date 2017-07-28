#!/usr/local/bin/lua
--******************************************************************************
-- work_decontamination.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work_decontamination = work_decontamination or {}
setmetatable(work_decontamination, {__index = work})

function work_decontamination:init ()
  self.timingName = "decontamination"
  self.grp = nil
  self.sub = nil
  --[[
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  --]]
  logger:info("work decontamination: init")
  logger:info("StateTo: ", self.stateTo)
end

function work_decontamination:run ()
  logger:info("work decontamination: run")
  self:grpTimingProcess()
end

function work_decontamination:quit ()
  logger:info("work decontamination: quit")
  self.stateTo = TimingConst.WORK_IDLE
end

function work_decontamination:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

return work_decontamination

--******************************************************************************
-- No More!
--******************************************************************************
