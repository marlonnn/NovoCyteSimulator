#!/usr/local/bin/lua

work_motorgohome = work_motorgohome or {}

function work_motorgohome:init ()
  self.timingName = "motorgohome"
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.grp = timing[self.timingName]
  self.sub = nil
  local tstart = tmr.systicks()
  local ttotal = self:timecalc()
  --subwork.stateset(0, 0, 0)
  --subwork.timeset(tstart, ttotal)
  logger:info("work motorgohome: init, ttotal: ", ttotal)
  logger:info("StateTo: ", self.stateTo)
end

function work_motorgohome:run ()
  logger:info("work motorgohome: run")
  self:grpTimingProcess()
end

function work_motorgohome:quit ()
  logger:info("work motorgohome: quit")
  if self.quittype ~= TimingConst.WORK_QUIT_AbortShutdown then
    self.stateTo = TimingConst.WORK_IDLE
  else 
    local ctrlTo, ref1, ref2 = subwork.ctrlto()
    self.stateTo = ctrlTo
    self.subref1 = ref1
    self.subref2 = ref2
  end
end

function work_motorgohome:process ()
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

setmetatable(work_motorgohome, {__index = work, __newindex = work})    -- 继承自work表

return work_motorgohome

--******************************************************************************
-- No More!
--******************************************************************************
