--#!/usr/local/bin/lua
--******************************************************************************
-- work.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work = work or {}         -- 创建顶层work表

require "LuaScript\\TimingConst"   -- 导入常量表
require "LuaScript\\config"
require "LuaScript\\timing"        -- 导入时序表
require "LuaScript\\logging"       -- 导入log模块

require "LuaScript\\work_startup"  -- 导入开机初始化流程控制表
require "LuaScript\\work_idle"     -- 导入待机流程控制表
require "LuaScript\\work_measure"
require "LuaScript\\work_maintain"
require "LuaScript\\work_error"
require "LuaScript\\work_initpriming"
require "LuaScript\\work_drain"
require "LuaScript\\work_decontamination"
require "LuaScript\\motor"         -- 导入motor控制模块
require "LuaScript\\valve"         -- 导入valve控制模块
require "LuaScript\\tmr"
require "LuaScript\\subwork"

logger = logging:console("%level %message\r\n")
logger:setLevel(logging.DEBUG)

local work_list = {     -- 创建时序控制转换表
  [TimingConst.WORK_STARTUP]          = work_startup,   -- 对应开机执行流程
  [TimingConst.WORK_IDLE]             = work_idle,      -- 对应待机流程
  [TimingConst.WORK_MEASURE]          = work_measure,
  [TimingConst.WORK_MAINTAIN]         = work_maintain,
  [TimingConst.WORK_ERROR]            = work_error,
  [TimingConst.WORK_INITPRIMING]      = work_initpriming,
  [TimingConst.WORK_DRAIN]            = work_drain,
  [TimingConst.WORK_DECONTAMINATION]  = work_decontamination,
  __default                           = work_idle
}
setmetatable(work_list, {__index = function (t, k)
  return rawget(t, "__default")
end})

function work:select()            -- 选择下一执行流程
  self.stateTo = work_list[self.stateTo]:process()
  return self.stateTo
end

function work:init()
  self.grpIdx = 1
  self.subIdx = 1
  self.grpCnt = 1
  self.subCnt = 1
  self.grp = timing[self.timingName]            -- 根据时序名获得grp时序引用
  self.sub = nil
  local tstart = tmr.systicks()
  local ttotal = self:timecalc()
  subwork:stateset(self.stateTo, 0, 0)
  subwork:timeset(tstart, ttotal)
end

function work:itemGet()           -- 从时序列表获取时序节点
  local item
  local shadowCall = self.shadowCall
  self.subCnt = self.subCnt + 1   -- 时序节点计数器
  if shadowCall then              -- 是否有影子节点调用
    self.shadowCall = nil
    item = shadowCall(self)       -- 通过修改创建影子节点
    return item                   -- 返回一个影子节点
  end

  local sub = self.sub            -- 从时序获取节点
  local index = self.subIdx
  self.subIdx = self.subIdx + 1   -- 时序节点索引器
  if sub.idx then index = sub.idx[index] end            -- 获取节点索引

  item = sub.sub[index]           -- 获取时序表中的节点

  return item
end

function work:itemRun(item)       -- 运行时序节点
  local ret
  local xmotor
  local omega
  local info

  -- 阀控制
  info = "[VALVES]: "
  if item.valve then              -- 判断当前节点valve值是否为nil
    info = info .. "<ON> " .. table.concat(item.valve, ' ')
    ret = valve.on(unpack(item.valve))            -- 如果valve值为非nil,打开相应的阀
  else
    info = info .. "<OFF>"
    ret = valve.off()                                   -- 如果valve值为nil,则关闭所有的valve
  end
  logger:info(info)

  -- 样本针电机控制
  if item.smotor then                                   -- 判断时序节点中样本针电机参数是否为nil
    info = "[SMOTOR]: "
    xmotor = item.smotor
    if type(xmotor) == "table" then                     -- 如果smotor引用的是table类型
      if xmotor.op == TimingConst.MOTOR_RUN then        -- 如果执行的是run操作
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("SMOTOR missing parameter")
        end
        info = info .. string.format("<RUN> %.2fr, %.2frpm", xmotor.rounds, omega) -- 打印相应参数信息,有助于调试
        motor.run(TimingConst.SMOTOR, xmotor.rounds, omega)    -- 执行run动作
      elseif xmotor.op == TimingConst.MOTOR_CHSPEED then-- 如果执行的是变速操作
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("SMOTOR missing parameter")
        end
        info = info .. string.format("<CHSPEED> %.2frpm", omega)
        motor.chspeed(TimingConst.SMOTOR, omega)        -- 执行变速动作
      elseif xmotor.op == TimingConst.MOTOR_RESET then  -- 如果执行的是复位操作
        info = info .. "<RESET>"
        motor.reset(TimingConst.SMOTOR)                 -- 执行复位动作
      elseif xmotor.op == TimingConst.MOTOR_STOP then   -- 如果执行的是停止操作
        info = info .. "<STOP>"
        motor.stop(TimingConst.SMOTOR)                  -- 执行停止动作
      end
    elseif type(xmotor) == "function" then              -- 如果smotor引用的是function类型
      info = info .. "<CALL>"
      xmotor()                                          -- 调用自定义函数
    else                                                -- 如果smotor引用的是其他类型
      info = info .. "<NIL>"
    end
    logger:info(info)
  end

  -- 注射器电机控制
  if item.imotor then                                   -- 判断时序节点中注射器电机参数是否为nil
    info = "[IMOTOR]: "
    xmotor = item.imotor
    if type(xmotor) == "table" then                     -- 如果imotor引用的是table类型
      if xmotor.op == TimingConst.MOTOR_RUN then        -- 如果执行的是run操作
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("IMOTOR missing parameter")
        end
        info = info .. string.format("<RUN> %.2fr, %.2frpm", xmotor.rounds, omega)
        motor.run(TimingConst.IMOTOR, xmotor.rounds, omega)    -- 执行run动作
      elseif xmotor.op == TimingConst.MOTOR_CHSPEED then-- 如果执行的是变速操作
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("IMOTOR missing parameter")
        end
        info = info .. string.format("<CHSPEED> %.2frpm", omega)
        motor.chspeed(TimingConst.IMOTOR, omega)        -- 执行变速动作
      elseif xmotor.op == TimingConst.MOTOR_RESET then  -- 如果执行的是复位操作
        info = info .. "<RESET>"
        motor.reset(TimingConst.IMOTOR)                 -- 执行复位动作
      elseif xmotor.op == TimingConst.MOTOR_STOP then   -- 如果执行的是停止操作
        info = info .. "<STOP>"
        motor.stop(TimingConst.IMOTOR)                  -- 执行停止动作
      end
    elseif type(xmotor) == "function" then              -- 如果smotor引用的是function类型
      info = info .. "<CALL>"
      xmotor()                                          -- 调用自定义函数
    else                                                -- 如果smotor引用的是其他类型
      info = info .. "<NIL>"
    end
    logger:info(info)
  end

  -- 蠕动泵电机控制
  if item.pmotor then                                   -- 判断时序节点中蠕动泵电机参数是否为nil
    info = "[PMOTOR]: "
    xmotor = item.pmotor
    if type(xmotor) == "table" then                     -- 如果pmotor引用的是table类型
      if xmotor.op == TimingConst.MOTOR_RUN then        -- 如果执行的是run操作
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("PMOTOR missing parameter")
        end
        info = info .. string.format("<RUN> %.2fr, %.2frpm", xmotor.rounds, omega)
        motor.run(TimingConst.PMOTOR, xmotor.rounds, omega)    -- 执行run动作
      elseif xmotor.op == TimingConst.MOTOR_CHSPEED then-- 如果执行的是变速操作
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("PMOTOR missing parameter")
        end
        info = info .. string.format("<CHSPEED> %.2frpm", omega)
        motor.chspeed(TimingConst.PMOTOR, omega)        -- 执行变速动作
      elseif xmotor.op == TimingConst.MOTOR_RESET then  -- 如果执行的是复位操作
        info = info .. "<RESET>"
        motor.reset(TimingConst.PMOTOR)                 -- 执行复位动作
      elseif xmotor.op == TimingConst.MOTOR_STOP then   -- 如果执行的是停止操作
        info = info .. "<STOP>"
        motor.stop(TimingConst.PMOTOR)                  -- 执行停止动作
      end
    elseif type(xmotor) == "function" then              -- 如果smotor引用的是function类型
      info = info .. "<CALL>"
      xmotor()                                          -- 调用自定义函数
    else                                                -- 如果smotor引用的是其他类型
      info = info .. "<NIL>"
    end
    logger:info(info)
  end
end

function work:subTimingInit()                           -- sub时序流程控制初始化
  logger:info("subTimingInit:", self.grpIdx)
  self.subIdx = 1
  if self.subBeginHook then self:subBeginHook() end     -- 是否需要初始化回调
end

function work:subTimingRun()                            -- sub时序流程执行
  local sub = self.sub                                  -- 获取当前sub时序流程
  local idx = 1                                         -- sub时序节点计数器
  if sub.idx then
  logger:info("subTimingRun: ", sub.sub.name, sub.idx.name)
  else
  logger:info("subTimingRun: ", sub.sub.name)
  end
  while true do
    local item = self:itemGet()                         -- 从sub时序流程中获得一个节点
    if not item then break end                          -- 如果获得的节点为nil,也就是说到了时序结尾,则退出
    if sub.idx then
    logger:info(string.format("-> idx:%3d[0x%02x], ticks:%4d", idx, sub.idx[idx], item.ticks))
    else
    logger:info(string.format("-> idx:%3d[0x%02x], ticks:%4d", idx, idx, item.ticks))
    end
    if item.beginhook then
      item.beginhook(self, item)
    end
    self:itemRun(item)                                  -- 执行获得的节点
    subwork:alarmstart(item.ticks)
    subwork:alarmwait(0)
    if item.endhook then
      item.endhook(self, item)
    end
    idx = idx + 1                                       -- 下一个节点
  end
end

function work:subTimingQuit()                           -- sub时序流程退出
  if self.subEndHook then self:subEndHook() end         -- 是否需要退出回调
  logger:info("subTimingQuit:", self.grpIdx)
end

function work:subTimingProcess()                        -- 整个sub时序流程的执行过程
  self:subTimingInit()                                  -- 初始化
  self:subTimingRun()                                   -- 运行
  self:subTimingQuit()                                  -- 结束
end

function work:grpTimingInit()                           -- grp时序流程控制初始化
  logger:info("grpTimingInit")
  --self.grp = timing[self.timingName]                    -- 根据时序名获得grp时序引用
  --self.grpIdx = 1
  --self.grpCnt = 1
  if self.grpBeginHook then self:grpBeginHook() end     -- 是否需要初始化回调
end

function work:grpTimingRun()                            -- grp时序流程执行
  local grp = self.grp
  logger:info("grpTimingRun: ", grp.name)
  while self.grpIdx <= #grp do                          -- 循环grp里每一个sub时序
    self.sub = grp[self.grpIdx]                         -- 获得当前的sub时序

    self:subTimingProcess()                             -- 执行sub时序流程

    self.grpIdx = self.grpIdx + 1                       -- 下一个sub
    self.grpCnt = self.grpCnt + 1
  end
end

function work:grpTimingQuit()                           -- grp时序流程退出
  if self.grpEndHook then self:grpEndHook() end         -- 是否需要退出回调
  logger:info("grpTimingQuit")
end

function work:grpTimingProcess()                        -- 整个grp时序流程的执行过程
  self:grpTimingInit()                                  -- 初始化
  self:grpTimingRun()                                   -- 运行
  self:grpTimingQuit()                                  -- 结束
end

function work:timecalc()
  local grp = self.grp
  local grpIdx = self.grpIdx or 1
  local index, subIdx
  local item
  local ticks = 0
  
  while grpIdx <= #grp do
    local sub = grp[grpIdx]
    subIdx = 1
    while true do
      index = subIdx
      subIdx = subIdx + 1
      if sub.idx then index = sub.idx[index] end        -- 获取节点索引
      item = sub.sub[index]                             -- 获取时序表中的节点
      -- todo add shadow ticks
      if item then ticks = ticks + item.ticks
      else break end
    end
    if sub.ishand then break end
    grpIdx = grpIdx + 1
  end
  return ticks
end

function work:setstate()
	work.stateTo = subwork.ToLua.Stateto
	logger:info(work.stateTo)
	work:select()
	return true
end

return work

--work.stateTo = TimingConst.WORK_STARTUP                 -- 默认设置为开机初始化状态
--work.stateTo = TimingConst.WORK_MAINTAIN
--work.stateTo = TimingConst.WORK_MEASURE;
--work.maintainTo = TimingConst.MAINTAIN_DEBUBBLE
--work.stateTo = TimingConst.WORK_IDLE
--logger:info(work.stateTo)
--work:select()
--[[
local work_prompt = "  [1]: Startup\r\n  [2]: Idle\r\n  [3]: Measure\r\n  [4]: Maintain\r\n  [5]: Error\r\n  [6]: Sleep\r\n  [7]: Shutdown\r\n  [8]: InitPriming\r\n  [9]: Drain\r\n  [0]: Exit\r\n"
local maintain_prompt = "  [1]: Debubble\r\n  [2]: Cleaning\r\n  [3]: Rinse\r\n  [4]: ExtRinse\r\n  [5]: Priming\r\n  [6]: Unclog\r\n  [7]: Backflush\r\n  [0]: Exit\r\n"

while true do
  io.write(work_prompt .. "Please Select: ")
  local input
  repeat input = io.read("*number") until input

  print(input)
  if input==1 then
    work.stateTo = TimingConst.WORK_STARTUP
  elseif input==2 then
    work.stateTo = TimingConst.WORK_IDLE
  elseif input==3 then
    work.stateTo = TimingConst.WORK_MEASURE
  elseif input==4 then
    work.stateTo = TimingConst.WORK_MAINTAIN
    while true do
      io.write(maintain_prompt .. "Please Select: ")
      local sel = io.read("*number")
      print(sel)
      if sel==1 then
        work.maintainTo = TimingConst.MAINTAIN_DEBUBBLE
        break
      elseif sel==2 then
        work.maintainTo = TimingConst.MAINTAIN_CLEANING
        break
      elseif sel==3 then
        work.maintainTo = TimingConst.MAINTAIN_RINSE
        break
      elseif sel==4 then
        work.maintainTo = TimingConst.MAINTAIN_EXTRINSE
        break
      elseif sel==5 then
        work.maintainTo = TimingConst.MAINTAIN_PRIMING
        break
      elseif sel==6 then
        work.maintainTo = TimingConst.MAINTAIN_UNCLOG
        break
      elseif sel==7 then
        work.maintainTo = TimingConst.MAINTAIN_BACKFLUSH
        break
      elseif sel==0 then
        input = nil
        break
      else
        logger:info("\r\n\27[1;31mERROR INPUT.\27[m")
        input = nil
      end
    end
  elseif input==5 then
    work.stateTo = TimingConst.WORK_ERROR
  elseif input==6 then
    work.stateTo = TimingConst.WORK_SLEEP
  elseif input==7 then
    work.stateTo = TimingConst.WORK_SHUTDOWN
  elseif input==8 then
    work.stateTo = TimingConst.WORK_INITPRIMING
  elseif input==9 then
    work.stateTo = TimingConst.WORK_DRAIN
  elseif input==0 then
    break
  else
    logger:info("\r\n\27[1;31mERROR INPUT.\27[m")
    input = nil
  end
  if input then
    logger:info(work.stateTo)
    work:select()
  end
end
--]]

--******************************************************************************
-- No More!
--******************************************************************************
