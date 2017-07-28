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
  SMOTOR                = 0,    -- SMotor(��������) ID��
  IMOTOR                = 1,    -- IMotor(ע����) ID��
  PMOTOR                = 2,    -- PMotor(FMI��) ID��
  
  SAMPLE_MIN_SPEED      = 1,    -- 1uL/min
  SAMPLE_MAX_SPEED      = 120,  -- 120uL/min

  INSTRUMENT_IS_RUO     = 0,
  INSTRUMENT_IS_IVD     = 1,

  TEST_IS_ABS           = 0,
  TEST_IS_PID           = 1,

  MOTOR_STOP            = 0,    -- ���Ƶ��ֹͣ
  MOTOR_RUN             = 1,    -- ���Ƶ������
  MOTOR_RESET           = 2,    -- ���Ƶ����λ
  MOTOR_CHSPEED         = 3,    -- ���Ƶ������
  MOTOR_KEEP            = 4,    -- �޲���

  SMOTOR_ACC            = 4800, -- SMotor�ļ��ٶ�(��λ:rpm/s)
  IMOTOR_ACC            = 4800, -- IMotor�ļ��ٶ�(��λ:rpm/s)
  PMOTOR_ACC            = 4800, -- PMotor�ļ��ٶ�(��λ:rpm/s)

  WORK_STARTUP          = 1,    -- ��ʾʱ���ʼ��״̬
  WORK_IDLE             = 2,    -- ��ʾ����״̬
  WORK_MEASURE          = 3,    -- ��ʾ����״̬
  WORK_MAINTAIN         = 4,    -- ��ʾά��״̬
  WORK_ERROR            = 6,    -- ��ʾ������״̬
  WORK_SLEEP            = 8,    -- ��ʾ����״̬
  WORK_SHUTDOWN         = 9,    -- ��ʾ�ػ�״̬
  WORK_INITPRIMING      = 10,   -- ��ʾ�״ι�ע״̬
  WORK_DRAIN            = 11,   -- ��ʾ�ſ�״̬
  WORK_SLEEPENTER       = 12,   -- ��ʾ��������״̬
  WORK_SLEEPEXIT        = 13,   -- ��ʾ�˳�����״̬
  WORK_DECONTAMINATION  = 14,   -- ��ʾ����״̬

  MAINTAIN_STOP         = 0,    -- ��ʾ
  MAINTAIN_DEBUBBLE     = 1,    -- ��ʾdebubbleά��״̬
  MAINTAIN_CLEANING     = 2,    -- ��ʾcleaningά��״̬
  MAINTAIN_RINSE        = 3,    -- ��ʾrinseά��״̬
  MAINTAIN_EXTRINSE     = 4,    -- ��ʾextrinseά��״̬
  MAINTAIN_PRIMING      = 5,    -- ��ʾprimingά��״̬
  MAINTAIN_UNCLOG       = 6,    -- ��ʾunclogά��״̬
  MAINTAIN_BACKFLUSH    = 7,    -- ��ʾbackflushά��״̬

  WORK_QUIT_Wait        = 0,    -- �ȴ�ʱ��ڵ�
  WORK_QUIT_Next        = 1,    -- ��һ��ʱ��ڵ�
  WORK_QUIT_Normal      = 2,    -- �����˳�
  WORK_QUIT_Abort       = 3,    -- �쳣�˳�

  MEASURE_None          = 0,
  MEASURE_Boosting      = 1,
  MEASURE_Testing       = 2,
  MEASURE_Washing       = 3,
  MEASURE_Resetting     = 4,

  BOOSTING_Step1        = 0,
  BOOSTING_Step2        = 1,

  TESTING_None          = 0,
  TESTING_Step1         = 1,
  TESTING_Step2         = 2,

  PID_Stop              = 0,
  PID_Start             = 1,
  PTC_Start             = 2,
  PTC_Stop              = 3
}

setmetatable(TimingConst, const.Const(TIMING_CONST_TABLE))
return TimingConst    -- ����TimingConst������
