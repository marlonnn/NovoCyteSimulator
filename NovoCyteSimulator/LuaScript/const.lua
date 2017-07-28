#!/usr/local/bin/lua
--******************************************************************************
-- const.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

const = const or {}

function const.Const( const_table )
  local mt = {
    __index = function (t, k)
      return const_table[k]
    end,
    __newindex = function (t, k, v)
      logger:info("*can't update " .. tostring(const_table) .."[" .. tostring(k) .."] = " .. tostring(v))
    end
  }

  return mt
end

function const.newConst( const_table )  --生成常量表功能
  local t = {}
  setmetatable(t, const.Const(const_table))
  return t
end

return const
