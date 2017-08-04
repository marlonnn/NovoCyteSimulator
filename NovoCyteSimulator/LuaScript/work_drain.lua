#!/usr/local/bin/lua
--******************************************************************************
-- work_drain.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work_drain = work_drain or {}

require "LuaScript\\work_record"                      -- 导入状态步骤记录函数

function work_drain:init ()
  self.timingName = "drain"
  self.grp = timing[self.timingName]            -- 根据时序名获得grp时序引用
  logger:info("work drain: init")
end

function work_drain:run ()                      -- 执行drain
  logger:info("work drain: run")
  if self.isrecordnil then
    subwork.stateset(self.stateTo, self.Step(self.subref1 - 1,TimingConst.WORK_DONE), 0)
    while true do
      local ret = subwork.idlewait(200)
      if  ret == TimingConst.WORK_QUIT_Normal then self:realrun() break 
      elseif ret == TimingConst.WORK_QUIT_AbortShutdown then
        subwork.stateset(TimingConst.WORK_IDLE, 0, 0)
        return
      end
    end
  else
    self:realrun()
  end

  while true do
    local ret = subwork.idlewait(200)
    if  ret == TimingConst.WORK_QUIT_Normal then
      self:realrun()
    elseif ret == TimingConst.WORK_QUIT_AbortShutdown then
      subwork.stateset(TimingConst.WORK_IDLE, 0, 0)
      return
    end
  end
end

function work_drain:realrun ()
  self.stateTo, self.subref1, self.subref2 = subwork.ctrlto()
  self.grpIdx = self.subref1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.sub = nil
  local tstart = tmr.systicks()
  local ttotal = self:timecalc()
  subwork.timeset(tstart, ttotal)
  subwork.stateset(self.stateTo, self.Step(self.grpIdx,TimingConst.WORK_DOING), 0)
  work_record:stateset(self.stateTo, self.subref1, self.subref2)
  self:grpTimingProcess()
  subwork.stateset(self.stateTo, self.Step(self.grpIdx,TimingConst.WORK_DONE), 0)
  if self.subref1 == #self.grp then
    work_record:stateset(TimingConst.WORK_INITPRIMING, 0, 0)
  else work_record:stateset(self.stateTo, self.subref1 + 1, self.subref2)
  end
end

function work_drain:quit ()
  logger:info("work drain: quit")
  misc.poweroff()
end

function work_drain:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

setmetatable(work_drain, {__index = work, __newindex = work})                  -- 继承自work表

return work_drain

--******************************************************************************
-- No More!
--******************************************************************************
