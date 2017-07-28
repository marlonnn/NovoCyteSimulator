#!/usr/local/bin/lua
--******************************************************************************
-- motor.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--*******************************************************************************

motor = {}  -- 创建motor表

function motor.config(id, microstep, current)
  logger:info(string.format("[CMD] MOTOR%d: microstep %d, current %.2f%%", id, microstep, current))
end

-- @brief 在motor表中实现run的控制功能
-- @param id: 被控制的motor ID号
--     round: 转动圈数(单位:r)
--     speed: 运行速度(单位:rpm)
-- @return 无
-- @notes 无
function motor.run(id, round, speed)
  logger:info(string.format("[CMD] MOTOR%d: run %.2fr, speed %.2frpm", id, round, speed))
end

-- @brief 在motor表中实现stop的控制功能
-- @param id: 被控制的motor ID号
-- @return 无
-- @notes 无
function motor.stop(id)
  logger:info(string.format("[CMD] MOTOR%d STOP!!!", id))
end

-- @brief 在motor表中实现reset功能
-- @param id: 被控制的motor ID号
-- @return
-- @notes
function motor.reset(id)
  logger:info(string.format("[CMD] MOTOR%d Reset!!!", id))
end

-- @brief 在motor表中实现运行变速功能
-- @param id: 被控制的motor ID号
--  newspeed: 新的运行速度(单位:rpm)
-- @return
-- @notes
function motor.chspeed(id, newspeed)
  logger:info(string.format("[CMD] MOTOR%d Change Speed to %.2frpm", id, newspeed))
end

motor.BASEOMEGA = 100
motor.maxn = 3

return motor                              -- 返回motor控制表,供外部调用

--******************************************************************************
-- No More!
--******************************************************************************
