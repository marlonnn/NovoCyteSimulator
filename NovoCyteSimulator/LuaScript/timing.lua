#!/usr/local/bin/lua
--******************************************************************************
-- timing.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

require "LuaScript\\TimingConst"

local TIMING_VERSION="Debug_1.1.0"

--[[
def_motor = function {opt, dir, acc, omega, rounds}
  local motor_param = {}
  motor_param.opt
end
--]]
--[[
Motor direction
  dir         0          1
  S-Motor:   +:Up,     -:Down
  I-Motor:   +:Pull,   -:Push
  P-Motor:   +:CW,     -:CCW(normal sheath flow direction)
--]]
--[[
Motor name
  S-Motor:   Sample injection probe pump, Motor_1@DebugSoftware
  I-Motor:   Sampling pump,               Motor_2@DebugSoftware
  P-Motor:   Sheath pump,                 Motor_3@DebugSoftware
--]]
local UP   =  1
local DN   = -1
local PULL =  1
local PUSH = -1
local CW   =  1
local CCW  = -1       --CCW:normal sheath flow direction

function MotorParam(param)
  if type(param.opt) ~= "number" then
    error("motor param no opt")
  else

  end

  local motor_param = {}
  motor_param.opt = param.opt

end

ACTION_End = function()
  return 0
end

ACTION_None = nil

SIP_Reset = function ()
  logger:info("Run Custom SMOTOR Reset")
end

-------------------------------------------------------------------------
-- SUB-Timing definition
-------------------------------------------------------------------------
-- ֹͣ��������з�
local TIMING_AllStop = {
  name = "allstop",
  {
  ticks     = 100,
  --valve  = nil,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- ����Motor��λ����е���,ͬʱ�ͷ�ѹ��
local TIMING_SUB_MotorsGoHome = {
  name = "SUB-MotorsGoHome",
-- 0X01
  {
  ticks     = 1200,   -- 1200ticks = 6s
  valve     = {4, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RESET},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*450.0, rounds = 40.0}
  },
-- 0x02
  {
  ticks     = 1400,   -- 1400ticks = 7s
  valve     = {4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0X03
  {
  ticks     = 100,   -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- �ػ����������������������
local TIMING_SUB_SIPSoak = {
  name = "SUB-SIPSoak",
-- 0x01 ��������������,���볬��ˮ��
  {
  ticks     = 400,  -- 400ticks = 2s
  --valve  = nil,
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 2.0},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- �����������Ϻ�ĸ�λ
local TIMING_SUB_SIPGoHome = {
  name = "SUB-SIPGoHome",
-- 0x01 ���������븴λ
  {
  ticks     = 200,  -- 200ticks = 1s
  --valve  = nil,
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- ��ע����
local TIMING_SUB_Priming = {
  name = "SUB-Priming",
-- 0x01 ��עfilter1,filter5
  {
  ticks     = 11000,         -- 11000ticks = 55s
  valve     = {3, 6, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x02 ��עNovoCleanԤ��������V11,Һ����Ϊ��·�ݻ�1��
  {
  ticks     = 8000,         -- 8000ticks = 40s
  valve     = {8, 9, 10, 11, 13}
  },
-- 0x03 ��עNovoRinseԤ����������Һ��,ͬʱ��NovoRinseȥ����Һ���е�����
  {
  ticks     = 9000,
  valve     = {8, 9, 10, 13}
  },
-- 0x04 ��Һ��ֹͣ,�Ŷ���ǻ����
  {
  ticks     = 200,
  valve     = {8, 9, 10, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x05 ��Һ������,���������ǻ����
  {
  ticks     = 400,
  valve     = {8, 9, 10, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 100000}
  },
-- 0x06 ��NovoFlow��ϴV8-V10֮���NovoRinse
  {
  ticks     = 1000,
  valve     = {8, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
-- 0x07 ��NovoFlow��ϴV8-V10֮���NovoRinse
  {
  ticks     = 1000,
  valve     = {3, 8, 13}
  },
-- 0x08 ���������������Ŷ������ڿ��ܲ�����NovoClean
  {
  ticks     = 200,
  valve     = {3, 8, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4}
  },
-- 0x09 ���������������Ŷ������ڿ��ܲ�����NovoClean
  {
  ticks     = 200,
  valve     = {3, 8, 13},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x0A ��ϴ����������
  {
  ticks     = 400,
  valve     = {4, 9, 13}
  },
-- 0x0B ��ϴflowchamber��Һ���
  {
  ticks     = 1000,
  valve     = {6, 9, 13}
  },
-- 0x0C ��ϴ����������
  {
  ticks     = 700,
  valve     = {2, 4, 13}
  },
-- 0x0D ����
  {
  ticks     = 100,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_Priming = {
  name = "IDX-Priming",
  0x01, 0x02, 0x03,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,

  0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09,
  0x0A, 0x0B,

  0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09,
  0x0A, 0x0B,

  0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09,
  0x0A, 0x0B,

  0x0C, 0x0D
}

-- ������
local TIMING_SUB_Debubble = {
  name = "SUB-Debubble",
-- 0x01 ��ϴ����������,��ֹ�������������е�����������ע������ǻ
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {4, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x02 ��Һ�ý�NovoRinse���͵�Flow chamber
  {
  ticks     = 3000,         -- 3000ticks = 15s
  valve     = {8, 9, 10, 13}
  },
-- 0x03 ��NovoRinse����ע������ǻ��
  {
  ticks     = 1700,         -- 1700ticks = 8.5s
  valve     = {8, 9, 10, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 20.0}
  },
-- 0x04 ע������NovoRinse����flowcell
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {8, 9, 10, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 20.0}
  },
-- 0x05 ������ֹͣ,�����Ŷ�,���������������ǻ���ܲ���������
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {8, 9, 10, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x06 ����������,�����Ŷ�,���������������ǻ���ܲ���������
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 8, 9, 10, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 100000}
  },
-- 0x07 ע�����ڵײ������Ŷ�
  {
  ticks     = 600,          -- 600ticks = 3.0s
  valve     = {2, 8, 9, 10, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 4.5}
  },
-- 0x08 ע�����ڵײ������Ŷ�
  {
  ticks     = 400,         -- 400ticks = 2.0s
  valve     = {8, 9, 10, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 4.5}
  },
-- 0x09 ע������λ
  {
  ticks     = 2500,         -- 2500ticks = 12.5s
  valve     = {8, 9, 10, 13},
  imotor    = {op = TimingConst.MOTOR_RESET},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*271.0}
  },
-- 0x0A ����
  {
  ticks     = 100,          -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_Debubble = {
  name = "IDX-Debubble",
  0x01,          -- ��ϴ����������,��ֹ�������������е�����������ע������ǻ
  0x02,          -- ��Һ�ý�NovoRinse���͵�Flow chamber

  0x03,          -- ��NovoRinse����ע������ǻ
  0x04,          -- ע������NovoRinse����flowcell
  0x05, 0x06, 0x05, 0x06, 0x05, 0x06, 0x05, 0x06,
                 -- ����������ֹͣ�Ŷ���ǻ����������
  0x03,
  0x04,
  0x05, 0x06, 0x05, 0x06, 0x05, 0x06, 0x05, 0x06,
  0x03,

  0x07, 0x08, 0x07, 0x08,
  0x07, 0x08, 0x07, 0x08,
                 -- ע���������ڵײ������Ŷ�
  0x09, 0x0A     -- ����
}

-- ��ϴV8-V10֮��NovoRinse
local TIMING_SUB_WashAwayNR = {
  name = "SUB-WashAwayNR",
-- 0x01 ��ϴNovoRinse���͹�·
  {
  ticks     = 2000,                   -- 2000ticks = 10s
  valve     = {8, 9},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x02 ��NovoFlow��ϴ��Һ�ü����͹�·
  {
  ticks     = 800,                   -- 800ticks = 4s
  valve     = {3, 8, 9, 13}
  },
--0x03 ���������������˶�,�Ŷ�������ǻ�п��ܲ�����NovoRinse
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4}
  },
--0x04 ���������������˶�,�Ŷ�������ǻ�п��ܲ�����NovoRinse
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x05 ����
  {
  ticks     = 100,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_WashAwayNR = {
  name = "IDX-WashAwayNR",
  0x01, 0x02,
  0x03, 0x04, 0x03, 0x04, 0x03, 0x04,
  0x03, 0x04, 0x03, 0x04, 0x03, 0x04,
                    -- ���������������˶�,�Ŷ�������ǻ�п��ܲ�����NovoRinse
  0x05
}

-- ��ϴ����
local TIMING_SUB_Rinse = {
  name = "SUB-Rinse",
-- 0x01 ��ϴ����������·
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {4, 9},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x02 ��ϴ����������·
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {2, 4, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
-- 0x03 ע���������Ŷ�,��ϴ����������·
  {
  ticks     = 500,         -- 500ticks = 2.5s
  valve     = {4, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
-- 0x04 ע���������Ŷ�,��ϴ����������·
  {
  ticks     = 700,         -- 700ticks = 3.5s
  valve     = {4, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*271.0}
  },
-- 0x05 ע���������Ŷ�,��ϴ����������·��flowchamber��Һ���
  {
  ticks     = 1000,         -- 1000ticks = 5.0s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 5.0}
  },
-- 0x06 ��chamber��������ϴ��ǻ
  {
  ticks     = 1000,         -- 1000ticks = 5.0s
  valve     = {8, 9, 13}
  },
-- 0x07 ��Һ��ֹͣ
  {
  ticks     = 100,         -- 100ticks = 0.5s
  valve     = {8, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x08 ��Һ�÷�����Һ240ul
  {
  ticks     = 500,         -- 500ticks = 2.5s
  valve     = {8, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CW*542.0, rounds = 20.0}
  },
-- 0x09 ��Һ��������Һ300ul
  {
  ticks     = 600,         -- 600ticks = 3.0s
  valve     = {8, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 25.0}
  },
-- 0x0A ��ϴ���ӹ�·
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 13},
  },
-- 0x0B ���������������˶�,�Ŷ�������ǻ�п��ܲ�����NovoClean
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4}
  },
-- 0x0C ���������������˶�,�Ŷ�������ǻ�п��ܲ�����NovoClean
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 13},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x0D ����Һ��·��ϴchamber
  {
  ticks     = 1500,         -- 1500ticks = 7.5s
  valve     = {6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
-- 0x0E ����Һ��·��ϴchamber
  {
  ticks     = 1500,         -- 1500ticks = 7.5s
  valve     = {6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x0F ��ϴ���ӹ�·
  {
  ticks     = 200,         -- 600ticks = 1.0s
  valve     = {8, 3, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x10 ��ϴ����������·
  {
  ticks     = 1500,         -- 1500ticks = 7.5s
  valve     = {4, 9}
  },
-- 0x11 ����
  {
  ticks     = 100,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_RinseNR = {
  name = "IDX-RinseNR",
  0x01, 0x02,                -- ��ϴ��&����������
  0x03, 0x04, 0x03, 0x05,
  0x03, 0x04, 0x03, 0x05,    -- ��ϴ��&����������,ע���������Ŷ�
  0x06, 0x0D,                -- ��ϴchamber
  0x0A,
  0x0B, 0x0C, 0x0B, 0x0C,    -- ��ϴ����

  0x03, 0x04, 0x03, 0x05,
  0x03, 0x04, 0x03, 0x05,
  0x06, 0x0D,
  0x0A,
  0x0B, 0x0C, 0x0B, 0x0C,
  0x11
}

local TIMING_IDX_RinseNC = {
  name = "IDX-RinseNC",
  0x01,                      -- ��ϴ����������
  0x03, 0x04, 0x03, 0x04,    -- ��ϴ����������,ע���������Ŷ�
  0x02,                      -- ��ϴ����������
  0x0D, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09,
  0x0E,                      -- ��ϴchamber
  0x0A,
  0x0B, 0x0C, 0x0B, 0x0C,    -- ��ϴ����

  0x03, 0x04, 0x03, 0x04,
  0x0D, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09,
  0x0E,
  0x0A,
  0x0B, 0x0C, 0x0B, 0x0C,

  0x10, 0x0D, 0x11
}

-- NovoClean��ϴ����
local TIMING_SUB_NovoCleanCleaning = {
  name = "SUB-NovoCleanCleaning",
-- 0x01 ��ϴ����������,��ֹ�������������е�����������ע������ǻ
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {4, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x02 ��ϴ����������,��ֹ�������������е�����������ע������ǻ
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {2, 4, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x03 ��Һ�ý�NovoClean�˵�flowchamber,��NovoClean��flowcell������ϴ
  {
  ticks     = 6000,         -- 6000ticks = 30s  2.25��
  valve     = {2, 8, 9, 10, 11, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*100.0, rounds = 2.0}
  },
-- 0x04 ��ע������NovoClean���빫��������·
  {
  ticks     = 840,         -- 840ticks = 4.2s
  valve     = {8, 9, 10, 11},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*100.0, rounds = 6.5}
  },
-- 0x05 ��NovoClean��������������·
  {
  ticks     = 100,         -- 100ticks = 0.5s
  valve     = {2, 8, 9, 10, 11, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 6.5},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x06 ��Һ�÷�����Һ240ul
  {
  ticks     = 500,         -- 500ticks = 2.5s
  valve     = {2, 8, 9, 10, 11, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CW*542.0, rounds = 20.0}
  },
-- 0x07 ��Һ��������Һ300ul
  {
  ticks     = 600,         -- 600ticks = 3.0s
  valve     = {2, 8, 9, 10, 11, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 25.0}
  },
-- 0x08 ��ע������NovoClean���빫��������·
  {
  ticks     = 870,         -- 870ticks = 4.35s
  valve     = {8, 9, 10, 11},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*100.0, rounds = 6.5},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 50}
  },
-- 0x09 ��NovoClean�˵���Һ�ù�·
  {
  ticks     = 1000,         -- 1000ticks = 5.0s
  valve     = {3, 8, 10, 11, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x0A ����
  {
  ticks     = 100,          -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_NovoCleanCleaning = {
  name = "IDX-NovoCleanCleaning",
  0x01, 0x02,              -- ��ϴ���������ܼ�����������,��ֹ�������������е������ȱ�����ע������ǻ
  0x03,                    -- ��Һ�ý�NovoClean�˵�Flow chamber,��NovoClean��flowcell������ϴ
  0x04, 0x05,              -- ��ע������NovoClean���빫��������·,�Ƶ�����������·
  0x06, 0x07,              -- ��Һ����ת��ת,��ϴflowcell

  0x08, 0x05,
  0x06, 0x07,

  0x08, 0x05,
  0x06, 0x07,

  0x08,
  0x06, 0x07,
  0x09, 0x0A               -- ����
}

-- ����Flowcell��������·,���н��в��ֹ�·����ϴ
local TIMING_SUB_Soak = {
  name = "SUB-Soak",
--0x01 ����
  {
  ticks     = 6000,         -- 6000ticks = 30s
  valve     = {8, 9, 10, 11},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*20.0, rounds = 100000}
  },
--0x02 ��NovoRinse���V10-V11֮���·
  {
  ticks     = 1400,         -- 1400ticks = 7s
  valve     = {3, 8, 10, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
--0x03 ��NovoFlow��ϴNovoClean���͹�·,V10-flow hamber�����ͨ��ͷ֮���·��3��
  {
  ticks     = 800,         -- 800ticks = 4s
  valve     = {3, 8, 13}
  },
--0x04 ���������������˶�,�Ŷ�������ǻ�п��ܲ�����NovoClean
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4}
  },
--0x05 ���������������˶�,�Ŷ�������ǻ�п��ܲ�����NovoClean
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 13},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x06 ע������λ
  {
  ticks     = 1200,         -- 1200ticks = 6.0s
  valve     = {2, 3, 8, 13},
  imotor    = {op = TimingConst.MOTOR_RESET},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*271.0}
  },
-- 0x07 ��ϴ����������
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {2, 4, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
-- 0x08 ע���������Ŷ�
  {
  ticks     = 500,         -- 500ticks = 2.5s
  valve     = {2, 4, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
-- 0x09 ע���������Ŷ�
  {
  ticks     = 700,         -- 700ticks = 3.5s
  valve     = {2, 4, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*271.0}
  },
--0x0A ����
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_Soak = {
  name = "IDX-Soak",
  0x01,             -- ����
  0x02,             -- ��NovoRinse��ϴV10��V11֮���·
  0x03,             -- ��NovoFlow��ϴNovoClean���͹�·
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
                    -- ���������������˶�,�Ŷ�������ǻ�п��ܲ�����NovoClean
  0x06,             -- ע������λ
  0x07,             -- ��ϴ����������
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09,
                    -- ��ϴ����������,ע�������������Ŷ�
  0x0A              -- ����
}

-- ���Լ�������ʱ��
local TIMING_SUB_AbsSampleAcquisition = {
  name = "SUB-AbsSampleAcquisition",
--0x01 ��������������
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step1      -- set step to step1
    self.idr  = 0
    local void, hasAutoSampler, rounds = subwork:samplerounds()
    if hasAutoSampler then 
      item.smotor.rounds = rounds
    else 
      item.smotor.rounds = config.smotor.lowrounds
    end
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
  end,
  ticks     = 30,           -- 30ticks = 0.15s,��֤�������¶������
  valve     = {2, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*650.0, rounds = 100000.0}
  },
--0x02 �������������й�����,����10ul�������
  {
  beginhook = function (self, item)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 160,           -- 160ticks = 0.8s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 1000, omega = PULL*120.0, rounds = 0.3}  --ȥ��ע����5uL�س̲�
  },
--0x03 ��������
  {
  beginhook = function (self, item)
    local void, size = subwork:sampleinfo()
    local extsize = config.compensation[TimingConst.TEST_IS_ABS].size
    local omega = math.abs(item.imotor.omega)
    --local extticks = omega / item.imotor.alpha * 2 * tmr:tickspersec() + 20
    --item.ticks = (size + extsize) * (tmr:tickspermin()/config.imotor.volumperround)/omega + extticks;
    item.imotor.rounds = (size + extsize)/config.imotor.volumperround
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 900,          -- 900ticks = 4.5s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PULL*40.0}
  },
--0x04 ��������������
  {
  beginhook = function (self, item)
    local void, hasAutoSampler, rounds = subwork:samplerounds()
    if hasAutoSampler then 
      item.smotor.rounds = rounds - 0.4
    else 
      item.smotor.rounds = config.smotor.lowrounds - 0.4
    end
  end,
  ticks     = 120,           -- 120ticks = 0.6s
  valve     = {2, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = UP*150.0}
  },
--0x05 ���������빫��������·
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step2      -- set step to step2
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 300,          -- 300ticks = 1.5s   0.4s��⼴�ɸ�λ
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PULL*100.0, rounds = 1.90}
  },
--[[
--0x06 ���������빫��������·
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step2      -- set step to step2
  end,
  ticks     = 220,          -- 220ticks = 1.1s
  valve     = {2, 6, 9, 13}
  },
--]]
--0x07 �������ӹ���������·boost��flow cell�����
  {
  beginhook = function (self, item)
    local r = config.imotor.boostrounds[TimingConst.TEST_IS_ABS]
    local omega = math.abs(item.imotor.omega)
    local alpha = item.imotor.alpha
    item.imotor.rounds = r
    local tmpr = omega * omega / (alpha * 60)
    local t
    if r > tmpr then
      t = 2 * omega / alpha + (r - tmpr) / omega * 60
    else
      t = 2 * math.sqrt(r * 60 / alpha)
    end
    item.ticks = t * tmr:tickspersec() + 10

    self.idr = self.idr + PUSH * item.imotor.rounds
  end,
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PUSH*200.0}
  },
--0x08 PID������Һѹ����ʼ,ע������ǰ����,Ϊ��ʼ������׼��
  {
  beginhook = function (self, item)
    self.idr = self.idr + PUSH * item.imotor.rounds
    subwork:pidcontrol(TimingConst.PID_Start)
  end,
  ticks     = 600,           -- 6000ticks = 3.0s
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 200, omega = PUSH*5.0, rounds = 0.5}
  },
--0x09 boost��,���������ȶ���,ע�����������û��趨������������ͬ
  {
  beginhook = function (self, item)
    local void, void, rate = subwork:sampleinfo()
    local coef = config.compensation[TimingConst.TEST_IS_ABS].coef[config.instrumenttype]
    item.imotor.omega = PUSH * rate * coef / config.imotor.volumperround
    subwork:pidcontrol(TimingConst.PID_Stop)
    --subwork:pmtreset()
  end,
  ticks     = 200,          -- 200ticks = 1s
  valve     = {6, 9},
  imotor    = {op = TimingConst.MOTOR_CHSPEED, alpha = 25},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*config.pmotor.omega}
  },
--0x0A ��ʽ����,��ʼ�ɼ�����
  {
  beginhook = function (self, item)
    local void, size, rate = subwork:sampleinfo()
    local coef = config.compensation[TimingConst.TEST_IS_ABS].coef[config.instrumenttype]
    self.samplesize, self.samplerate = size, rate
    item.imotor.omega = PUSH * rate * coef / config.imotor.volumperround
    size = size * coef
    item.ticks = tmr:tickspermin() * size / TimingConst.SAMPLE_MIN_SPEED
    --item.ticks = tmr:tickspermin() * size / rate + 100
    local irounds = size / config.imotor.volumperround
    self.isamplerounds, item.imotor.rounds = irounds, irounds

    self.teststart = tmr:systicks()
    self.ref1 = TimingConst.MEASURE_Testing     -- set state to testing
    self.ref2 = 0                               -- set step to 0
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
    self.idr = self.idr + PUSH * irounds
    item.awakehook = self.awakehook
    subwork:cellstart()
    subwork:pidcontrol(TimingConst.PTC_Start)
  end,
  endhook = function (self, item)
    if self.isdrain then
      self.shadowCall = function (self)
        return {
          beginhook = function (self, item)
            local void, runrounds = motor:status(TimingConst.IMOTOR)
            local remainrounds = self.isamplerounds - runrounds
            item.ticks = remainrounds * tmr:tickspermin() / config.imotor.drainomega
            item.imotor.rounds = remainrounds
            self.ref1 = TimingConst.MEASURE_Resetting     -- set state to resetting
            self.ref2 = 0                                 -- set step to 0
            subwork:stateset(self.stateTo, self.ref1, self.ref2)
            subwork:cellstop(TimingConst.CELL_STOPWAY_SoftCmd)
          end,
          valve     = {6, 9, 13},
          --smotor    = {op = TimingConst.MOTOR_STOP},
          imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*config.imotor.drainomega}
        }
      end
    end
  end,
  awaketicks= 100,
  ticks     = 85715,        -- 85715ticks = 428.57s
  valve     = {6, 9},
  imotor    = {op = TimingConst.MOTOR_RUN}
  },
--0x0B ����ֹͣ
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Resetting   -- set state to resetting
    self.ref2 = 0                               -- set step to 0
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
    subwork:pidcontrol(TimingConst.PTC_Stop)
  end,
  ticks     = 5,         -- 5ticks = 25ms
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0X0C ���Խ���,ע��������������������ʣ���������������,ͬʱע���������������
  {
  beginhook = function (self, item)
    local r = self.idr
    local omega = math.abs(item.imotor.omega)
    local alpha = item.imotor.alpha

    if r > 0 then
      r = r + 0.3
      item.imotor.rounds = r
      local tmpr = omega * omega / (alpha * 60)
      local t
      if r > tmpr then
        t = 2 * omega / alpha + (r - tmpr) / omega * 60
      else
        t = 2 * math.sqrt(r * 60 / alpha)
      end
      item.ticks = t * tmr:tickspersec()
    else
      item.ticks = 100
      item.imotor.op = TimingConst.MOTOR_STOP
    end
  end,
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 4800, omega = PUSH*200.0}
  }
}

-- �Ǿ��Լ�������ʱ��
local TIMING_SUB_NoAbsSampleAcquisition = {
  name = "SUB-NoAbsSampleAcquisition",
--0x01 ��������������
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step1      -- set step to step1
    self.idr  = 0
    local void, hasAutoSampler, rounds = subwork:samplerounds()
    if hasAutoSampler then 
      item.smotor.rounds = rounds
    else 
      item.smotor.rounds = config.smotor.lowrounds
    end
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
  end,
  ticks     = 30,           -- 60ticks = 0.15s,��֤�������¶������
  valve     = {2, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*748.0, rounds = 100000.0}
  },
--0x02 �������������й�����,����10ul�������
  {
  beginhook = function (self, item)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 160,           -- 160ticks = 0.8s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 4800, omega = PULL*120.0, rounds = 0.3}  --ȥ��ע����5uL�س̲�
  },
--0x03 ��������
  {
  beginhook = function (self, item)
    local void, size = subwork:sampleinfo()
    local extsize = config.compensation[TimingConst.TEST_IS_NOABS].size
    local omega = math.abs(item.imotor.omega)
    --local extticks = omega / item.imotor.alpha * 2 * tmr:tickspersec() + 20
    --item.ticks = (size + extsize) * (tmr:tickspermin()/config.imotor.volumperround)/omega + extticks;
    item.imotor.rounds = (size + extsize)/config.imotor.volumperround
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 200,          -- 200ticks = 1.0s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 4800, omega = PULL*240.0}
  },
--0x04 ��������������
  {
  beginhook = function (self, item)
    local void, hasAutoSampler, rounds = subwork:samplerounds()
    if hasAutoSampler then 
      item.smotor.rounds = rounds - 0.4
    else 
      item.smotor.rounds = config.smotor.lowrounds - 0.4
    end
  end,
  ticks     = 120,           -- 120ticks = 0.6s
  valve     = {2, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = UP*150.0}
  },
--0x05 ���������빫��������·
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step2      -- set step to step2
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 150,          -- 150ticks = 0.75s   0.4s��⼴�ɸ�λ
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PULL*200.0, rounds = 1.90}
  },
--[[
--0x06 ���������빫��������·
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step2      -- set step to step2
  end,
  ticks     = 220,          -- 220ticks = 1.1s
  valve     = {2, 6, 9, 13}
  },
--]]
--0x07 �������ӹ���������·boost��flow cell�����
  {
  beginhook = function (self, item)
    local r = config.imotor.boostrounds[TimingConst.TEST_IS_NOABS]
    local omega = math.abs(item.imotor.omega)
    local alpha = item.imotor.alpha
    item.imotor.rounds = r
    local tmpr = omega * omega / (alpha * 60)
    local t
    if r > tmpr then
      t = 2 * omega / alpha + (r - tmpr) / omega * 60
    else
      t = 2 * math.sqrt(r * 60 / alpha)
    end
    item.ticks = t * tmr:tickspersec() + 10

    self.idr = self.idr + PUSH * item.imotor.rounds
  end,
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PUSH*200.0}
  },
--0x08 PID������Һѹ����ʼ,ע������ǰ����,Ϊ��ʼ������׼��
  {
  beginhook = function (self, item)
    self.idr = self.idr + PUSH * item.imotor.rounds
    subwork:pidcontrol(TimingConst.PID_Start)
  end,
  ticks     = 600,           -- 6000ticks = 3.0s
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 200, omega = PUSH*5.0, rounds = 0.5}
  },
--0x09 boost��,���������ȶ���,ע�����������û��趨������������ͬ
  {
  beginhook = function (self, item)
    local void, void, rate = subwork:sampleinfo()
    local coef = config.compensation[TimingConst.TEST_IS_NOABS].coef[config.instrumenttype]
    item.imotor.omega = PUSH * rate * coef / config.imotor.volumperround
    subwork:pidcontrol(TimingConst.PID_Stop)
    --subwork:pmtreset()
  end,
  ticks     = 200,          -- 200ticks = 1s
  valve     = {6, 9},
  imotor    = {op = TimingConst.MOTOR_CHSPEED, alpha = 25},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*config.pmotor.omega}
  },
--0x0A ��ʽ����,��ʼ�ɼ�����
  {
  beginhook = function (self, item)
    local void, size, rate = subwork:sampleinfo()
    local coef = config.compensation[TimingConst.TEST_IS_NOABS].coef[config.instrumenttype]
    self.samplesize, self.samplerate = size, rate
    item.imotor.omega = PUSH * rate * coef / config.imotor.volumperround
    size = size * coef
    item.ticks = tmr:tickspermin() * size / TimingConst.SAMPLE_MIN_SPEED
    --item.ticks = tmr:tickspermin() * size / rate + 100
    local irounds = size / config.imotor.volumperround
    self.isamplerounds, item.imotor.rounds = irounds, irounds

    self.teststart = tmr:systicks()
    self.ref1 = TimingConst.MEASURE_Testing     -- set state to testing
    self.ref2 = 0                               -- set step to 0
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
    self.idr = self.idr + PUSH * irounds
    item.awakehook = self.awakehook
    subwork:cellstart()
    subwork:pidcontrol(TimingConst.PTC_Start)
  end,
  endhook = function (self, item)
    if self.isdrain then
      self.shadowCall = function (self)
        return {
          beginhook = function (self, item)
            local void, runrounds = motor:status(TimingConst.IMOTOR)
            local remainrounds = self.isamplerounds - runrounds
            item.ticks = remainrounds * tmr:tickspermin() / config.imotor.drainomega
            item.imotor.rounds = remainrounds
            self.ref1 = TimingConst.MEASURE_Resetting     -- set state to resetting
            self.ref2 = 0                                 -- set step to 0
            subwork:stateset(self.stateTo, self.ref1, self.ref2)
            subwork:cellstop(TimingConst.CELL_STOPWAY_SoftCmd)
          end,
          valve     = {6, 9, 13},
          --smotor    = {op = TimingConst.MOTOR_STOP},
          imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*config.imotor.drainomega}
        }
      end
    end
  end,
  awaketicks= 100,
  ticks     = 85715,        -- 85715ticks = 428.57s
  valve     = {6, 9},
  imotor    = {op = TimingConst.MOTOR_RUN}
  },
--0x0B ����ֹͣ
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Resetting   -- set state to resetting
    self.ref2 = 0                               -- set step to 0
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
    subwork:pidcontrol(TimingConst.PTC_Stop)
  end,
  ticks     = 5,         -- 5ticks = 25ms
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0C ���Խ���,ע��������������������ʣ���������������,ͬʱע���������������
  {
  beginhook = function (self, item)
    local r = self.idr
    local omega = math.abs(item.imotor.omega)
    local alpha = item.imotor.alpha

    if r > 0 then
      r = r + 0.3
      item.imotor.rounds = r
      local tmpr = omega * omega / (alpha * 60)
      local t
      if r > tmpr then
        t = 2 * omega / alpha + (r - tmpr) / omega * 60
      else
        t = 2 * math.sqrt(r * 60 / alpha)
      end
      item.ticks = t * tmr:tickspersec()
    else
      item.ticks = 100
      item.imotor.op = TimingConst.MOTOR_STOP
    end
  end,
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 4800, omega = PUSH*200.0}
  }
}

-- ���ܹ���У׼����
local TIMING_SUB_AdjustNormal = {
  name = "SUB-AdjustNormal"
}

-- �������̽�������ϴִ������
local TIMING_SUB_TestCleanNone = {
  name = "SUB-TestCleanNone",
--0x01 ��Һ��ֹͣ
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Resetting   -- set state to resetting
    self.ref2 = 0                               -- set step to 0
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
  end,
  ticks     = 90,          -- 90ticks = 0.45s
  valve     = {2, 4, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x02 �������������·
  {
  ticks     = 90,          -- 90ticks = 0.45s
  valve     = {2, 4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542, rounds = 3.0}
  },
--0x03 ��Һ�ø�λ,�ͷ�ѹ��
  {
  ticks     = 160,           -- 160ticks = 0.8s
  valve     = {2, 4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x04 ���з��ر�,����
  {
  ticks     = 10            -- 10ticks = 50ms
  }
}

-- �������̽�������״���ϴ����
local TIMING_SUB_TestCleanFirst = {
  name = "SUB-TestCleanFirst",
--0x01 �����������ڱ���ϴ
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Washing   -- set state to washing
    self.ref2 = 0                             -- set step to 0
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
  end,
  ticks     = 500,          -- 500ticks = 2.5s
  valve     = {4, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*800.0}
  },
--0x02 ��������������,ͬʱ���������ϴ
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {3, 4, 6, 8, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = UP*30.0, rounds = 0.4}
  },
--0x03 �����������ڱ���ϴ
  {
  ticks     = 700,          -- 700ticks = 3.5s
  valve     = {2, 3, 4, 9, 13}
  },
--0x04 ��Һ��ֹͣ
  {
  ticks     = 80,          -- 80ticks = 0.4s
  valve     = {3, 4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x05 ����������,��Һ�ø�λ
  {
  ticks     = 200,          -- 200ticks = 1.0s
  valve     = {3, 4, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.45},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x06 V3�ر�,���������븴λ
  {
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {4, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x07 ���з��ر�,��Һ��ֹͣ,����
  {
  ticks     = 10,          -- 10ticks = 50ms
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- �������̽�����Ķ����ϴ����
local TIMING_SUB_TestCleanOthers = {
  name = "SUB-TestCleanOthers",
--0x01 �����������ڱ���ϴ
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Washing   -- set state to washing
    self.ref2 = 0                             -- set step to 0
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
  end,
  ticks     = 800,          -- 800ticks = 4s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 100000}
  },
--0x02 ��������������,ͬʱ���������ϴ
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = UP*15.0, rounds = 0.4}
  },
--0x03 ����������,ͬʱ���������ϴ
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*15.0, rounds = 0.35}
  },
--0x04 �ر�v3,ͬʱ�����븴λ
  {
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 �����������ڱ���ϴ
  {
  ticks     = 1000,          -- 1000ticks = 5s
  valve     = {1, 3, 8, 12}
  },
--0x06 ��Һ��ֹͣ
  {
  ticks     = 80,          -- 80ticks = 0.4s
  valve     = {3, 5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 ����������,��Һ�ø�λ
  {
  ticks     = 320,          -- 320ticks = 1.6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x08 v3�����ͷ�ѹ��
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {2, 3, 5, 8, 12}
  },
--0x09 V3�ر�,���������븴λ
  {
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x0a ���з��ر�,��Һ��ֹͣ,����
  {
  ticks     = 10,          -- 10ticks = 50ms
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- ײ���ĸ�λ��ϴ����
local TIMING_SUB_SIPHitClean = {
  name = "SUB-SIPHitClean",
--0x01 ��λ
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step1      -- set step to step1
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
  end,
  ticks     = 60,           -- 60ticks = 0.3s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*config.pmotor.omega, rounds = 100000}
  },
--0x02 �����������ڱ���ϴ
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {1, 3, 8, 12}
  },
--0x03 ��Һ��ֹͣ
  {
  ticks     = 80,           -- 80ticks = 0.4s
  valve     = {3, 5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 ����������,��Һ�ø�λ
  {
  ticks     = 320,           -- 320ticks = 1.6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4}, -- acc = acc or DEFAULT_ACC
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 v3�����ͷ�ѹ��
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 3, 5, 8, 12}
  },
--0x06 V3�ر�,���������븴λ
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x07 ���з��ر�,��Һ��ֹͣ,����
  {
  ticks     = 10,           -- 10ticks = 50ms
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- �״ι�ע----������;�����ʱ�䲻ʹ��,��Ҫ�ſ�,�ٶ�װ����ʹ��ǰ�����״ι�ע
-- InitPriming step 1: ��Һ��·��������·��ע
local TIMING_SUB_InitPrimingStep1 = {
  name = "SUB-InitPrimingStep1",
--0x01 ��עע������ǻ������������·��flowchamber��flowchamber��Һ��·
  {
  ticks     = 141000,           -- 141000ticks = 705s ��ע5��
  valve     = {4, 9},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
--0x02 ��ע����������·
  {
  ticks     = 500,           -- 500ticks = 2.5s ��ע5��
  valve     = {2, 4, 9, 13}
  },
--0x03 ��עNovoCleanͰ��V11
  {
  ticks     = 17000,           -- 17000ticks = 85s ��ע����NovoClean��V11�ݻ���2��
  valve     = {8, 9, 10, 11}
  },
--0x04 ��עNovoRinseͰ��flowchamber��ڹ�·
  {
  ticks     = 17400,           -- 17400ticks = 87s ��ע����NovoRinse��V10�ݻ���2��
  valve     = {8, 9, 10}
  },
--0x05 ����Һ��ϴNovoRinse���͹�·
  {
  ticks     = 4200,           -- 4200ticks = 21s ��ϴV10��flowchamber���2��
  valve     = {8, 9}
  },
--0x06 �ͷ�chamberѹ��
  {
  ticks     = 1200,           -- 1200ticks = 6s
  valve     = {4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 ��ע��Һ��·
  {
  ticks     = 11500,           -- 12000ticks = 57.5s ��ע2��
  valve     = {3, 6, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
--0x08 ֹͣ��Һ��,�ͷ�ѹ��
  {
  ticks     = 1600,           -- 1600ticks = 8s
  valve     = {4, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 ����ŷ��ر�
  {
  ticks     = 100           -- 100ticks = 0.5s
  }
}

local TIMING_IDX_InitPrimingStep1 = {
  name = "IDX-InitPrimingStep1",
  -- ��עע������ǻ������������·��flowchamber��flowchamber��Һ��·
  0x01,
  -- ��ע����������·
  0x02,
  -- ��עNovoClean��·
  0x03,
  -- ��עNovoRinse��·
  0x04,
  -- ��ϴNovoRinse���͹�·
  0x05, 0x06,
  -- ��ע��Һ��·
  0x07,
  -- ֹͣ��Һ��,����ŷ���λ
  0x08, 0x09
}


-- �ſ�----������;�����ʱ�䲻ʹ��,��Ҫ�ſ�
-- Drain step 1: �ó���ˮ��ϴ��·
local TIMING_SUB_DrainStep1 = {
  name = "SUB-DrainStep1",
--0x01 ��ϴNovoClean��·��10��
  {
  ticks     = 85000,           -- 85000ticks = 425s ��NovoCleanͰ>V11 ��ϴ10��
  valve     = {8, 9, 10, 11},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 10000000}
  },
--0x02 ��ϴNovoRinse��·��10��
  {
  ticks     = 100700,           -- 107000ticks = 503.5s ��NovoRinseͰ>��Һ��>NovoRinse���͹�·>chamber����ͷ ��ϴ10��
  valve     = {8, 9, 10}
  },
  --0x03 ��ϴ��Һ��·��10��
  {
  ticks     = 222500,           -- 222500ticks = 1125.5s
  valve     = {3, 6, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 10000000}
  },
--0x04 �ó���ˮ��ϴע������ǻ��������·��25��
  {
  ticks     = 152200,           -- 152200ticks = 761s ��ϴ20��
  valve     = {4, 9}
  },
--0x05 ע���������Ŷ���ǻ�е�����
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {4, 9},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 5.0}
  },
--0x06 ע���������Ŷ���ǻ�е�����
  {
  ticks     = 700,           -- 700ticks = 3.5s
  valve     = {4, 9},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*271.0}
  },
--0x07 ע���������Ŷ���ǻ�е�����
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {4, 9},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
--0x08 �ͷ�ѹ��
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 �ó���ˮ��ϴ����������·��30��
  {
  ticks     = 3000,           -- 3000ticks = 15s
  valve     = {2, 4, 9, 13},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
--0x0A �ͷ�ѹ��
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {2, 4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0B ����
  {
  ticks     = 200,           -- 200ticks = 1s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DrainStep1 = {
  name = "IDX-DrainStep1",
  -- NovoCleanͰ>>v11 ��ϴ10��
  0x01,
  -- NovoRinseͰ>��Һ��>NovoRinse���͹�·>chamber�����ͨ ��ϴ10��
  0x02,
  -- ��ҺͰ>��Һ��>damper>flow chamber>V3>���ӹ�·��ϴ10��
  0x03,
  -- ��ҺͰ>��Һ��>ע����>chamber>V9>��Һ��·��ϴ25��
  0x04,
  -- ��ҺͰ>��Һ��>ע����>chamber>V9>��Һ��·��ϴ15��,ע���������Ŷ�121��
  0x05, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,  
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,  
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,
  0x05, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,  
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,  
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x07, 0x06,
  0x07, 0x06, 0x07, 0x06, 0x07, 0x06, 0x08,
  -- ��ҺͰ>��Һ��>ע����>V2>���������ܳ�ϴ,Һ����Ϊ������������+�����������ݻ���30��
  0x09, 0x0A, 0x0B
}

-- Drain step 2: NovoClean��·��NovoRinse��·��������·����Һ��·�ſ�
local TIMING_SUB_DrainStep2 = {
  name = "SUB-DrainStep2",
--0x01 �ſ�NovoClean��·
  {
  ticks     = 25500,           -- 25500ticks = 127.5s ��NovoCleanͰ>v11 �ſ�3��
  valve     = {8, 9, 10, 11},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 10000000}
  },
--0x02 �ſ�NovoRinse��·
  {
  ticks     = 30300,           -- 30300ticks = 151.5s ��NovoRinseͰ>��Һ��>NovoRinse���͹�·>chamber��� �ſ�3��
  valve     = {8, 9, 10}
  },
--0x03 �ſ�ע������ǻ������������·��flowchamber��flowchamber��Һ��·
  {
  ticks     = 84600,           -- 84600ticks = 423s �ſ�3��
  valve     = {4, 9}
  },
--0x04 �ſ�����������·
  {
  ticks     = 1000,           -- 1000ticks = 5s �ſ�10��
  valve     = {2, 4, 9, 13}
  },
--0x05 �ſ���Һ��·
  {
  ticks     = 17200,           -- 17200ticks = 86s
  valve     = {3, 6, 13}
  },
--0x06 ��Һ�������ӵķ�Һ��·
  {
  ticks     = 1600,           -- 1600ticks = 8s
  valve     = {3, 4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 ��Һ��ֹͣ��Һ,�����ӷ�Һ��·�е�Һ��ۼ�,�Ա���һ�α�����
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {3, 4, 6, 9, 13}
  },
--0x08 ���е����λ
  {
  ticks     = 2700,           -- 2700ticks = 13.5s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RESET},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x09 ֹͣ��Һ��,�����е�ŷ��ر�,ֹͣ��Һ��,����
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DrainStep2 = {
  name = "IDX-DrainStep2",
  -- NovoCleanͰ>v11 �ſ�3��
  0x01,
  -- NovoRinseͰ>��Һ��>NovoRinse���͹�·>chamber��� �ſ�3��
  0x02,
  -- ��ҺͰ>��Һ��>ע����>chamber>V9>��Һ��·�ſ�3��
  0x03,
  -- ��ҺͰ>��Һ��>ע����>V2>���������ܳ�ϴ,�ſ�����������·3��
  0x04,
  -- ��ҺͰ>��Һ��>damper>flow chamber>V3>���ӹ�·��ϴ3��
  0x05,
  -- �������ӵķ�Һ��·
  0x06, 0x07, 0x06, 0x07, 0x06, 0x07,
  -- �����λ,���ر�,����
  0x08, 0x09
}

-- ����----����ʹ��һ��ʱ�������ϸ��,��Ҫ����
-- Decontamination step 1: ��NovoClean����������·
local TIMING_SUB_DeconStep1 = {
  name = "SUB-DeconStep1",
--0x01 ������Һ��,����ע������·
  {
  ticks     = 42000,           -- 42000ticks = 210s ��Һ��=22.75ml
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 1000000}
  },
--0x02 ����8��3��13��·
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*542.0}
  },
--0x03 ������Һ��·6��3��13
  {
  ticks     = 18000,           -- 18000ticks = 90s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
--0x04 ��������������
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*271.0}
  },
--0x05 ��Һ��ת�����
  {
  ticks     = 42000,           -- 42000ticks = 210s ��Һ��=22.75ml
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
--0x06 ֹͣ��Һ��
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07
  {
  ticks     = 1200,           -- 1200ticks = 6s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RESET}, -- Ĭ�ϸ�λ�ٶ�100rpm,��֤ע��������ײ�Ҳ�ܸ�λ
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*420.0, rounds = 35.0}
  },
--0x08
  {
  ticks     = 1400,           -- 1400ticks = 7s
  valve     = {3, 5, 7, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x09 ����
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DeconStep1 = {
  name = "IDX-DeconStep1",
  0x07, 0x08, 0x09,      -- ��λ

  0x01, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,

  0x06, 0x09
}


-- Decontamination step 2: NovoClean���ݹ�·,����ɱ������
local TIMING_SUB_DeconStep2 = {
  name = "SUB-DeconStep4",
--0x01 ����V4��V6��V8����4min
  {
  ticks     = 48000,           -- 48000ticks = 240s
  valve     = {3, 5, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x02 �ر�V4��V6��V8����2min
  {
  ticks     = 24000,           -- 24000ticks = 120s
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 ����
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
}

local TIMING_IDX_DeconStep2 = {
  name = "IDX-DeconStep2",
  0x01, 0x02, 0x01, 0x02, 0x01, 0x02,
  0x01, 0x02, 0x01, 0x02, 0x01, 0x02,
  0x01, 0x03
}

-- Decontamination step 5-1: ��ϴע������ǻ,��Խ���ʱ�����45min
local TIMING_SUB_DeconStep5_1 = {
  name = "SUB-DeconStep5_1",
--0x01 ������Һ��
  {
  ticks     = 24000,           -- 24000ticks = 120s ��Һ��=13ml
  valve     = {7, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 10000000}
  },
--0x02
  {
  ticks     = 12000,           -- 12000ticks = 60s
  valve     = {5, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03
  {
  ticks     = 6000,           -- 6000ticks = 30s  3��8��13��·
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 100000}
  },
--0x04 ��V6�Ŷ�
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
--0x05 ��V6�Ŷ�
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {5, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x06 ��V6��ϴ
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {5, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 ��ϴ8��9��·
  {
  ticks     = 3000,           -- 3000ticks = 15s
  valve     = {7, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x08 ��ϴ8��3��13��·
  {
  ticks     =3000,           -- 3000ticks = 15s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 100000}
  },
--0x09 ��ϴpressure2��·
  {
  ticks     = 3000,           -- 3000ticks = 15s
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
--0x0a
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0b ע��������,����NovoRinse
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 20.0}
  },
--0x0c ע��������
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*150.0, rounds = 20.0}
  },
--0x0d ��V4�Ŷ�
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0e ��V4�Ŷ�
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0f ��V4�Ŷ�
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x10 ע��������,��������,�����Ŷ�
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x11 ע��������,��V9
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*150.0, rounds = 20.0}
  },
--0x12 ע��������,��V3��13
  {
  ticks     = 1700,           -- 2000ticks = 10s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*150.0, rounds = 20.0}
  },
--0x13 ������Һ��,��עע����
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
--0x14 ע��������,��עע����
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*150.0, rounds = 20.0}
  },
--0x15 ע��������,��עע����
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 20.0}
  },
--0x16 ��V4�Ŷ�
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x17 ��V4�Ŷ�
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x18 ��V4�Ŷ�
  {
  ticks     = 12000,           -- 12000ticks = 60s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x19 ������Һ��
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {7, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1a
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {5, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1b
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 100000}
  },
--0x1c ��V6�Ŷ�
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1d ��ϴpressure2��·
  {
  ticks     = 3000,           -- 3000ticks = 15s
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1e �ͷ�ѹ��
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1f ����
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DeconStep5_1 = {
  name = "IDX-DeconStep5_1",
  0x01, 0x02, 0x1E, 0x03,                                        -- ��ϴ��Һ��·

  0x04, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x07, 0x1E, 0x08,
  0x04, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x07, 0x1E, 0x08,
  0x09,
  -- ѭ��1-1
  0x0A,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  -- ѭ��2-1
  0x10, 0x11, 0x10, 0x11, 0x10, 0x11,                             -- �ſչ�עע����
  0x10, 0x12, 0x10, 0x13, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17, 0x16, 0x17, 0x16, 0x17, 0x16, 0x17, 0x16, 0x18, 0x1D,
  0x10, 0x11, 0x10, 0x11, 0x10, 0x11,
  0x10, 0x12, 0x10, 0x13, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17, 0x16, 0x17, 0x16, 0x17, 0x16, 0x17, 0x16, 0x18, 0x1D,
  0x10, 0x11, 0x10, 0x11, 0x10, 0x11,
  0x10, 0x12, 0x10, 0x13, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17, 0x16, 0x17, 0x16, 0x17, 0x16, 0x17, 0x16, 0x18, 0x1D,
  0x10, 0x11, 0x10, 0x11, 0x10, 0x11,
  0x10, 0x12, 0x10, 0x13, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17, 0x16, 0x17, 0x16, 0x17, 0x16, 0x17, 0x16, 0x18, 0x1D,
  -- ѭ��3-1
  0x06, 0x19, 0x1E, 0x1B, 0x04,
  0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x19, 0x1E, 0x1B, 0x04,
  0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x19, 0x1E, 0x1B, 0x09,

  0x1E, 0x1F                                 -- �ͷ�ѹ��
}

-- Decontamination step 9: dummy
local TIMING_SUB_DeconStep9 = {
  name = "SUB-DeconStep9",
--0x01
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- Pressure Target Calibration: Ŀ��ѹ��У׼
local TIMING_SUB_PTCalibration = {
  name = "SUB-PTCalibration",
--0x01 V6��V9����,������Һ��
  {
  ticks     = 3000,           -- 3000ticks = 15s
  valve     = {6, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*config.pmotor.omega, rounds = 1000000.0}
  },
--0x02 ��ʼУ׼Ŀ��ѹ��ֵ
  {
  beginhook = function (self, item)
    subwork:pidcontrol(TimingConst.PTC_Start)
  end,
  ticks     = 3000,             -- 3000ticks = 15s
  valve     = {6, 9}
  },
--0x03 Ŀ��ѹ��ֵУ׼����
  {
  beginhook = function (self, item)
    subwork:pidcontrol(TimingConst.PTC_Stop)
  end,
  ticks     = 200,              -- 200ticks = 1s
  valve     = {6, 9}
  },
--0x04 ��Һ��ֹͣ,�����е�ŷ��ϵ縴λ
  {
  ticks     = 100,              -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- ��������
local TIMING_SUB_SleepEnter = {
  name = "SUB-SleepEnter",
--0x01 V6��V9����,������Һ��
  {
  ticks     = 5000,             -- 5000ticks = 25s
  valve     = {6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*config.pmotor.omega, rounds = 1000000.0}
  },
--0x02 ֹͣ��Һ��
  {
  ticks     = 20,               -- 20ticks = 0.1s
  valve     = {6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 ��Һ�ø�λ,�ͷ�ѹ��
  {
  ticks     = 1200,             -- 1200ticks = 6s
  valve     = {6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x04 ѹ���ͷŽ���,�����е�ŷ��ϵ縴λ
  {
  ticks     = 100               -- 100ticks = 0.5s
  }
}

-- �˳�����
local TIMING_SUB_SleepExit = {
  name = "SUB-SleepExit",
--0x01 V6��V9����,������Һ��
  {
  ticks     = 3000,             -- 3000ticks = 15s
  valve     = {6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*config.pmotor.omega, rounds = 1000000.0}
  },
--0x02 ֹͣ��Һ��
  {
  ticks     = 100,              -- 100ticks = 0.5s
  valve     = {6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 �����е�ŷ��ϵ縴λ
  {
  ticks     = 100,              -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}
-------------------------------------------------------------------------
-- �������ģ��
-------------------------------------------------------------------------
-- ѹ�����޺��ѹ���ͷ�
local TIMING_SUB_PRelease = {
  name = "SUB-PRelease",
-- 0x01 ��λ
  {
  ticks     = 1200,   -- 1200ticks = 6s  ��֤ע��������ײ�Ҳ�ܸ�λ
  valve     = {3, 4, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*225.0, rounds = 22.0},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x02 ��ŷ���,�ͷ�ѹ��
  {
  ticks     = 1000,   -- 1000ticks = 5s
  valve     = {2, 3, 4, 6, 9, 13}
  }
}

-- V8>V3,������ӹ�·
local TIMING_SUB_DiagnosticateStep1 = {
  name = "SUB-DiagnosticateStep1",
--0x01 ��������������Һ��
  {
  ticks     = 4000,             -- 4000ticks = 20s
  valve     = {3, 8, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 1000000.0}
  },
--0x02 �ɼ�10sѹ��
  {
  ticks     = 2000,              -- 2000ticks = 10s
  valve     = {3, 8, 13}
  },
--0x03 �����е�ŷ��ϵ縴λ
  {
  ticks     = 100,              -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- V8>V9,���flowcell����Һ��·
local TIMING_SUB_DiagnosticateStep2 = {
  name = "SUB-DiagnosticateStep2",
--0x01 ��������������Һ��
  {
  ticks     = 4000,             -- 4000ticks = 20s
  valve     = {8, 9},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 1000000.0}
  },
--0x02 �ɼ�10sѹ��
  {
  ticks     = 2000,              -- 2000ticks = 10s
  valve     = {8, 9}
  },
--0x03 �����е�ŷ��ϵ縴λ
  {
  ticks     = 100,              -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- V6>V3, �����Һ���͹�·
local TIMING_SUB_DiagnosticateStep3 = {
  name = "SUB-DiagnosticateStep3",
--0x01 ��������������Һ��
  {
  ticks     = 4000,             -- 4000ticks = 20s
  valve     = {3, 6, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 1000000.0}
  },
--0x02 �ɼ�10sѹ��
  {
  ticks     = 2000,              -- 2000ticks = 10s
  valve     = {3, 6, 13}
  },
--0x03 �����е�ŷ��ϵ縴λ
  {
  ticks     = 100,              -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- V4>V9, ������������뼰��·
local TIMING_SUB_DiagnosticateStep4 = {
  name = "SUB-DiagnosticateStep4",
--0x01 ��������������Һ��
  {
  ticks     = 4000,             -- 4000ticks = 20s
  valve     = {4, 9},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 1000000.0}
  },
--0x02 �ɼ�10sѹ��
  {
  ticks     = 2000,              -- 2000ticks = 10s
  valve     = {4, 9}
  },
--0x03 �����е�ŷ��ϵ縴λ
  {
  ticks     = 100,              -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- V4>V2, ������������뼰��·
local TIMING_SUB_DiagnosticateStep5 = {
  name = "SUB-DiagnosticateStep5",
-- 0x01 ��������������Һ��
  {
  ticks     = 4000,             -- 4000ticks = 20s
  valve     = {4, 2, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 1000000.0}
  },
-- 0x02 �ɼ�10sѹ��
  {
  ticks     = 2000,              -- 2000ticks = 10s
  valve     = {4, 2, 13}
  },
-- 0x03 �����е�ŷ��ϵ縴λ
  {
  ticks     = 100,              -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-------------------------------------------------------------------------
-- GRP-Timing definition
-------------------------------------------------------------------------
local TIMING_GRP_StartUp = {
  name = "StartUp",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_Debubble,           idx = TIMING_IDX_Debubble         },
  {sub = TIMING_SUB_WashAwayNR,         idx = TIMING_IDX_WashAwayNR       },
  {sub = TIMING_SUB_Rinse,              idx = TIMING_IDX_RinseNR          },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_AbsSampleAcquisition = {
  name = "MeasureAbs",
  {sub = TIMING_SUB_AbsSampleAcquisition,        idx = nil                }
}

local TIMING_GRP_NoAbsSampleAcquisition = {
  name = "MeasureNoAbs",
  {sub = TIMING_SUB_NoAbsSampleAcquisition,     idx = nil                 }
}

local TIMING_GRP_AdjustNormal = {
  name = "AdjustNormal",
  {sub = TIMING_SUB_AdjustNormal,       idx = nil                         }
}

local TIMING_GRP_TestCleanNone = {
  name = "TestCleanNone",
  {sub = TIMING_SUB_TestCleanNone,      idx = nil                         }
}

local TIMING_GRP_TestCleanFirst = {
  name = "TestCleanFirst",
  {sub = TIMING_SUB_TestCleanFirst,     idx = nil                         }
}

local TIMING_GRP_TestCleanOthers = {
  name = "TestCleanOthers",
  {sub = TIMING_SUB_TestCleanOthers,    idx = nil                         }
}

local TIMING_GRP_Shutdown = {
  name = "Shutdown",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_NovoCleanCleaning,  idx = TIMING_IDX_NovoCleanCleaning},
  {sub = TIMING_SUB_Soak,               idx = TIMING_IDX_Soak             },
  {sub = TIMING_SUB_Rinse,              idx = TIMING_IDX_RinseNC          },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_SIPSoak = {
  name = "SIPSoak",
  {sub = TIMING_SUB_SIPSoak,            idx = nil                         }
}

local TIMING_GRP_SIPGoHome = {
  name = "SIPGoHome",
  {sub = TIMING_SUB_SIPGoHome,          idx = nil                         }
}

local TIMING_GRP_Debubble = {
  name = "Debubble",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_Debubble,           idx = TIMING_IDX_Debubble         },
  {sub = TIMING_SUB_WashAwayNR,         idx = TIMING_IDX_WashAwayNR       },
  {sub = TIMING_SUB_Rinse,              idx = TIMING_IDX_RinseNR          },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_Cleaning = {
  name = "Cleaning",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_NovoCleanCleaning,  idx = TIMING_IDX_NovoCleanCleaning},
  {sub = TIMING_SUB_Soak,               idx = TIMING_IDX_Soak             },
  {sub = TIMING_SUB_Rinse,              idx = TIMING_IDX_RinseNC          },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_Priming = {
  name = "Priming",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_Priming,            idx = TIMING_IDX_Priming          },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_Unclog = {
  name = "Unclog",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_NovoCleanCleaning,  idx = TIMING_IDX_NovoCleanCleaning},
  {sub = TIMING_SUB_Soak,               idx = TIMING_IDX_Soak             },
  {sub = TIMING_SUB_Rinse,              idx = TIMING_IDX_RinseNC          },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_InitPriming = {
  name = "InitPriming",
  {sub = TIMING_SUB_InitPrimingStep1,   idx = TIMING_IDX_InitPrimingStep1,  ishand = true}
}

local TIMING_GRP_Drain = {
  name = "Drain",
  {sub = TIMING_SUB_DrainStep1,         idx = TIMING_IDX_DrainStep1,        ishand = true},
  {sub = TIMING_SUB_DrainStep2,         idx = TIMING_IDX_DrainStep2,        ishand = true}
}

local TIMING_GRP_PTCalibration = {
  name = "PTCalibration",
  {sub = TIMING_SUB_PTCalibration,      idx = nil}
}

local TIMING_GRP_SleepEnter = {
  name = "SleepEnter",
  {sub = TIMING_SUB_SleepEnter,         idx = nil}
}

local TIMING_GRP_SleepExit = {
  name = "SleepExit",
  {sub = TIMING_SUB_SleepExit,          idx = nil},
  {sub = TIMING_SUB_PTCalibration,      idx = nil},
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil}
}

local TIMING_GRP_MotorsGoHome = {
  name = "MotorsGoHome",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil},
}

local TIMING_GRP_SIPCollisionResume = {
  name = "SIPCollisionResume",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil},
  {sub = TIMING_SUB_Rinse,              idx = TIMING_IDX_Rinse},
  {sub = TIMING_SUB_PTCalibration,      idx = nil},
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil}
}

local TIMING_GRP_PResume = {
  name = "PResume",
  {sub = TIMING_SUB_PRelease,           idx = nil},
  {sub = TIMING_SUB_PRecheck,           idx = nil},
}

local TIMING_GRP_PExtResume = {
  name = "PExtResume",
  {sub = TIMING_SUB_DiagnosticateStep1,         idx = nil},
  {sub = TIMING_SUB_DiagnosticateStep2,         idx = nil},
  {sub = TIMING_SUB_PTCalibration,          idx = nil},
  {sub = TIMING_SUB_MotorsGoHome,           idx = nil}
}

local TIMING_GRP_ERdiagnosticate = {
  name = "ERdiagnosticate",
  {sub = TIMING_SUB_DiagnosticateStep1,         idx = nil},
  {sub = TIMING_SUB_DiagnosticateStep2,         idx = nil},
  {sub = TIMING_SUB_DiagnosticateStep3,         idx = nil},
  {sub = TIMING_SUB_DiagnosticateStep4,         idx = nil},
  {sub = TIMING_SUB_DiagnosticateStep5,         idx = nil},
  {sub = TIMING_SUB_MotorsGoHome,               idx = nil}
}

local TIMING_GRP_SIPAbnormalResume = {
  name = "SIPAbnormalResume",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil},
  {sub = TIMING_SUB_Rinse,              idx = TIMING_IDX_Rinse},
  {sub = TIMING_SUB_PTCalibration,      idx = nil},
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil}
}

local TIMING_GRP_Decontamination = {
  name = "Decontamination",
  {sub = TIMING_SUB_SIPSoak,            idx = nil,                      ishand = true},
  {sub = TIMING_SUB_SIPGoHome,          idx = nil,                      ishand = true},
  {sub = TIMING_SUB_DeconStep1,         idx = TIMING_IDX_DeconStep1,    ishand = true},
  {sub = TIMING_SUB_DeconStep2,         idx = TIMING_IDX_DeconStep2,    ishand = true}
}


-------------------------------------------------------------------------
-- Timing Export
-------------------------------------------------------------------------
timing = const.newConst {
  version               = TIMING_VERSION,
  allstop               = TIMING_AllStop,
  startup               = TIMING_GRP_StartUp,
  measure_abs           = TIMING_GRP_AbsSampleAcquisition,
  measure_noabs         = TIMING_GRP_NoAbsSampleAcquisition,
  adjust_normal         = TIMING_GRP_AdjustNormal,
  test_clean_none       = TIMING_GRP_TestCleanNone,
  test_clean_first      = TIMING_GRP_TestCleanFirst,
  test_clean_others     = TIMING_GRP_TestCleanOthers,
  shutdown              = TIMING_GRP_Shutdown,
  maintain_debubble     = TIMING_GRP_Debubble,
  maintain_cleaning     = TIMING_GRP_Cleaning,
  maintain_priming      = TIMING_GRP_Priming,
  maintain_unclog       = TIMING_GRP_Unclog,
  initpriming           = TIMING_GRP_InitPriming,
  drain                 = TIMING_GRP_Drain,
  ptcali                = TIMING_GRP_PTCalibration,
  sleep_enter           = TIMING_GRP_SleepEnter,
  sleep_exit            = TIMING_GRP_SleepExit,
  motorgohome           = TIMING_GRP_MotorsGoHome,
  resume_sipcollision   = TIMING_GRP_SIPCollisionResume,
  resume_pressure       = TIMING_GRP_PResume,
  resume_pressureext    = TIMING_GRP_PExtResume,
  resume_sipabnormal    = TIMING_GRP_SIPAbnormalResume,
  error_diagnosticate   = TIMING_GRP_ERdiagnosticate,
  decontamination       = TIMING_GRP_Decontamination
}

return timing

--******************************************************************************
-- No More!
--******************************************************************************