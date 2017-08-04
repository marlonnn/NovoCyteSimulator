#!/usr/local/bin/lua

work_sleepenter = work_sleepenter or {}

function work_sleepenter:init ()                   -- startup初始化
  self.timingName = "sleep_enter"                   -- 通过该名称查找时序表
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.grp = timing[self.timingName]                -- 根据时序名获得grp时序引用
  self.sub = nil
  local tstart = tmr.systicks()
  local ttotal = self:timecalc()
  subwork.stateset(self.stateTo, 0, 0)
  subwork.timeset(tstart, ttotal)
  
  logger:info("work sleepenter: init, ttotal: ", ttotal)
  logger:info("StateTo: ", self.stateTo)
end

function work_sleepenter:run ()
  logger:info("work sleepenter: run")
  self:grpTimingProcess()
end

function work_sleepenter:quit () 
  logger:info("work sleepenter: quit")
  if self.quittype == TimingConst.WORK_QUIT_Normal then
    self.stateTo = TimingConst.WORK_SLEEP
  else
    local ctrlTo, ref1, ref2 = subwork.ctrlto()
    self.stateTo = ctrlTo
    self.subref1 = ref1
    self.subref2 = ref2
  end
end

function work_sleepenter:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo                                                  -- 返回下一个将要执行的时序状态
end

setmetatable(work_sleepenter, {__index = work, __newindex = work})    -- 继承自work表

return work_sleepenter                                                -- 返回startup控制表,供外部调用

--******************************************************************************
-- No More!
--******************************************************************************
