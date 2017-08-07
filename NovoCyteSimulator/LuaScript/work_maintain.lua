#!/usr/local/bin/lua
--******************************************************************************
-- work_maintain.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

require "LuaScript\\TimingConst"

work_maintain = work_maintain or {
  maintainTo = 0
}

require "LuaScript\\maintain_debubble"
require "LuaScript\\maintain_cleaning"
require "LuaScript\\maintain_priming"
require "LuaScript\\maintain_unclog"

local maintain_list = {
  [TimingConst.MAINTAIN_DEBUBBLE]   = maintain_debubble,
  [TimingConst.MAINTAIN_CLEANING]   = maintain_cleaning,
  [TimingConst.MAINTAIN_PRIMING]    = maintain_priming,
  [TimingConst.MAINTAIN_UNCLOG]     = maintain_unclog
}
--[[
setmetatable(maintain_list, {__index = function (t, k)
  return rawget(t, "__default")
end})
]]--
function work_maintain:select(sel)
  local subprocess = maintain_list[sel]
  if subprocess ~= nil then
    subprocess:process()
  end
end

function work_maintain:init ()
  logger:info("work maintain: init")
  logger:info("StateTo: ", self.stateTo)
end

function work_maintain:run ()
  logger:info("work maintain: run")
  self.maintainTo = self.subref1
  self:select(self.maintainTo)
end

function work_maintain:quit ()
  logger:info("work maintain: quit")
  if self.quittype ~= TimingConst.WORK_QUIT_AbortShutdown then
    self.stateTo = TimingConst.WORK_IDLE
  else 
    local _, ctrlTo, ref1, ref2 = subwork:ctrlto()
    self.stateTo = ctrlTo
    self.subref1 = ref1
    self.subref2 = ref2
  end
end

function work_maintain:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

setmetatable(work_maintain, {__index = work, __newindex = work})    -- 继承自work表

return work_maintain

--******************************************************************************
-- No More!
--******************************************************************************
