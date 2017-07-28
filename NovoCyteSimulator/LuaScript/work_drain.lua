#!/usr/local/bin/lua
--******************************************************************************
-- work_drain.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work_drain = work_drain or {}

local function init (t)
  logger:info("work drain: init")
end

local function run (t)
  logger:info("work drain: run")
end

local function quit (t)
  logger:info("work drain: quit")
end

function work_drain.process (t)
  init(t)
  run(t)
  quit(t)
end

return work_drain

--******************************************************************************
-- No More!
--******************************************************************************
