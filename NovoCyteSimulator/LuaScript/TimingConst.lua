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
  SMOTOR                        = 0,    -- SMotor(��������) ID��
  IMOTOR                        = 1,    -- IMotor(ע����) ID��
  PMOTOR                        = 2,    -- PMotor(FMI��) ID��

  SAMPLE_MIN_SPEED              = 1,    -- 1uL/min
  SAMPLE_MAX_SPEED              = 120,  -- 120uL/min

  INSTRUMENT_IS_RUO             = 0,    -- RUO����
  INSTRUMENT_IS_IVD             = 1,    -- IVD����

  TEST_IS_ABS                   = 0,    -- ���Լ�������ģʽ
  TEST_IS_NOABS                 = 1,    -- PID����ģʽ

  MOTOR_STOP                    = 0,    -- ���Ƶ��ֹͣ
  MOTOR_RUN                     = 1,    -- ���Ƶ������
  MOTOR_RESET                   = 2,    -- ���Ƶ����λ
  MOTOR_CHSPEED                 = 3,    -- ���Ƶ������
  MOTOR_KEEP                    = 4,    -- �޲���

  SMOTOR_ACC                    = 4800, -- SMotor�ļ��ٶ�(��λ:rpm/s)
  IMOTOR_ACC                    = 4800, -- IMotor�ļ��ٶ�(��λ:rpm/s)
  PMOTOR_ACC                    = 4800, -- PMotor�ļ��ٶ�(��λ:rpm/s)

  WORK_STARTUP                  = 1,    -- ��ʾʱ���ʼ��״̬
  WORK_IDLE                     = 2,    -- ��ʾ����״̬
  WORK_MEASURE                  = 3,    -- ��ʾ����״̬
  WORK_MAINTAIN                 = 4,    -- ��ʾά��״̬
  WORK_ERRORHANDLE              = 6,    -- ��ʾ������״̬
  WORK_SLEEP                    = 8,    -- ��ʾ����״̬
  WORK_SHUTDOWN                 = 9,    -- ��ʾ�ػ�״̬
  WORK_INITPRIMING              = 10,   -- ��ʾ�״ι�ע״̬
  WORK_DRAIN                    = 11,   -- ��ʾ�ſ�״̬
  WORK_SLEEPENTER               = 12,   -- ��ʾ��������״̬
  WORK_SLEEPEXIT                = 13,   -- ��ʾ�˳�����״̬
  WORK_DECONTAMINATION          = 14,   -- ��ʾ����״̬
  WORK_ERRORDIAGNOSIS           = 15,   -- ��ʾ�������״̬
  WORK_MOTORGOHOME              = 16,   -- ��ʾ��λ״̬
  WORK_STOP                     = 17,   -- ��ʾ��ȫ��ֹ���ܹ���״̬

  MAINTAIN_STOP                 = 0,    -- ��ʾ
  MAINTAIN_DEBUBBLE             = 1,    -- ��ʾdebubbleά��״̬
  MAINTAIN_CLEANING             = 2,    -- ��ʾcleaningά��״̬
  MAINTAIN_RINSE                = 3,    -- ��ʾrinseά��״̬
  MAINTAIN_EXTRINSE             = 4,    -- ��ʾextrinseά��״̬
  MAINTAIN_PRIMING              = 5,    -- ��ʾprimingά��״̬
  MAINTAIN_UNCLOG               = 6,    -- ��ʾunclogά��״̬
  MAINTAIN_BACKFLUSH            = 7,    -- ��ʾbackflushά��״̬

  WORK_QUIT_Wait                = 0,    -- �ȴ�ʱ��ڵ�
  WORK_QUIT_Next                = 1,    -- ��һ��ʱ��ڵ�
  WORK_QUIT_Normal              = 2,    -- �����˳�
  WORK_QUIT_Abort               = 3,    -- �쳣�ж��˳�
  
  ERROR_RESUME_SIPFIRING        = 1,    -- ײ�����ָ�
  ERROR_RESUME_PRESSURE         = 2,    -- ѹ���ָ�
  ERROR_RESUME_PRESSUREEXT      = 3,    -- ѹ�����޻ָ�
  ERROR_RESUME_SIPABNORMAL      = 4,    -- �������쳣�ָ�

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

  PID_Stop                      = 0,    -- ֹͣPID����
  PID_Start                     = 1,    -- ����PID����
  PTC_Start                     = 2,    -- ����PID��������
  PTC_Stop                      = 3,    -- ֹͣPID��������
  
  CURRENT_VOLTAGE_SENOSR        = 0,    --������ѹ���AD
  FLUIDICS_STATION_SENOSR       = 1,    --��Һ̨���AD
  PRESSURE_SENOSR               = 2,    --ѹ�����AD
  
  PRESSURE_SENOSR1              = 0,    --ѹ��������1
  PRESSURE_SENOSR2              = 1,
  PRESSURE_SENOSR3              = 2,
  PRESSURE_SENOSR4              = 3,

  TURN_OFF                      = 0,  
  TURN_ON                       = 1
}

setmetatable(TimingConst, const.Const(TIMING_CONST_TABLE))
return TimingConst    -- ����TimingConst������
