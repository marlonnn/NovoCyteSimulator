#!/usr/local/bin/lua
--******************************************************************************
-- work_idle.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work_idle = work_idle or {}                 -- ����idle���Ʊ�
setmetatable(work_idle, {__index = work})   -- �̳���work��

function work_idle:preinit()
  
end

function work_idle:prequit()

end

function work_idle:init ()                  -- idle��ʼ��
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

function work_idle:run ()                   -- ִ��idle
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

function work_idle:quit ()                  -- �˳�idle
  motor.config(TimingConst.SMOTOR, 256, 0.75)
  motor.config(TimingConst.IMOTOR, 256, 0.75)
  motor.config(TimingConst.PMOTOR,  16, 0.75)
  logger:info("work idle: quit")
end

function work_idle:process ()               -- idle״̬�µĿ�������
  self:init()                               -- ��ʼ��
  self:run()                                -- ִ��
  self:quit()                               -- �˳�
  return self.stateTo                       -- ������һ����Ҫִ�е�ʱ��״̬
end

return work_idle                            -- ����idle���Ʊ�,���ⲿ����

--******************************************************************************
-- No More!
--******************************************************************************
