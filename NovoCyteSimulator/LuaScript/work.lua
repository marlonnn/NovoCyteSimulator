--#!/usr/local/bin/lua
--******************************************************************************
-- work.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

work = work or {}                         -- 创建顶层work表

require "LuaScript\\TimingConst"                     -- 导入常量表
require "LuaScript\\config"
require "LuaScript\\timing"                          -- 导入时序表
require "LuaScript\\logging"                         -- 导入log模块
require "LuaScript\\work_record"                     -- 导入状态步骤记录模块
require "LuaScript\\novoerror"                       -- 导入错误类型判断模块
require "LuaScript\\work_startup"                    -- 导入开机初始化流程控制表
require "LuaScript\\work_idle"                       -- 导入待机流程控制表
require "LuaScript\\work_measure"                    -- 导入测试流程控制表
require "LuaScript\\work_maintain"                   -- 导入维护流程控制表
require "LuaScript\\work_shutdown"                   -- 导入关机流程控制表
require "LuaScript\\work_initpriming"                -- 导入首次灌注控制表
require "LuaScript\\work_drain"                      -- 导入排空流程控制表
require "LuaScript\\work_decontamination"            -- 导入消毒流程控制表
require "LuaScript\\work_error_handle"               -- 导入错误自动处理流程控制表
require "LuaScript\\work_error_diagnosis"            -- 导入故障诊断流程控制表
require "LuaScript\\work_sleepenter"                 -- 导入进入休眠控制表
require "LuaScript\\work_sleep"                      -- 导入休眠控制表
require "LuaScript\\work_sleepexit"                  -- 导入退出休眠控制表
require "LuaScript\\work_motorgohome"                -- 导入复位流程控制表
require "LuaScript\\motor"  
require "LuaScript\\valve"  
require "LuaScript\\subwork"  
require "LuaScript\\timer"  


logger = logging:console("%level %message\r\n")
logger:setLevel(logging.DEBUG)            -- 设置调试级别
--subwork:timingversionset(timing.version)  -- 设置当前跑的流体时序版本
--tmr = subwork.GetTimer()
local work_list = {                       -- 创建时序控制转换表
  [TimingConst.WORK_STARTUP]          = work_startup,         -- 对应开机执行流程
  [TimingConst.WORK_IDLE]             = work_idle,            -- 对应待机流程
  [TimingConst.WORK_MEASURE]          = work_measure,         -- 对应测试流程
  [TimingConst.WORK_MAINTAIN]         = work_maintain,        -- 对应维护流程
  [TimingConst.WORK_SHUTDOWN]         = work_shutdown,        -- 对应关机流程
  [TimingConst.WORK_ERRORHANDLE]      = work_error_handle,    -- 对应错误处理流程
  [TimingConst.WORK_ERRORDIAGNOSIS]   = work_error_diagnosis, -- 对应故障诊断流程
  [TimingConst.WORK_INITPRIMING]      = work_initpriming,     -- 对应首次灌注流程
  [TimingConst.WORK_DRAIN]            = work_drain,           -- 对应排空流程
  [TimingConst.WORK_DECONTAMINATION]  = work_decontamination, -- 对应消毒流程
  [TimingConst.WORK_SLEEPENTER]       = work_sleepenter,      -- 对应进入休眠
  [TimingConst.WORK_SLEEP]            = work_sleep,           -- 对应休眠
  [TimingConst.WORK_SLEEPEXIT]        = work_sleepexit,       -- 对应退出休眠
  [TimingConst.WORK_MOTORGOHOME]      = work_motorgohome,     -- 对应复位流程
  [TimingConst.WORK_STOP]             = work_stop,            -- 对应无法工作流程
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
  --subwork:Print(motor.Motors[1]:reset())
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
  --subwork:Print("Vales set end")

  -- 样本针电机控制
  if item.smotor then                                   -- 判断时序节点中样本针电机参数是否为nil
    info = "[SMOTOR]: "
    xmotor = item.smotor
    --subwork:Print("smotor start")
	--subwork:Print(xmotor)
	if type(xmotor) == "table" then                     -- 如果smotor引用的是table类型
      if xmotor.op == TimingConst.MOTOR_RUN then        -- 如果执行的是run操作
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("SMOTOR missing parameter")
		--subwork:Print("SMOTOR missing parameter")
        end
        info = info .. string.format("<RUN> %.2fr, %.2frpm", xmotor.rounds, omega) -- 打印相应参数信息,有助于调试
        motor:run(TimingConst.SMOTOR, xmotor.rounds, omega)    -- 执行run动作
		--subwork:Print(string.format("[SMOTOR]: <RUN> %.2fr, %.2frpm", xmotor.rounds, omega))
      elseif xmotor.op == TimingConst.MOTOR_CHSPEED then-- 如果执行的是变速操作
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("SMOTOR missing parameter")
		--subwork:Print("SMOTOR missing parameter")
        end
        info = info .. string.format("<CHSPEED> %.2frpm", omega)
        motor:chspeed(TimingConst.SMOTOR, omega)        -- 执行变速动作
      elseif xmotor.op == TimingConst.MOTOR_RESET then  -- 如果执行的是复位操作
        info = info .. "<RESET>"
        motor:reset(TimingConst.SMOTOR)                 -- 执行复位动作
      elseif xmotor.op == TimingConst.MOTOR_STOP then   -- 如果执行的是停止操作
        info = info .. "<STOP>"
        motor:stop(TimingConst.SMOTOR)                  -- 执行停止动作
		--subwork:Print("----work SMOTOR motor stop----")
      end
    elseif type(xmotor) == "function" then              -- 如果smotor引用的是function类型
      info = info .. "<CALL>"
      xmotor()                                          -- 调用自定义函数
    else                                                -- 如果smotor引用的是其他类型
      info = info .. "<NIL>"
    end
    logger:info(info)
  end
  --subwork:Print("smotor end ")

  -- 注射器电机控制
  if item.imotor then                                   -- 判断时序节点中注射器电机参数是否为nil
    info = "[IMOTOR]: "
    xmotor = item.imotor
    --subwork:Print("imotor start")
	--subwork:Print(xmotor)
	if type(xmotor) == "table" then                     -- 如果imotor引用的是table类型
      --subwork:Print(xmotor.op)
	  if xmotor.op == TimingConst.MOTOR_RUN then        -- 如果执行的是run操作
        if xmotor.omega then
        omega = xmotor.omega
	    --subwork:Print(omega)
        else
        error("IMOTOR missing parameter")
        end
        info = info .. string.format("<RUN> %.2fr, %.2frpm", xmotor.rounds, omega)
        motor:run(TimingConst.IMOTOR, xmotor.rounds, omega)    -- 执行run动作
		--subwork:Print(string.format("[IMOTOR]: <RUN> %.2fr, %.2frpm", xmotor.rounds, omega))
      elseif xmotor.op == TimingConst.MOTOR_CHSPEED then-- 如果执行的是变速操作
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("IMOTOR missing parameter")
        end
        info = info .. string.format("<CHSPEED> %.2frpm", omega)
        motor:chspeed(TimingConst.IMOTOR, omega)        -- 执行变速动作
		--subwork:Print(string.format("[IMOTOR]: <CHSPEED> %.2frpm", omega))
      elseif xmotor.op == TimingConst.MOTOR_RESET then  -- 如果执行的是复位操作
        info = info .. "<RESET>"
        motor:reset(TimingConst.IMOTOR)                 -- 执行复位动作
      elseif xmotor.op == TimingConst.MOTOR_STOP then   -- 如果执行的是停止操作
        info = info .. "<STOP>"
        motor:stop(TimingConst.IMOTOR)                  -- 执行停止动作
      end
    elseif type(xmotor) == "function" then              -- 如果smotor引用的是function类型
      info = info .. "<CALL>"
      xmotor()                                          -- 调用自定义函数
    else                                                -- 如果smotor引用的是其他类型
      info = info .. "<NIL>"
    end
    logger:info(info)
  end
  --subwork:Print("imotor end")
  -- 蠕动泵电机控制
  if item.pmotor then                                   -- 判断时序节点中蠕动泵电机参数是否为nil
    info = "[PMOTOR]: "
    xmotor = item.pmotor
	--subwork:Print("pmotor start")
	--subwork:Print(xmotor)
    if type(xmotor) == "table" then                     -- 如果pmotor引用的是table类型
      --subwork:Print(xmotor.op)
	  if xmotor.op == TimingConst.MOTOR_RUN then        -- 如果执行的是run操作
        if xmotor.omega then
        omega = xmotor.omega
		--subwork:Print(omega)
        else
        error("PMOTOR missing parameter")
		--subwork:Print("PMOTOR missing parameter")
        end
        info = info .. string.format("<RUN> %.2fr, %.2frpm", xmotor.rounds, omega)
		motor:run(TimingConst.PMOTOR, xmotor.rounds, omega)    -- 执行run动作
		--subwork:Print(string.format("[PMOTOR]: <RUN> %.2fr, %.2frpm", xmotor.rounds, omega))
      elseif xmotor.op == TimingConst.MOTOR_CHSPEED then-- 如果执行的是变速操作
        if xmotor.omega then
        omega = xmotor.omega
        else
        error("PMOTOR missing parameter")
		--subwork:Print("PMOTOR missing parameter")
        end
        info = info .. string.format("<CHSPEED> %.2frpm", omega)
        motor:chspeed(TimingConst.PMOTOR, omega)        -- 执行变速动作
		--subwork:Print(string.format("[PMOTOR]: <CHSPEED> %.2frpm", omega))
      elseif xmotor.op == TimingConst.MOTOR_RESET then  -- 如果执行的是复位操作
        info = info .. "<RESET>"
        motor:reset(TimingConst.PMOTOR)                 -- 执行复位动作
      elseif xmotor.op == TimingConst.MOTOR_STOP then   -- 如果执行的是停止操作
        info = info .. "<STOP>"
        motor:stop(TimingConst.PMOTOR)                  -- 执行停止动作
		--subwork:Print("----work PMOTOR motor stop----")
      end
    elseif type(xmotor) == "function" then              -- 如果smotor引用的是function类型
      info = info .. "<CALL>"
      xmotor()                                          -- 调用自定义函数
    else                                                -- 如果smotor引用的是其他类型
      info = info .. "<NIL>"
    end
    logger:info(info)
  end
  --subwork:Print("pmotor end")
end

function work:subTimingInit()                           -- sub时序流程控制初始化
  logger:info("subTimingInit:", self.grpIdx)
  self.subIdx = 1
  if self.subBeginHook then self:subBeginHook() end     -- 是否需要初始化回调
end

function work:subTimingRun()                            -- sub时序流程执行
  local sub = self.sub                                  -- 获取当前sub时序流程
  local idx = 1                                         -- sub时序节点计数器
  local ret
  if sub.idx then
  logger:info("subTimingRun: ", sub.sub.name, sub.idx.name)
  else
  logger:info("subTimingRun: ", sub.sub.name)
  end
  repeat
    local item = self:itemGet()                         -- 从sub时序流程中获得一个节点
    --subwork:Print(item)
	if not item then
      self.quittype = TimingConst.WORK_QUIT_Normal
      break
    end                          -- 如果获得的节点为nil,也就是说到了时序结尾,则退出
    if item.beginhook then
      item.beginhook(self, item)
    end
    item.ticks = math.ceil(item.ticks)
    if sub.idx then
    logger:info(string.format("-> idx:%3d[0x%02x], ticks:%4d", idx, sub.idx[idx], item.ticks))
    else
    logger:info(string.format("-> idx:%3d[0x%02x], ticks:%4d", idx, idx, item.ticks))
    end
	--subwork:Print("item run")
    self:itemRun(item)                                  -- 执行获得的节点
    --subwork:Print("item run end")
	subwork:alarmstart(item.ticks)
	--subwork:Print("alarm start")
    while true do
      ret = subwork:alarmwait(item.awaketicks or 100)
      if ret == TimingConst.WORK_QUIT_Abort then 
        --subwork:Print("abort")
		self.quittype = ret
        return self.quittype                            -- 若出现异常，结束当前流程
      end
      if ret ~= TimingConst.WORK_QUIT_Wait then 
	    --subwork:Print("not equal work quit wait")
		break 
		end
      if item.awakehook then
        ret = item.awakehook(self)
        if ret ~= TimingConst.WORK_QUIT_Wait then break end
      end
    end
    self.quittype = ret
    if item.endhook then
	  --subwork:Print("--end hook--")
      item.endhook(self, item)
    end
    idx = idx + 1                                       -- 下一个节点
  	--subwork:Print(ret)
  until ret ~= TimingConst.WORK_QUIT_Next
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
  if self.grpBeginHook then self:grpBeginHook() end     -- 是否需要初始化回调
end

function work:grpTimingRun()                            -- grp时序流程执行
  local grp = self.grp
  --subwork:Print(grp)
  logger:info("grpTimingRun: ", grp.name)
  while self.grpIdx <= #grp do                          -- 循环grp里每一个sub时序
	self.sub = grp[self.grpIdx]                         -- 获得当前的sub时序

    self:subTimingProcess()                             -- 执行sub时序流程
    if self.quittype ~= TimingConst.WORK_QUIT_Normal then break end

    if self.sub.ishand then break end

    self.grpIdx = self.grpIdx + 1                       -- 下一个sub
    self.grpCnt = self.grpCnt + 1
  end
end

function work:grpTimingQuit()                           -- grp时序流程退出
  if self.grpEndHook then self:grpEndHook() end         -- 是否需要退出回调
  --subwork:Print("work: grpTimingQuit")
  logger:info("grpTimingQuit")
  --logger:warn("quittype: ", self.quittype)

  if self.quittype ~= TimingConst.WORK_QUIT_Normal then
    self:itemRun(timing.allstop[1])
  end
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

  self.istimecalc = true
  while grpIdx <= #grp do
    local sub = grp[grpIdx]
    subIdx = 1
    while true do
      index = subIdx
      subIdx = subIdx + 1
      if sub.idx then index = sub.idx[index] end        -- 获取节点索引
      item = sub.sub[index]                             -- 获取时序表中的节点
      if item then
        if item.beginhook then
          item.beginhook(self, item)
        end
        ticks = ticks + item.ticks
      else break end
    end
    if sub.ishand then break end
    grpIdx = grpIdx + 1
  end
  self.istimecalc = false

  return ticks
end

function work.Step(step, set)
  --return (set<<16)|step     --INT16U,多步交互流程,高字节0表示执行完成,1表示执行中;低字节表示执行的步骤
    --return math.ldexp(set, 16) + set     --INT16U,多步交互流程,高字节0表示执行完成,1表示执行中;低字节表示执行的步骤
	return set * 2^16 + set 
end

--function work:setstate()
	--work.stateTo = subwork.ToLua.Stateto
	--logger:info("state to: ------------------->")
	--logger:info(work.stateTo)
	--work:select()
	--return true
--end

--return work

--work.stateTo, work.subref1, work.subref2, work.isrecordnil = work_record:stateget()
--work.stateTo, work.subref1, work.subref2 = subwork.ctrlto()
work.stateTo = TimingConst.WORK_IDLE
while true do
	work:select()
end

-- work.stateTo = TimingConst.WORK_STARTUP                 -- 默认设置为开机初始化状态
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
  elseif input==5 then
    work.stateTo = TimingConst.WORK_ERRORHANDLE
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
