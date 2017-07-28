#!/usr/local/bin/lua
--******************************************************************************
-- work_idle.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work_idle = work_idle or {}                 -- 创建idle控制表
setmetatable(work_idle, {__index = work})   -- 继承自work表

function work_idle:preinit()
  
end

function work_idle:prequit()

end

function work_idle:init ()                  -- idle初始化
  logger:info("work idle: init")
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.grp = nil
  self.sub = nil
  logger:info(subwork:ctrlto())
  subwork:stateset(self.stateTo, 0, 0)
  motor.config(TimingConst.SMOTOR, 256, 0.25)
  motor.config(TimingConst.IMOTOR, 256, 0.25)
  motor.config(TimingConst.PMOTOR,  16, 0.25)
end

function work_idle:run ()                   -- 执行idle
  local ctrlto
  logger:info("work idle: run")
  while true do
    _,ctrlto = subwork:ctrlto()
	logger:info(ctrlto);
    if ctrlto ~= TimingConst.WORK_IDLE then
      self.stateTo = ctrlto
      break
    else
	logger:info("-------------------");
      tmr.delayms(200)
    end
  end
end

function work_idle:quit ()                  -- 退出idle
  motor.config(TimingConst.SMOTOR, 256, 0.75)
  motor.config(TimingConst.IMOTOR, 256, 0.75)
  motor.config(TimingConst.PMOTOR,  16, 0.75)
  logger:info("work idle: quit")
end

function work_idle:process ()               -- idle状态下的控制流程
  self:init()                               -- 初始化
  self:run()                                -- 执行
  self:quit()                               -- 退出
  return self.stateTo                       -- 返回下一个将要执行的时序状态
end

return work_idle                            -- 返回idle控制表,供外部调用

--******************************************************************************
-- No More!
--******************************************************************************
