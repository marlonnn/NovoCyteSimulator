#!/usr/local/bin/lua

work_sleep = work_sleep or {}

function work_sleep:preinit()
  
end

function work_sleep:prequit()

end

function work_sleep:init ()
  logger:info("work sleep: init")
  subwork:print("work sleep: init")
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.grp = nil
  self.sub = nil
  subwork:stateset(self.stateTo, 0, 0)
  subwork:timeset(0, 0)
  motor.config(TimingConst.SMOTOR, 256, 0.65)
  motor.config(TimingConst.IMOTOR, 256, 0.10)
  motor.config(TimingConst.PMOTOR,  16, 0.10)
end

function work_sleep:run ()
  logger:info("work sleep: run")
  subwork:print("work sleep: run")
  local ret
  local ctrlTo, ref1, ref2
  while true do
    ret = subwork:idlewait(200)
    if ret ~= TimingConst.WORK_QUIT_Wait and ret ~= TimingConst.WORK_QUIT_AbortOthers then
      ctrlTo, ref1, ref2 = subwork:ctrlto()
      self.stateTo = ctrlTo
      self.subref1 = ref1
      self.subref2 = ref2
      break
    end
  end
end

function work_sleep:quit ()
  motor.config(TimingConst.SMOTOR, 256, 0.65)
  motor.config(TimingConst.IMOTOR, 256, 0.30)
  motor.config(TimingConst.PMOTOR,  16, 0.40)
  logger:info("work sleep: quit")
  subwork:print("work sleep: quit")
end

function work_sleep:process ()
  self:init()
  self:run()
  self:quit()
  return self.stateTo
end

setmetatable(work_sleep, {__index = work, __newindex = work})

return work_sleep

--******************************************************************************
-- No More!
--******************************************************************************
