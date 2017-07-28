#!/usr/local/bin/lua
--******************************************************************************
-- motor.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--*******************************************************************************

motor = {}  -- ����motor��

function motor.config(id, microstep, current)
  logger:info(string.format("[CMD] MOTOR%d: microstep %d, current %.2f%%", id, microstep, current))
end

-- @brief ��motor����ʵ��run�Ŀ��ƹ���
-- @param id: �����Ƶ�motor ID��
--     round: ת��Ȧ��(��λ:r)
--     speed: �����ٶ�(��λ:rpm)
-- @return ��
-- @notes ��
function motor.run(id, round, speed)
  logger:info(string.format("[CMD] MOTOR%d: run %.2fr, speed %.2frpm", id, round, speed))
end

-- @brief ��motor����ʵ��stop�Ŀ��ƹ���
-- @param id: �����Ƶ�motor ID��
-- @return ��
-- @notes ��
function motor.stop(id)
  logger:info(string.format("[CMD] MOTOR%d STOP!!!", id))
end

-- @brief ��motor����ʵ��reset����
-- @param id: �����Ƶ�motor ID��
-- @return
-- @notes
function motor.reset(id)
  logger:info(string.format("[CMD] MOTOR%d Reset!!!", id))
end

-- @brief ��motor����ʵ�����б��ٹ���
-- @param id: �����Ƶ�motor ID��
--  newspeed: �µ������ٶ�(��λ:rpm)
-- @return
-- @notes
function motor.chspeed(id, newspeed)
  logger:info(string.format("[CMD] MOTOR%d Change Speed to %.2frpm", id, newspeed))
end

motor.BASEOMEGA = 100
motor.maxn = 3

return motor                              -- ����motor���Ʊ�,���ⲿ����

--******************************************************************************
-- No More!
--******************************************************************************
