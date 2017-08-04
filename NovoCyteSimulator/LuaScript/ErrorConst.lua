#!/usr/local/bin/lua

ErrorConst = ErrorConst or {}

local TIMING_STOPERROR_TABLE      = {  
  VOLTAGE_OVER_LIMIT              = 0x0006,                  -- ��������
  CURRENT_OVER_LIMIT              = 0x0007,                  -- ��ѹ����
  FIRMWARE_CONFIGURATION_ERROR    = 0x0008,                  -- Flashδ���û���������У�����
  SIP_RESET_FAILED                = 0x001C,                  -- �����븴λʧ��
  SAMPLINGPUMP_RESET_FAILED       = 0x001D,                  -- �����ø�λʧ��
  SHEATHPUMP_RESET_FAILED         = 0x0021                   -- ��Һ�ø�λʧ��
}

local TIMING_HANDLEERROR_TABLE    = {
  SIPCOLLISION_WHENSAMPLING       = 0x0001,                  -- ����ʱײ��
  SIPCOLLISION                    = 2                        -- ��ͨײ��
}

local TIMING_DIAGNOSISERROR_TABLE = {
  PRESSURESENSOR1_OVER_LIMIT      = 1,                       -- ѹ������
  PRESSURESENSOR2_OVER_LIMIT      = 2                        -- ѹ���ָ�
}

local TIMING_OTHERERROR_TABLE     = {
  RUNNING_OUT_OF_NOVOFLOW         = 0x0002,                  -- ��Һ��������
  RUNNING_OUT_OF_NOVORINSE        = 0x0003,                  -- ��ϴҺ��������
  RUNNING_OUT_OF_NOVOCLEAN        = 0x0004,                  -- ��ϴϴҺ��������
  WASTE_CONTAINER_IS_FULL         = 0x0005
}

ErrorConst          = {

StopErrorConst      = TIMING_STOPERROR_TABLE,                -- ϵͳֹͣ���������
HandleErrorConst    = TIMING_HANDLEERROR_TABLE,              -- �Զ����������
DiagnosisErrorConst = TIMING_DIAGNOSISERROR_TABLE            -- �Զ���������

}

return ErrorConst    -- ����ErrorConst������
