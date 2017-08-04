#!/usr/local/bin/lua

--压力监测

pressure_monitor = pressure_monitor or {}

local maxpressure    = 200   --压力上限值
local pressurepoints = 5     --报警点数
local frequency      = 200   --采集频率

function pressure_monitor.isoverlimit()
  local isoverlimit = false
  local P1 = 0                                          --压力传感器1压力值
  local P2 = 0                                          --压力传感器2压力值
  local p1overlimitpoint = 0                            --压力传感器1压力超限点数
  local p2overlimitpoint = 0                            --压力传感器2压力超限点数
  local errortype = nil
  local PRESSURE_SENOSR = TimingConst.PRESSURE_SENOSR
  local SENOSR1 = TimingConst.PRESSURE_SENOSR1
  local SENOSR2 = TimingConst.PRESSURE_SENOSR2
  
  while true do
    P1 = sensor.get(PRESSURE_SENOSR, SENOSR1)
    P2 = sensor.get(PRESSURE_SENOSR, SENOSR2)
    if     P1 >= maxpressure then
      p1overlimitpoint  = p1overlimitpoint + 1
    elseif P1 <  maxpressure then
      p1overlimitpoint  = 0
    end
    
    if     P2 >= maxpressure then
      p2overlimitpoint  = p2overlimitpoint + 1
    elseif P2 <  maxpressure then
      p2overlimitpoint  = 0
    end

    if     p1overlimitpoint <  pressurepoints and p2overlimitpoint < pressurepoints then
      isoverlimit = false
    elseif p1overlimitpoint >= pressurepoints then
      isoverlimit = true
      errortype   = "PRESSURESENSOR1_OVER_LIMIT"
    elseif p2overlimitpoint >= pressurepoints then
      isoverlimit = true
      errortype   = "PRESSURESENSOR2_OVER_LIMIT"
    end
    
    status, errortype = coroutine.yield(errortype)
  end
end

pressure_monitor.reporterror = coroutine.create(pressure.isoverlimit)

--[[
function pressure.isoverlimit(id)
  local i    = 1
  local j    = 1
  local mean = 0
  local cnt  = 0
  local sum  = 0
  local P    = 0
  local isoverlimit = false
  
  P = pressure.read(id)
  if P >= 200 then
    sum = P
    cnt = cnt + 1
  end

  if cnt < 5 then
    sum  = sum + P
    mean = sum / i
    i    = i + 1
  else
    isoverlimit = true
  end 
  return mean
end

function pressure.judge(P1max, P2max) 
  local P1result   = 0
  local P2result   = 0
  local error_code = nil
  P1result = pressure.average(1)
  P2result = pressure.average(2)
  if     P1result >= P1max and P2result >=  P2max then
    error_code = 00
  elseif P1result >= P1max and P2result <   P2max then
    error_code = 01
  elseif P1result <  P1max and P2result >=  P2max then
    error_code = 10
  elseif P1result <  P1max and P2result <   P2max then
    error_code = 11
  end
  
  return error_code
end

local PRESSURE_LIMIT_TABLE = {
  [P1max] = 20,
  [P2max] = 200
}

return pressure
--]]

return pressure_monitor