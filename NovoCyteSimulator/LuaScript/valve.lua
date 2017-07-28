#!/usr/local/bin/lua
--******************************************************************************
-- valve.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--*******************************************************************************

valve = {}  -- 创建valve表

-- @brief 在valve表中实现打开功能
-- @param ...: 需要打开的valve的ID号列表
-- @return 无
-- @notes 无
function valve.on(...)
  local valves = ''
  for i=1, select('#', ...) do
    valves = valves .. select(i, ...) .. ' '
  end
  logger:info("   [RESULT] VALVE ON " .. valves)
end

-- @brief 在valve表中实现关闭功能
-- @param 无
-- @return 无
-- @notes 无
function valve.off()
  logger:info(string.format("   [RESULT] VALVE OFF!!!"))
end

return valve                                -- 返回valve控制表,供外部调用

--******************************************************************************
-- No More!
--******************************************************************************
