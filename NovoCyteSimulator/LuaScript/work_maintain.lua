#!/usr/local/bin/lua
--******************************************************************************
-- work_maintain.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

require "LuaScript\\TimingConst"

work_maintain = work_maintain or {}
setmetatable(work_maintain, {__index = work})

require "LuaScript\\maintain_debubble"
require "LuaScript\\maintain_cleaning"
require "LuaScript\\maintain_rinse"
require "LuaScript\\maintain_extrinse"
require "LuaScript\\maintain_priming"
require "LuaScript\\maintain_unclog"
require "LuaScript\\maintain_backflush"

local maintain_list = {
  [TimingConst.MAINTAIN_DEBUBBLE]   = maintain_debubble,
  [TimingConst.MAINTAIN_CLEANING]   = maintain_cleaning,
  [TimingConst.MAINTAIN_RINSE]      = maintain_rinse,
  [TimingConst.MAINTAIN_EXTRINSE]   = maintain_extrinse,
  [TimingConst.MAINTAIN_PRIMING]    = maintain_priming,
  [TimingConst.MAINTAIN_UNCLOG]     = maintain_unclog,
  [TimingConst.MAINTAIN_BACKFLUSH]  = maintain_backflush
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
  self:select(self.maintainTo)
end

function work_maintain:quit ()
  logger:info("work maintain: quit")
  self.stateTo = TimingConst.WORK_IDLE
end

function work_maintain:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

return work_maintain

--******************************************************************************
-- No More!
--******************************************************************************
