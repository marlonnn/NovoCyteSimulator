#!/usr/local/bin/lua
--******************************************************************************
-- work_measure.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work_measure = work_measure or {
  isamplerounds = 0,                    -- 测试时imotor吸样圈数
  samplesize    = 0.0,                  -- 测试样本量
  samplerate    = 0.0,                  -- 测试样本流速

  testsel   = TimingConst.TEST_IS_ABS,  -- 绝对计数模式

  isextdata = false,                    -- 是否扩展数据采集
  isdrain   = false,                    -- 是否推掉样本

  cleannums = 0                         -- 清洗次数
}

local work_measure_list = {
  [TimingConst.TEST_IS_ABS]     = "measure_abs",
  [TimingConst.TEST_IS_NOABS]   = "measure_noabs"
}

function work_measure:init ()
  void, self.testsel, self.isextdata = subwork:testinfoget()
  self.timingName = work_measure_list[self.testsel]
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.grp = timing[self.timingName]            -- 根据时序名获得grp时序引用
  subwork:print("work measure init")
  subwork:print(self.grp)
  self.sub = nil
  local tstart = tmr:systicks()
  subwork:stateset(self.stateTo, 0, 0)
  subwork:timeset(tstart, 0)
  --subwork:testinfoset(0, 0)
  void, self.testsel, self.isextdata, self.cleannums = subwork:testinfoget()
  self.cleancnt = 0
  self.isdrain = false
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

function work_measure:awakehook()
  local void, runrounds = motor:status(TimingConst.IMOTOR)
  local testsecs = (tmr:systicks() - self.teststart) * 1000 / tmr:tickspersec()
  local factor = config.compensation[self.testsel].coef[config.instrumenttype]
  local testsize = runrounds * config.imotor.volumperround / factor
  --logger:warn(string.format("runrounds:%.2f, testsecs:%d, testsize:%.2f", runrounds, testsecs, testsize))
  subwork:testinfoset(testsecs, testsize)

  local _, ref1 = subwork:ctrlto()
  if subwork:cellisstop() or ref1 == 0 then
    subwork:alarmstop()
    self.isdrain = true
    return TimingConst.WORK_QUIT_Next
  end

  local remainrounds = self.isamplerounds - runrounds
  if remainrounds < 0.001 then
    subwork:alarmstop()
    subwork:cellstop(TimingConst.CELL_STOPWAY_OverSize)
    return TimingConst.WORK_QUIT_Next
  end

  local _, rate = subwork:sampleinfo()
  if rate ~= self.samplerate then
    local remainsize = remainrounds * config.imotor.volumperround
    if remainsize > 5.0 then
      self.samplerate = rate
      motor:chspeed(TimingConst.IMOTOR, rate*factor/config.imotor.volumperround)
    end
  end

  return TimingConst.WORK_QUIT_Wait
end

function work_measure:run ()
  local iscontinue
  logger:info("work measure: run")

  subwork:cellconfig()

  self:grpTimingProcess()

  if self.quittype == TimingConst.WORK_QUIT_Normal then
    void, _, _, self.cleannums = subwork:testinfoget()
    while self:clean() do
      self:grpTimingProcess()
    end
  end
end

function work_measure:quit ()
  logger:info("work measure: quit")
  if self.quittype ~= TimingConst.WORK_QUIT_AbortShutdown then
    self.stateTo = TimingConst.WORK_IDLE
  else 
    local ctrlTo, ref1, ref2 = subwork:ctrlto()
    self.stateTo = ctrlTo
    self.subref1 = ref1
    self.subref2 = ref2
  end
  subwork:print("---work measure quit---")
  subwork.FromLua.State = self.stateTo
end

function work_measure:process ()
  logger:info("start: ", self.stateTo)
  self:init()
  self:run()
  self:quit()
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo
end

setmetatable(work_measure, {__index = work, __newindex = work})    -- 继承自work表

return work_measure

--******************************************************************************
-- No More!
--******************************************************************************
