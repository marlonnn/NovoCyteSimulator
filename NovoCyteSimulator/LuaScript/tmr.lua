#!/usr/local/bin/lua
--******************************************************************************
-- tmr.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

tmr = tmr or {}

function tmr.tickspersec()
  local ticks_per_sec = 200
  return ticks_per_sec
end

function tmr.tickspermin()
  local ticks_per_min = 12000
  return ticks_per_min
end

function tmr.systicks()
  return os.clock() * 1000
end

function tmr.delayms(msec)
  local tend = os.clock() * 1000 + msec
  
  while tend < os.clock()*1000 do end
end

function tmr.delays(sec)
  local tend = os.clock() * 1000 + sec
  
  while tend < os.clock() do end
end

return tmr
