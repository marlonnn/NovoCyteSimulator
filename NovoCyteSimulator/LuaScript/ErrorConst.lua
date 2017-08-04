#!/usr/local/bin/lua

ErrorConst = ErrorConst or {}

local TIMING_STOPERROR_TABLE      = {  
  VOLTAGE_OVER_LIMIT              = 0x0006,                  -- 电流超限
  CURRENT_OVER_LIMIT              = 0x0007,                  -- 电压超限
  FIRMWARE_CONFIGURATION_ERROR    = 0x0008,                  -- Flash未配置或配置数据校验错误
  SIP_RESET_FAILED                = 0x001C,                  -- 加样针复位失败
  SAMPLINGPUMP_RESET_FAILED       = 0x001D,                  -- 样本泵复位失败
  SHEATHPUMP_RESET_FAILED         = 0x0021                   -- 鞘液泵复位失败
}

local TIMING_HANDLEERROR_TABLE    = {
  SIPCOLLISION_WHENSAMPLING       = 0x0001,                  -- 采样时撞针
  SIPCOLLISION                    = 2                        -- 普通撞针
}

local TIMING_DIAGNOSISERROR_TABLE = {
  PRESSURESENSOR1_OVER_LIMIT      = 1,                       -- 压力超限
  PRESSURESENSOR2_OVER_LIMIT      = 2                        -- 压力恢复
}

local TIMING_OTHERERROR_TABLE     = {
  RUNNING_OUT_OF_NOVOFLOW         = 0x0002,                  -- 鞘液余量不足
  RUNNING_OUT_OF_NOVORINSE        = 0x0003,                  -- 冲洗液余量不足
  RUNNING_OUT_OF_NOVOCLEAN        = 0x0004,                  -- 清洗洗液余量不足
  WASTE_CONTAINER_IS_FULL         = 0x0005
}

ErrorConst          = {

StopErrorConst      = TIMING_STOPERROR_TABLE,                -- 系统停止工作类错误
HandleErrorConst    = TIMING_HANDLEERROR_TABLE,              -- 自动处理类错误
DiagnosisErrorConst = TIMING_DIAGNOSISERROR_TABLE            -- 自动诊断类错误

}

return ErrorConst    -- 返回ErrorConst常量表
