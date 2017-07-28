#!/usr/local/bin/lua
--******************************************************************************
-- valve.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--*******************************************************************************

valve = {}  -- ����valve��

-- @brief ��valve����ʵ�ִ򿪹���
-- @param ...: ��Ҫ�򿪵�valve��ID���б�
-- @return ��
-- @notes ��
function valve.on(...)
  local valves = ''
  for i=1, select('#', ...) do
    valves = valves .. select(i, ...) .. ' '
  end
  logger:info("   [RESULT] VALVE ON " .. valves)
end

-- @brief ��valve����ʵ�ֹرչ���
-- @param ��
-- @return ��
-- @notes ��
function valve.off()
  logger:info(string.format("   [RESULT] VALVE OFF!!!"))
end

return valve                                -- ����valve���Ʊ�,���ⲿ����

--******************************************************************************
-- No More!
--******************************************************************************
