#!/usr/local/bin/lua
--******************************************************************************
-- TimingConst.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

require "LuaScript\\const"

TimingConst = TimingConst or {}

local TIMING_CONST_TABLE = {
  SMOTOR                        = 0,    -- SMotor(样本针电机) ID号
  IMOTOR                        = 1,    -- IMotor(注射器) ID号
  PMOTOR                        = 2,    -- PMotor(FMI泵) ID号

  SAMPLE_MIN_SPEED              = 1,    -- 1uL/min
  SAMPLE_MAX_SPEED              = 120,  -- 120uL/min

  INSTRUMENT_IS_RUO             = 0,    -- RUO机型
  INSTRUMENT_IS_IVD             = 1,    -- IVD机型

  TEST_IS_ABS                   = 0,    -- 绝对计数测试模式
  TEST_IS_NOABS                 = 1,    -- PID测试模式

  MOTOR_STOP                    = 0,    -- 控制电机停止
  MOTOR_RUN                     = 1,    -- 控制电机运行
  MOTOR_RESET                   = 2,    -- 控制电机复位
  MOTOR_CHSPEED                 = 3,    -- 控制电机变速
  MOTOR_KEEP                    = 4,    -- 无操作

  SMOTOR_ACC                    = 4800, -- SMotor的加速度(单位:rpm/s)
  IMOTOR_ACC                    = 4800, -- IMotor的加速度(单位:rpm/s)
  PMOTOR_ACC                    = 4800, -- PMotor的加速度(单位:rpm/s)

  WORK_STARTUP                  = 1,    -- 表示时序初始化状态
  WORK_IDLE                     = 2,    -- 表示待机状态
  WORK_MEASURE                  = 3,    -- 表示测试状态
  WORK_MAINTAIN                 = 4,    -- 表示维护状态
  WORK_ERRORHANDLE              = 6,    -- 表示错误处理状态
  WORK_SLEEP                    = 8,    -- 表示休眠状态
  WORK_SHUTDOWN                 = 9,    -- 表示关机状态
  WORK_INITPRIMING              = 10,   -- 表示首次灌注状态
  WORK_DRAIN                    = 11,   -- 表示排空状态
  WORK_SLEEPENTER               = 12,   -- 表示进入休眠状态
  WORK_SLEEPEXIT                = 13,   -- 表示退出休眠状态
  WORK_DECONTAMINATION          = 14,   -- 表示消毒状态
  WORK_ERRORDIAGNOSIS           = 15,   -- 表示故障诊断状态
  WORK_MOTORGOHOME              = 16,   -- 表示复位状态
  WORK_STOP                     = 17,   -- 表示完全终止不能工作状态

  MAINTAIN_STOP                 = 0,    -- 表示
  MAINTAIN_DEBUBBLE             = 1,    -- 表示debubble维护状态
  MAINTAIN_CLEANING             = 2,    -- 表示cleaning维护状态
  MAINTAIN_RINSE                = 3,    -- 表示rinse维护状态
  MAINTAIN_EXTRINSE             = 4,    -- 表示extrinse维护状态
  MAINTAIN_PRIMING              = 5,    -- 表示priming维护状态
  MAINTAIN_UNCLOG               = 6,    -- 表示unclog维护状态
  MAINTAIN_BACKFLUSH            = 7,    -- 表示backflush维护状态

  WORK_QUIT_Wait                = 0,    -- 等待时序节点
  WORK_QUIT_Next                = 1,    -- 下一个时序节点
  WORK_QUIT_Normal              = 2,    -- 正常退出
  WORK_QUIT_Abort               = 3,    -- 异常中断退出
  
  ERROR_RESUME_SIPFIRING        = 1,    -- 撞针错误恢复
  ERROR_RESUME_PRESSURE         = 2,    -- 压力恢复
  ERROR_RESUME_PRESSUREEXT      = 3,    -- 压力超限恢复
  ERROR_RESUME_SIPABNORMAL      = 4,    -- 样本针异常恢复

  MEASURE_None                  = 0,
  MEASURE_Boosting              = 1,
  MEASURE_Testing               = 2,
  MEASURE_Washing               = 3,
  MEASURE_Resetting             = 4,

  BOOSTING_Step1                = 0,
  BOOSTING_Step2                = 1,
  
  WORK_DONE                     = 0,
  WORK_DOING                    = 1,

  CELL_STOPWAY_Abnormal         = 0,
  CELL_STOPWAY_SoftCmd          = 1,
  CELL_STOPWAY_OverTime         = 2,
  CELL_STOPWAY_OverNumber       = 3,
  CELL_STOPWAY_OverSize         = 4,

  TESTING_None                  = 0,
  TESTING_Step1                 = 1,
  TESTING_Step2                 = 2,

  PID_Stop                      = 0,    -- 停止PID调节
  PID_Start                     = 1,    -- 启动PID调节
  PTC_Start                     = 2,    -- 启动PID参数计算
  PTC_Stop                      = 3,    -- 停止PID参数计算
  
  CURRENT_VOLTAGE_SENOSR        = 0,    --电流电压检测AD
  FLUIDICS_STATION_SENOSR       = 1,    --储液台检测AD
  PRESSURE_SENOSR               = 2,    --压力检测AD
  
  PRESSURE_SENOSR1              = 0,    --压力传感器1
  PRESSURE_SENOSR2              = 1,
  PRESSURE_SENOSR3              = 2,
  PRESSURE_SENOSR4              = 3,

  TURN_OFF                      = 0,  
  TURN_ON                       = 1
}

setmetatable(TimingConst, const.Const(TIMING_CONST_TABLE))
return TimingConst    -- 返回TimingConst常量表
