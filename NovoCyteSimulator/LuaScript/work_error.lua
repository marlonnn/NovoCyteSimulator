#!/usr/local/bin/lua
--******************************************************************************
-- work_error.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work_error = work_error or {}

local function init (t)
  logger:info("work error: init")
end

local function run (t)
  logger:info("work error: run")
end

local function quit (t)
  logger:info("work error: quit")
end

function work_error.process (t)
  init(t)
  run(t)
  quit(t)
end

return work_error

--******************************************************************************
-- No More!
--******************************************************************************
