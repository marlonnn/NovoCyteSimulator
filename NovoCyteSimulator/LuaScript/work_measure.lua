#!/usr/local/bin/lua
--******************************************************************************
-- work_measure.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work_measure = work_measure or {}
setmetatable(work_measure, {__index = work})

function work_measure:init ()
  self.timingName = "measure"
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.grp = timing[self.timingName]            -- 根据时序名获得grp时序引用
  self.sub = nil
  subwork:stateset(self.stateTo, 0, 0)
  void, self.testsel, self.isextdata, self.cleannums = subwork:testinfoget()
  self.cleancnt = 0
  logger:info("work measure: init")
  logger:info("StateTo: ", self.stateTo)
end

function work_measure:clean()
  local iscontinue = false
  
  if self.cleancnt < self.cleannums then
    self.cleancnt = self.cleancnt + 1
    if self.cleancnt == 1 then
      self.timingName = "test_clean_first"
    else
      self.timingName = "test_clean_others"
    end
    self.grpIdx = 1
    self.subIdx = 1
    self.grpCnt = 1
    self.subCnt = 1
    self.grp = timing[self.timingName]            -- 根据时序名获得grp时序引用
    self.sub = nil
    iscontinue = true
  else if self.cleannums == 0 then
    if self.cleancnt < 1 then
      self.cleancnt = self.cleancnt + 1
      self.timingName = "test_clean_none"
      self.grpIdx = 1
      self.subIdx = 1
      self.grpCnt = 1
      self.subCnt = 1
      self.grp = timing[self.timingName]            -- 根据时序名获得grp时序引用
      self.sub = nil
      iscontinue = true
    end
  end
  end
  
  return iscontinue  
end

function work_measure:run ()
  local iscontinue
  logger:info("work measure: run")
  self:grpTimingProcess()
  
  while self:clean() do
    self:grpTimingProcess()
  end
end

function work_measure:quit ()
  logger:info("work measure: quit")
  self.stateTo = TimingConst.WORK_IDLE
end

function work_measure:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

return work_measure

--******************************************************************************
-- No More!
--******************************************************************************
