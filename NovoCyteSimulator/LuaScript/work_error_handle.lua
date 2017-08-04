#!/usr/local/bin/lua
--******************************************************************************
-- work_maintain.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

require "LuaScript\\TimingConst"

work_error_handle = work_error_handle or {}

local error_resume_list = {
  [ErrorConst.HandleErrorConst.SIPCOLLISION]      = resume_sipcollision,
  [TimingConst.ERROR_RESUME_PRESSURE]             = resume_pressure,
  [TimingConst.ERROR_RESUME_PRESSUREEXT]          = resume_pressureext,
  [TimingConst.ERROR_RESUME_SIPABNORMAL]          = resume_sipabnormal
}

function work_error_handle:select(sel)
  local subprocess = error_resume_list[sel]
  if subprocess ~= nil then
    subprocess:process()
  end
end

function work_error_handle:init ()
  logger:info("work error: init")
  logger:info("StateTo: ", self.stateTo)
end

function work_error_handle:run ()
  logger:info("work error: run")
  self.maintainTo = self.subref1
  self:select(self.maintainTo)
end

function work_error_handle:quit ()
  logger:info("work error: quit")
  if self.quittype ~= TimingConst.WORK_QUIT_AbortShutdown then
    self.stateTo = TimingConst.WORK_IDLE
  else 
    local ctrlTo, ref1, ref2 = subwork.ctrlto()
    self.stateTo = ctrlTo
    self.subref1 = ref1
    self.subref2 = ref2
  end
end

function work_error_handle:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

setmetatable(work_error_handle, {__index = work, __newindex = work})    -- 继承自work表

return work_error_handle

--******************************************************************************
-- No More!
--******************************************************************************
