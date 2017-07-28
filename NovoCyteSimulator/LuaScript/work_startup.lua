#!/usr/local/bin/lua
--******************************************************************************
-- work_startup.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work_startup = work_startup or {}               -- 创建startup控制表
setmetatable(work_startup, {__index = work})    -- 继承自work表

function work_startup:init ()                   -- startup初始化
  self.timingName = "startup"                   -- 通过该名称查找时序表
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.grp = timing[self.timingName]            -- 根据时序名获得grp时序引用
  self.sub = nil
  local tstart = tmr.systicks()
  local ttotal = self:timecalc()
  subwork:stateset(self.stateTo, 0, 0)
  subwork:timeset(tstart, ttotal)
  motor.config(TimingConst.SMOTOR, 256, 0.75)
  motor.config(TimingConst.IMOTOR, 256, 0.75)
  motor.config(TimingConst.PMOTOR,  16, 0.75)
  logger:info("work startup: init, ttotal: ", ttotal)
  logger:info("StateTo: ", self.stateTo)
end

function work_startup:run ()                    -- 执行startup
  logger:info("work startup: run")
  self:grpTimingProcess()                       -- 执行时序流程
end

function work_startup:quit ()                   -- 退出startup
  motor.config(TimingConst.SMOTOR, 256, 0.25)
  motor.config(TimingConst.IMOTOR, 256, 0.25)
  motor.config(TimingConst.PMOTOR,  16, 0.25)
  logger:info("work startup: quit")
  self.stateTo = TimingConst.WORK_IDLE          -- 状态切换到IDLE
end

function work_startup:process ()                -- startup状态下的控制流程
  self:init()                                   -- 初始化
  self:run()                                    -- 执行
  self:quit()                                   -- 退出
  logger:info("StateTo: ", self.stateTo)
  return self.stateTo                           -- 返回下一个将要执行的时序状态
end

return work_startup                             -- 返回startup控制表,供外部调用

--******************************************************************************
-- No More!
--******************************************************************************
