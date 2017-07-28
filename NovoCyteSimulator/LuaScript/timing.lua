#!/usr/local/bin/lua
--******************************************************************************
-- timing.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

require "LuaScript\\TimingConst"

local TIMING_VERSION="V5.0"

--[[
def_motor = function {opt, dir, acc, omega, rounds}
  local motor_param = {}
  motor_param.opt
end
--]]
--[[
Motor direction
  S-Motor:   +:Up,     -:Down
  I-Motor:   +:Pull,   -:Push
  P-Motor:   +:CCW,    -:CW
--]]

local UP   =  1
local DN   = -1
local PULL =  1
local PUSH = -1
local CCW  =  1
local CW   = -1

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
  --opt    = nil,
  --state  = nil,
  ticks     = 100,
  --valve  = nil,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- ѹ�����޺��ѹ���ͷ�
local TIMING_SUB_PRelease = {
  name = "SUB-PRelease",
-- 0x01 ��λ
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 1200,   -- 1200ticks = 6s  ��֤ע��������ײ�Ҳ�ܸ�λ
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -225.0, rounds = 22.0},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x02 ��ŷ���,�ͷ�ѹ��
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 3000,   -- 3000ticks = 15s
  valve     = {3, 5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- ����ѹ�����
local TIMING_SUB_PRecheck = {
  name = "SUB-PRecheck",
-- 0X01 �ͷ�ѹ������,���ѹ���Ƿ���Ȼ����200kPa
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 2000,   -- 2000ticks = 10s ÿ��ͨ�����2s
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
  --opt    = nil,
  --state  = nil,
  ticks     = 1200,   -- 1200ticks = 6s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RESET},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 420.0, rounds = 35.0}
  },
-- 0x02
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 1400,   -- 1400ticks = 7s
  valve     = {3, 5, 7, 8, 12},
--smotor    = {op = TimingConst.MOTOR_KEEP},
--imotor    = {op = TimingConst.MOTOR_KEEP},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0X03
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 100,   -- 100ticks = 0.5s
  --valve  = nil,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- ��������
local TIMING_SUB_Soak = {
  name = "SUB-Soak",
-- 0x01 ����2min
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 24000,  -- 24000ticks = 120s
  valve     = {8},
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
  --opt    = nil,
  --state  = nil,
  ticks     = 400,  -- 400ticks = 2s
  --valve  = nil,
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 2.0},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- �����������Ϻ�ĸ�λ
local TIMING_SUB_SIPGoHome = {
  name = "SUB-SIPGoHome",
-- 0x01 ���������븴λ
  {
  --opt    = nil,
  --state  = nil,
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
-- 0x01 ������Һ��
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
-- 0x02 �ر�V4�����Ŷ�
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 20,
  valve     = {8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
--pmotor    = {op = TimingConst.MOTOR_KEEP}
  },
-- 0x03 ��V4�����Ŷ�
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
--pmotor    = {op = TimingConst.MOTOR_KEEP}
  },
-- 0x04 ע��������,�Ŷ����ڲ�����������NovoRinse
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 500,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 5.0}
--pmotor    = {op = TimingConst.MOTOR_KEEP}
  },
-- 0x05 ע��������,�Ŷ����ڲ�����������NovoRinse
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 500,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
-- 0x06 ע������ֹ,��Һ�ñ���
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 400,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x07 ����Һ��·����Һ��ϴchamber(��V9����Һ)
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x08 V6�ر��Ŷ�
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 20,
  valve     = {8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x09 V6���Ŷ�
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0a �ͷ�chamberѹ��,��ǰ�򿪷�Һ��,��������������,ʹV3����Һ���ܵ�����,ͬʱ�ͷ�������·ѹ��
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 1200,
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0b ����Һ��·����Һ��ϴchamber(��V3����Һ)
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 500,
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
-- 0x0c ����Һ��·����Һ��ϴchamber(��V3����Һ),��������������,���ɱ���
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 100,
  valve     = {2, 5, 12},
  smotor    = SIP_Reset,
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0d ����Һ��·����Һ��ϴchamber(��V3����Һ),��������������,����V3�رս���ˮ��
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 1000,
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0e ��������������
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {5, 8, 12},
  smotor    = SIP_Reset,
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0f V2��ǰ��
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x10 ��������·����Һ��ϴ����������&�����������ڱ�
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 1000,
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
-- 0x11 ��V4�����Ŷ�
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x12 ֹͣ��Һ��
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x13 �ر�V2,�ͷ�ѹ��
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 100,
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x14 ����
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 100,
  --valve  = nil,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_Priming = {
  name = "IDX-Priming",
  0x01, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02,
  0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02,   -- V4�����Ŷ�

  0x04, 0x05, 0x06, 0x04, 0x05, 0x06, 0x04, 0x05, 0x06,
  0x04, 0x05, 0x06, 0x04, 0x05, 0x06, 0x04, 0x05,               -- ע��������

  0x07, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, -- V6�����Ŷ�
  0x0a, 0x0b, 0x0c, 0x0d, 0x0c, 0x0d, 0x0e, 0x0f,               -- ��chamber��ڳ���Һ,����ϴchamber�ڲ�
  0x10,                                                         -- ��ϴ���������ڱ�

  0x11, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02,
  0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02,
  0x04, 0x05, 0x06, 0x04, 0x05, 0x06, 0x04,
  0x05, 0x06, 0x04, 0x05, 0x06, 0x04, 0x05,
  0x07, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08,
  0x0a, 0x0b, 0x0c, 0x0d, 0x0c, 0x0d, 0x0e, 0x0f,
  0x10,

  0x12, 0x13, 0x14                                              -- �ͷ�ѹ��
}

-- ��Һ��ϴ����
local TIMING_SUB_SheathCleaning = {
  name = "SUB-SheathCleaning",
-- 0x01 ��ϴ����������·
  {
  ticks     = 6000,
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
-- 0x02 ע��������,�Ŷ����ڲ�����������NovoRinse&NovoClean
  {
  ticks     = 220,
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 2.5}
  },
-- 0x03 ע��������,�Ŷ����ڲ�����������NovoRinse&NovoClean
  {
  ticks     = 520,
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 60.0, rounds = 2.5}
  },
-- 0x04 �ر�V2�����Ŷ�
  {
  ticks     = 200,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x05 ��V2�����Ŷ�
  {
  ticks     = 20,
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x06 ��������·����Һ��ϴ�����������ڱ�
  {
  ticks     = 1600,
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
-- 0x07 �ر�V2,ת�����
  {
  ticks     = 100,
  valve     = {3, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x08 ����Һ��·����Һ��ϴchamber(��V9����Һ)
  {
  ticks     = 6000,
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x09 ������ˮ��ϴchamber(��V9����Һ)
  {
  ticks     = 6000,
  valve     = {5, 7, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0a ����������,ע��������,����chamber�ڲ�ѹ��,Һ���л���������·
  {
  ticks     = 620,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 7.5}
  },
-- 0x0b ��������·��ϴchamber(��V3����Һ),��������������,ͬʱ�Ŷ������ڲ�����Һ��
  {
  ticks     = 200,
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x0c ��������������,ͬʱ�Ŷ������ڲ�����Һ��
  {
  ticks     = 1000,
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4}
  },
-- 0x0d ����Һ��·����Һ��ϴchamber(��V3����Һ),��������������,���ɱ���
  {
  ticks     = 200,
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0e ��������������,ͬʱ�Ŷ������ڲ�����Һ��
  {
  ticks     = 1000,
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0f V3�ر�,�����븴λ
  {
  ticks     = 100,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x10 ����
  {
  ticks     = 100,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_SheathCleaning = {
  name = "IDX-SheathCleaning",
  0x01,

  0x02, 0x03, 0x02, 0x03, 0x02, 0x03,                           -- ע��������
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,   -- v2�����Ŷ�
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x06, 0x07,                   -- ��ϴ����������&���ڱ�
  0x08,                         -- ����Һ��·��ϴchamber(��v9����Һ)
  0x09,                         -- ������ˮ��ϴchamber(��v9����Һ)
  0x0a,                         -- ����������,ע��������,����chamber�ڲ�ѹ��,Һ���л���������·
  0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c,   -- ��������·��ϴchamber(��v3����Һ)
  0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e,   -- ����Һ��·��ϴchamber(��v3����Һ)
  0x0f,                         -- ���������븴λ

  0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x06, 0x07,
  0x08,
  0x09,
  0x0a,
  0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c,
  0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e,
  0x0f,

  0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x06, 0x07,
  0x08,
  0x09,
  0x0a,
  0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c,
  0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e,
  0x0f,

  0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x06, 0x07,
  0x08,
  0x09,
  0x0a,
  0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c,
  0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e,
  0x0f,

  0x0f
}

-- ��ϴ����
local TIMING_SUB_Rinse = {
  name = "SUB-Rinse",
-- 0x01 ע������������ϴ����������
  {
  ticks     = 500,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
-- 0x02 ע�������ơ���ϴ����������
  {
  ticks     = 500,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
-- 0x03 ��ϴ����������
  {
  ticks     = 400,
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x04 ע������������ϴ����������
  {
  ticks     = 500,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x05 ��ֹͣ,�ͷ�ѹ��
  {
  ticks     = 100,
  valve     = {3, 8, 12},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x06
  {
  ticks     = 100,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_Rinse = {
  name = "IDX-Rinse",
  0x01, 0x02, 0x03, 0x04, 0x02, 0x03,
  0x04, 0x02, 0x03, 0x04, 0x02, 0x03,
  0x05, 0x06
}

-- NovoRinse��ϴ����
local TIMING_SUB_NovoRinseCleaning = {
  name = "SUB-NovoRinseCleaning",
-- 0x01 ��Һ�ý�NovoRinse�˵�Flow chamber,��NovoRinse��flowcell������ϴ
  {
  ticks     = 6000,
  valve     = {7, 8, 9},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 635.0, rounds = 100000}
  },
-- 0x02 ��ע������NovoRinse�������ü�����������·
  {
  ticks     = 1000,
  valve     = {7, 8, 9, 12},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -100.0, rounds = 7.8} --NovoRinse��NovoFlow֮��Ľ����ע����150mm
  },
-- 0x03 ��NovoRinse��������������·
  {
  ticks     = 400,
  valve     = {1, 7, 8, 9, 12},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -65.0, rounds = 1.6}
  },
-- 0x04 ������ֹͣ,�����Ŷ�,���������������ǻ���ܲ���������
  {
  ticks     = 200,
  valve     = {7, 8, 9},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x05 ����������,�����Ŷ�,���������������ǻ���ܲ���������
  {
  ticks     = 200,
  valve     = {7, 8, 9},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 300.0, rounds = 100000}
  },
-- 0x06 ����
  {
  ticks     = 100,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_NovoRinseCleaning = {
  name = "IDX-NovoRinseCleaning",
  0x01, 0x02, 0x03,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x06
}

-- ��ϴV8-V10֮��NovoRinse,ͬʱ����Flowcell��������·
local TIMING_SUB_WashAwayNR = {
  name = "SUB-WashAwayNR",
-- 0x01 ������Һ��,�����͹�·�е�NovoRinse�Ƶ�chamber����Һ��·
  {
  ticks     = 3400,                   -- 3400ticks = 17s 3s�ͷ�chamberѹ��
  valve     = {7, 8},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 170.0}
  },
-- 0x02 ��NovoFlow��ϴ��Һ�ü����͹�·
  {
  ticks     = 1000,                   -- 1000ticks = 5s
  valve     = {2, 7, 12},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000}
  },
-- 0x03 ��������������
  {
  ticks     = 200,                    -- 200ticks = 1s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x04 ��������������
  {
  ticks     = 1000,                   -- 1000ticks = 5s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4}
  },
-- 0x05 ��������������
  {
  ticks     = 1000,                   -- 1000ticks = 5s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.15}
  },
-- 0x06 ע������λ,��ϴchamber��ǻ��Flowcell
  {
  ticks     = 2000,                   -- 2000ticks = 10s
  valve     = {7, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x07 ����
  {
  ticks     = 10,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_WashAwayNR = {
  name = "IDX-WashAwayNR",
  0x01,                               -- �����͹�·�е�NovoRinse�Ƶ�chamber����Һ��·
  0x02, 0x03, 0x04, 0x03, 0x05, 0x03, 0x04, 0x03, 0x05, 0x03,
  0x04, 0x03, 0x05, 0x03, 0x04, 0x03, 0x05, 0x03, 0x04,
                                      -- ��NovoFlow��ϴV8��V10֮��NovoRinse
  0x06,                               -- ע������λ,��ϴchamber��ǻ��Flowcell

  0x07                                -- ����
}

-- ���ڹ�ע��NovoRinse��ϴ����
local TIMING_SUB_NovoRinse4Priming = {
  name = "SUB-NovoRinse4Priming",
-- 0x01 ��עfilter5
  {
  ticks     = 6000,         -- 6000ticks = 30s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
-- 0x02 V6�ر��Ŷ�
  {
  ticks     = 20,           -- 20ticks = 0.1s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x03 V6���Ŷ�
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x04 ��עV4��·,ע�����������ײ�
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
-- 0x05 V4�ر��Ŷ�
  {
  ticks     = 20,           -- 20ticks = 0.1s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x06 ����Һ��עע����ǰ��Ĺ�·,�����ݴ���ע����,V4���Ŷ�,ע���������Ŷ��ײ�����
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 2.0}
  },
-- 0x07 ����Һ��עע����ǰ��Ĺ�·,�����ݴ���ע����,V4���Ŷ�,ע���������Ŷ��ײ�����
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 2.0}
  },
-- 0x08 ��Һ�ý�NovoRinse�˵�Flow chamber,ע������λ
  {
  ticks     = 6000,         -- 6000ticks = 30s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x09 ע������NovoRinse��������������·(v2-chamber)������������·(V2-V1)һֱ����ע������
  {
  ticks     = 1700,         -- 1700ticks = 8.5s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 2.0}
  },
-- 0x0a ע������NovoRinse����flowcell
  {
  ticks     = 600,          -- 600ticks = 3s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -100.0, rounds = 20.0}
  },
-- 0x0b ������ֹͣ,�����Ŷ�,���������������ǻ���ܲ���������
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0c ����������,�����Ŷ�,���������������ǻ���ܲ���������
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
-- 0x0d ע�����ڵײ������Ŷ�
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 4.5},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
-- 0x0e ע�����ڵײ������Ŷ�
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 4.5},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x0f ע���������ݴ�flowchamber����
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
-- 0x10 ��Һ������
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x11 v9�ر��Ŷ�
  {
  ticks     = 20,           -- 20ticks = 0.1s
  valve     = {7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x12 v9���Ŷ�
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x13 ����
  {
  ticks     = 100,          -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_NovoRinse4Priming = {
  name = "IDX-NovoRinse4Priming",
  0x01,                                   -- ��עfilter5
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x02, 0x03, 0x02, 0x03,                 -- V6�����Ŷ�

  0x04,                                   -- ע���������ײ�, ��עV4��·
  0x05, 0x06, 0x05, 0x07, 0x05, 0x06, 0x05, 0x07, 0x05, 0x06, 0x05, 0x07,
  0x05, 0x06, 0x05, 0x07, 0x05, 0x06, 0x05, 0x07, 0x05, 0x06, 0x05, 0x07,
                                          -- V4�����Ŷ�, ע�������������Ŷ�

  0x08,                                   -- ��Һ�ý�NovoRinse�˵�Flow chamber
  0x09,                                   -- ��NovoRinse����ע������ǻ
  0x0a,                                   -- ע������NovoRinse��������������·
  0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c,     -- ����������ֹͣ�Ŷ���ǻ����������
  0x09,
  0x0a,
  0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c,
  0x09,
  0x0a,
  0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c,
  0x09,

  0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e,
  0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e,
                                          -- ע���������ڵײ������Ŷ�
  0x0f, 0x10,                             -- ע���������ݴ�flowchamber����
  0x11, 0x12, 0x11, 0x12, 0x11, 0x12, 0x11, 0x12, 0x11, 0x12,
  0x11, 0x12, 0x11, 0x12, 0x11, 0x12, 0x11, 0x12, 0x11, 0x12,
                                          -- V9�����Ŷ�flowchamber�ڵ�����
  0x13                                    -- ����
}

-- NovoClean��ϴ����
local TIMING_SUB_NovoCleanCleaning = {
  name = "SUB-NovoCleanCleaning",
--0x01 ��Һ�ý�NovoClean�˵�Flow chamber,��NovoClean��flowcell������ϴ
  {
  ticks     = 6000,         -- 6000ticks = 30s
  valve     = {7, 8, 9, 10},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x02 ����������,��ֹNovoClean��ɢ��ע������ǻ
  {
  ticks     = 800,          -- 800ticks = 4s
  valve     = {1, 7, 8, 9, 10, 12},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 40.0, rounds = 2.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 250.0}
  },
--0x03 �����������������������·
  {
  ticks     = 600,          -- 600ticks = 3s
  valve     = {7, 8, 9, 10},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -55.0, rounds = 2.0}
  },
--0x04 ��ע������NovoClean���빫��������·
  {
  ticks     = 2400,         -- 2400ticks = 12s
  valve     = {7, 8, 9, 10},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 40.0, rounds = 6.5}   -- ���������ע����100mm
  },
--0x05 ��NovoClean��������������·
  {
  ticks     = 1000,         -- 1000ticks = 5s �ȴ���������ָ�����
  valve     = {1, 7, 8, 9, 10},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -50.0, rounds = 2.0},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x06 ����
  {
  ticks     = 100,          -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_NovoCleanCleaning = {
  name = "IDX-NovoCleanCleaning",
  0x01, 0x02, 0x03, 0x04, 0x05, 0x06
}

-- ��ϴV8-V10֮��NovoClean,ͬʱ����Flowcell��������·
local TIMING_SUB_WashAwayNC = {
  name = "SUB-WashAwayNC",
--0x01 ������Һ��,��NovoRinse���V10-V11֮���·
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {7, 8, 9},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 135.0}
  },
--0x02 ��NovoFlow��NovoClean�����͹�·�Ƶ�chamber����Һ��·
  {
  ticks     = 1600,         -- 1600ticks = 8s
  valve     = {7, 8},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4}
  },
--0x03 ��NovoFlow��ϴ����·�е�NovoClean&NovoRinse
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {2, 7, 12},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000}
  },
--0x04 ��������������,��NovoFlow��ϴ����·�е�NovoRinse
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 ��������������,���̽������
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4}
  },
--0x06 ��������������,���ͣ��������
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.15}
  },
--0x07 ��NovoClean�Ƶ�V9���ҺͰ֮��
  {
  ticks     = 5000,         -- 5000ticks = 25s
  valve     = {7, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x08 �ͷ�chamberѹ��
  {
  ticks     = 600,          -- 600ticks = 3s
  valve     = {7, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 ע������λ,��ϴchamber��ǻ��Flowcell
  {
  ticks     = 3000,         -- 3000ticks = 15s
  valve     = {7, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x0a ����
  {
  ticks     = 10,           -- 10ticks = 50ms
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_WashAwayNC = {
  name = "IDX-WashAwayNC",
  0x01,             -- ��NovoRinse��ϴV10��V11֮���·
  0x02,             -- ��NovoFlow��NovoClean�����͹�·�Ƶ�chamber����Һ��·
  0x03,
  0x04, 0x05, 0x04, 0x06, 0x04, 0x05, 0x04, 0x06, 0x04, 0x05,
  0x04, 0x06, 0x04, 0x05, 0x04, 0x06, 0x04, 0x05, 0x04, 0x06,
  0x04, 0x05, 0x04, 0x06, 0x04, 0x05, 0x04, 0x06, 0x04, 0x05,
                    -- ��NovoFlow��ϴ����·�е�NovoClean&NovoRinse
  0x07, 0x08,       -- ��NovoClean�Ƶ�V9���ҺͰ֮��
  0x03, 0x04, 0x06, 0x04, 0x05, 0x04, 0x06,
                    -- ��NovoFlow��ϴ����·�е�NovoClean&NovoRinse

  0x09,             -- ע������λ,��NovoFlow��ϴFlowchamber

  0x0a              -- ����
}

-- ����
local TIMING_SUB_Backflush = {
  name = "SUB-Backflush",
--0x01 ������Һ��,�򿪵�ŷ�
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x02 ע������������,Ϊ�����������뷴��Һ����׼��
  {
  ticks     = 500,          -- 500ticks = 2.5s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 5.0}
  },
--0x03 ����Һ�����͵�Һ���л�����Һ��·
  {
  ticks     = 100,          -- 100ticks = 0.5s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 ��ע������ϴ����������·
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {1, 5, 8, 12},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -65.0, rounds = 5.0}
  },
--0x05 ����Һ�����͵�Һ���л���������·
  {
  ticks     = 100,          -- 100ticks = 0.5s
  valve     = {3, 8, 12},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x06 ��ϴflowcell
  {
  ticks     = 3000,         -- 3000ticks = 15s
  valve     = {5, 8, 12},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 ��V3֮ǰ,�ͷ�ѹ��
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x08 ��ϴ�������������
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {2, 5, 12},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x09 ��ֹͣ,�ͷ�ѹ��
  {
  ticks     = 600,          -- 600ticks = 3s
  valve     = {2, 3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0a ��ŷ��ر�
  {
  ticks     = 100,          -- 100ticks = 0.5s
  valve     = {12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0b ����
  {
  ticks     = 100,          -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_Backflush = {
  name = "IDX-Backflush",
  0x01, 0x02, 0x03, 0x04,
  --------------------
  0x05, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,
  --------------------
  0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B
}

-- ������
local TIMING_SUB_Debubble = {
  name = "SUB-Debubble",
--0x01 ������Һ��&��ŷ�
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x02 ��������������
  {
  ticks     = 260,          -- 260ticks = 1.3s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0},  -- auto rounds
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 ����75%�ƾ�
  {
  ticks     = 560,          -- 560ticks = 2.8s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 50.0, rounds = 2.0}
  },
--0x04 V2�ر�
  {
  ticks     = 20,           -- 20ticks = 0.1s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x05 ���ƾ�����flow cell
  {
  ticks     = 560,          -- 560ticks = 2.8s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -50.0, rounds = 2.0}
  },
--0x06 ����75%�ƾ�
  {
  ticks     = 560,          -- 560ticks = 2.8s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 50.0, rounds = 2.0}
  },
--0x07 V2�ر�
  {
  ticks     = 20,           -- 20ticks = 0.1s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x08 ���ƾ�����flow cell
  {
  ticks     = 560,          -- 560ticks = 2.8s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -50.0, rounds = 2.0}
  },
--0x09 V2��
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0a ����75%�ƾ�
  {
  ticks     = 560,          -- 560ticks = 2.8s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 50.0, rounds = 2.0}
  },
--0x0b ����2min
  {
  ticks     = 24000,        -- 24000ticks = 120s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0c ���ƾ�����flow cell
  {
  ticks     = 560,          -- 560ticks = 2.8s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -50.0, rounds = 2.0}
  },
--0x0d ��ϴ����������10s
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0e ���������븴λ
  {
  ticks     = 280,          -- 280ticks = 1.4s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0f ��������������
  {
  ticks     = 800,          -- 800ticks = 4s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x10 ��ǰ�ر�V3
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x11 ���������븴λ
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x12 ��ϴ�����������ڱ�
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 271.0, rounds = 100000}
  },
--0x13 ��ֹͣ�ͷ�ѹ��
  {
  ticks     = 600,          -- 600ticks = 3s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x14 ����
  {
  ticks     = 100,          -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- 100uL����
local TIMING_SUB_Ration100uL = {
  name = "SUB-Ration100uL",
--0x01 ��ŷ���,��Һ������,��ǰ����ѹ��
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step1      -- set step to step1
    self.idr  = 0
  end,
  ticks     = 60,           -- 60ticks = 0.3s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = config.pmotor.omega, rounds = 100000}
  },
--0x02 ע���������������
  {
  beginhook = function (self, item)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 300,          -- 300ticks = 1.5s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*100.0, rounds = 2.4}
  },
--0x03 �ͷ�V4-V2֮��ѹ��
  {
  ticks     = 240,          -- 240ticks = 1.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 ��Һ������,������
  {
  ticks     = 100,          -- 100ticks = 0.5s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = config.pmotor.omega, rounds = 100000}
  },
--0x05 v2��
  {
  ticks     = 100,          -- 100ticks = 0.5s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x06 ��������������
  {
  beginhook = function (self, item)
    item.smotor.rounds = config.smotor.lowrounds
  end,
  ticks     = 60,           -- 60ticks = 0.3s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0},  -- auto rounds
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 �������������й�����,����20ul�������
  {
  beginhook = function (self, item)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 80,           -- 80ticks = 0.4s
  valve     = {1, 5, 8, 12},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 1000, omega = PULL*120.0, rounds = 0.4}
  },
--0x08 ������̽��������
  {
  ticks     = 180,          -- 180ticks = 0.9s
  valve     = {1, 5, 8, 12},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 ��������
  { -- todo: ע����rounds
  beginhook = function (self, item)
    local _,size = subwork:sampleinfo()
    local extsize = config.imotor.boostrounds[TimingConst.TEST_IS_ABS]
    local omega = math.abs(item.imotor.omega)
    local extticks = omega / item.imotor.alpha * 2 * tmr.tickspersec() + 20
    item.ticks = (size + extsize) * (tmr.tickspermin()/config.imotor.volumperround)/omega + extticks;
    item.imotor.rounds = (size+extsize)/config.imotor.volumperround
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 340,          -- 340ticks = 1.7s  ʱ����Alex���ݲ���������,����100ms����
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PULL*40.0}
  },
--0x0a �����������,�ȴ���һ�θ�������ָ�����,��֤����������׼ȷ
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0b ��������������
  {
  beginhook = function (self, item)
    item.smotor.rounds = config.smotor.lowrounds - 0.4
  end,
  ticks     = 20,           -- 20ticks = 0.1s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0c ?
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step2      -- set step to step2
  end,
  ticks     = 20,           -- 20ticks = 0.1s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0d ���������빫��������·
  {
  beginhook = function (self, item)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 640,          -- 640ticks = 3.2s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PULL*40.0, rounds = 1.98}   -- v2�ݻ���9ul����Ϊ18ul/�ڶ��θ��������С����20��Ϊ10 20140418��
  },
--0x0e Ϊboostʱ,��Сѹ����ֵ��׼��,����Һ��ת�ٽ���Ϊ����ת�ٵ�88%
  {
  beginhook = function (self, item)
    item.pmotor.omega = 0.881 * config.pmotor.omega
  end,
  ticks     = 20,           -- 20ticks = 0.1s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED}
  },
--0x0f ����boost,�������ӹ���������·����flow cell
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
    item.ticks = t * tmr.tickspersec() + 10

    self.idr = self.idr + PUSH * item.imotor.rounds
  end,
  ticks     = 1400,         -- 1400ticks = 7s,��������,ʱ��Ԥ��50ms
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 25, omega = PUSH*55.0, rounds = 4.16}  -- �ڶ��θ��������С����20��Ϊ10, rounds�����û�ȡ
  },
--0x10 ��Һ�ûָ�����ת��
  {
  ticks     = 10,           -- 10ticks = 50ms
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = config.pmotor.omega}
  },
--0x11 boost��,����������һ���ȶ���,ע���������̶�Ϊ35ul/min
  {
  beginhook = function (self, item)
    self.idr = self.idr + PUSH * item.imotor.rounds
  end,
  ticks     = 700,          -- 700ticks = 3.5s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*0.7*config.pmotor.omega, rounds = 0.05}
  },
--0x12 boost��,���������ڶ����ȶ���,ע�����������û��趨������������ͬ
  {
  beginhook = function (self, item)
    local _, size, rate = subwork:sampleinfo()
    local coef = config.compensation[TimingConst.TEST_IS_ABS].coef[config.instrumenttype]
    item.imotor.omega = PUSH * rate * coef / config.imotor.volumperround
  end,
  ticks     = 200,          -- 200ticks = 1s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, rounds = 0.05}
  },
--0x13 ��ʽ����,��ʼ�ɼ�����
  {
  beginhook = function (self, item)
    local _, size, rate = subwork:sampleinfo()
    local coef = config.compensation[TimingConst.TEST_IS_ABS].coef[config.instrumenttype]
    item.imotor.omega = PUSH * rate * coef / config.imotor.volumperround
    size = size * coef
    item.ticks = tmr.tickspersec() * size / TimingConst.SAMPLE_MIN_SPEED
    item.imotor.rounds = size / config.imotor.volumperround

    self.tstart = tmr.systicks()
    self.ref1 = TimingConst.MEASURE_Testing     -- set state to testing
    self.ref2 = 0                               -- set step to 0
  end,
  awake     = 100,
  ticks     = 85715,        -- 85715ticks = 428.57s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN}
  },
--[[
--0x13...
  {
  opt       = TimingConst.ACTION_Drain,
  state     = TimingConst.MEASURE_Stop,
  ticks     = 85715,        -- 85715ticks = 428.57s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -10, rounds = 2.0}
  },
--]]
--0x14 ����ֹͣ
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Resetting   -- set state to resetting
    self.ref2 = 0                               -- set step to 0
  end,
  ticks     = 10,         -- 10ticks = 0.05s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x15 ���Խ���,ע��������������������ʣ���������������,ͬʱע���������������
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
      item.ticks = t * tmr.tickspersec()
    else
      item.imotor.op = TimingConst.MOTOR_STOP
    end
  end,
  ticks     = 200,        -- 200ticks = 1s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 4800, omega = -120.0, rounds = 1.55}
  }
}

-- 100uL����PIDʱ���
local TIMING_SUB_PIDRation100uL = {
  name = "SUB-PIDRation100uL",
--0x01 ��������������
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step1      -- set step to step1
    --@ ����ײ����
    self.idr  = 0
  end,
  ticks     = 30,            -- 30ticks = 0.15s,��֤�������¶������
  valve     = {6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = 150, rounds = config.smotor.lowrounds},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 650, rounds = 100000}
  },
--0x02 �������������й�����,����10uL�������
  {
  beginhook = function (self, item)
    self.idr  = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 160,            -- 160ticks = 0.8s,��֤������⵽���Թܵײ�
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 1000, omega = PULL * 120.0, rounds = 0.3}  -- ȥ��ע�����س̲�
  },
--0x03 ��������
  {
  beginhook = function (self, item)
  	--@ ��������������Ϊ�û��趨��������ͬ
    item.imotor.rounds = config.compensation[self.testsel].size + volum / config.imotor.volumperround
    --@ testsel��ʾTimingConst.TEST_IS_ABS��TimingConst.TEST_IS_PID
    --@ volum��ʾ�û��趨�Ĳ������,��Ҫ���е�λ����,1 round = 50 uL
  end,
  ticks     = 900,            -- 900ticks = 4.5s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PULL * 40, rounds = 2.6 }
  },
--0x04 ���������븴λ
  {
  beginhook = function (self, item)
    --@ ����ײ����
  end,
  ticks     = 120,            -- 900ticks = 0.6s
  valve     = {2, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = DN * (config.smotor.lowrounds - 0.4)}
  },
--0x05 ���������빫��������·
  {
  ticks     = 300,            -- 300ticks = 1.5s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PULL * 100.0, rounds = 1.75 }
  },
--[[
--0x06 ���������빫��������·
  {
    --@ ����STATEΪboosting1,
  ticks     = 260,            -- 260ticks = 1.3s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = -100.0, rounds = 1.75}
  },
--]]
--0x07 ������boost��flowcell�����
  {
  beginhook = function (self, item)
    item.imotor.rounds = config.imotor.boostrounds[self.testsel]
  end,
  ticks     = 40,            -- 40ticks = 0.2s
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PUSH * 100.0, rounds = 0.6}
  },
--0x08 PID������Һѹ����ʼ
  {
  beginhook = function (self, item)
    subwork:pidcontrol(TimingConst.PID_Start)
  end,
  ticks     = 600,            -- 600ticks = 3.0s
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PUSH * 100.0, rounds = 1.75}
  },
--0x09 PID������Һѹ������
  {
  beginhook = function (self, item)
    subwork:pidcontrol(TimingConst.PID_Stop)
  end,
  ticks     = 5,            -- 5ticks = 25ms
  valve     = {6, 9, 13}
  },
--0x0A ��Һ�����ָ�Ϊ��׼����
  {
  ticks     = 45,            -- 45ticks = 225ms
  valve     = {6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = config.pmotor.omega}
  },
--0x0B ���������Թ���״̬�ȶ�1S
  {
  beginhook = function (self, item)
  	--@ ע�����ٶ��趨Ϊ�û����õ��������� ACTION_Stable
    item.imotor.omega = sample_speed * config.compensation[self.testsel].coef[config.instrumenttype]
    --sel��ʾTimingConst.TEST_IS_ABS��TimingConst.INSTRUMENT_IS_IVD
    -- sample_speed�����û��趨����������,��Ҫ���е�λ����
    --@ state�趨Ϊstable STATE_Stable
  end,
  ticks     = 200,            -- 20ticks = 1s
  valve     = {6, 9},
  imotor    = {op = TimingConst.MOTOR_CHSPEED, alpha = 4800, omega = PUSH * 0.28},
  },
--0x0C ��ʽ����
  {
  beginhook = function (self, item)
    --@ state�趨ΪSTART ACTION_Start
    --@ ʱ����Ƹ���ʵ�ʲ����������
    --item.ticks = ?   --@ ��ζ��壿
  	--@ ע�����ٶ��趨Ϊ�û����õ��������� ACTION_Stable
    item.imotor.omega = sample_speed * sample_speed * config.compensation[self.testsel].coef[config.instrumenttype]
    -- sample_speed�����û��趨����������,��Ҫ���е�λ����
    --@ ע������ת���趨Ϊ�û����õĲ������
    item.imotor.rounds = volum / 50
    -- volum��ʾ�û��趨�Ĳ������,��Ҫ���е�λ����,1 round = 50 uL
  end,
  ticks     = 85715,            -- 85715ticks = 428.57s
  valve     = {6, 9},
  imotor    = {op = TimingConst.MOTOR_CHSPEED, alpha = 4800, omega = PUSH * 0.28, rounds = 2.0}
  },
--[[
--0x0D �û���ֹͣʱ,ִ�е�����������
  {
  --@ �ⲿ�ֹ���Ҫ���ʵ�֣�
  ticks     = 45,            -- 45ticks = 225ms
  valve     = {6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega_factor = 1.0}
  },
--]]
--0x0E ����ֹͣ
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Resettting    -- set state to resetting
    self.ref2 = 0
  end,
  ticks     = 5,            -- 5ticks = 25ms
  valve     = {6, 9, 13}
  },
--0x0F �����������
  {
  beginhook = function (self, item)
    --@ ����ע������Ҫ���Ƶ�Ȧ������ʱ
    tiem.ticks = (rounds + 0.3) /  item.imotor.omega
    item.imotor.rounds = rounds + 0.3 --@rounds���������Թ�����ע�������ƶ�����,��Ҫ�����ȡ
  end,
  ticks     = 100,            -- 100ticks = 0.5s
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_CHSPEED, alpha = 4800, omega = PUSH * 200, rounds = 2.0}
  }
}

-- ���ܹ���У׼����
local TIMING_SUB_AdjustNormal = {
  name = "SUB-AdjustNormal"
}

-- �������̽�������ϴִ������
local TIMING_SUB_TestCleanNone = {
  name = "SUB-TestCleanNone",
--0x01 ����������·���,ͬʱ��������������
  {
  state     = TimingConst.MEASURE_Reset,
  ticks     = 500,          -- 500ticks = 2.5s
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x02 v2�ر�,��������������,��Һ��ֹͣ
  {
  state     = TimingConst.MEASURE_Reset,
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 ��Һ�ø�λ,�ͷ�ѹ��
  {
  state     = TimingConst.MEASURE_Reset,
  ticks     = 200,          -- 200ticks = 1s
  valve     = {2, 3, 5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x04 v3��ǰ�ر�
  {
  state     = TimingConst.MEASURE_Reset,
  ticks     = 30,           -- 30ticks = 0.15s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 ���з��ر�,����
  {
  state     = TimingConst.MEASURE_Reset,
  ticks     = 10            -- 10ticks = 50ms
  }
}

-- �������̽�������״���ϴ����
local TIMING_SUB_TestCleanFirst = {
  name = "SUB-TestCleanFirst",
--0x01 �����������ڱ���ϴ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 800,          -- 800ticks = 4s
  valve     = {3, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 542.0}
  },
--0x02 ��������������,ͬʱ���������ϴ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = 15.0, rounds = 0.4}
  },
--0x03 ����������,ͬʱ���������ϴ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 15.0, rounds = 0.35}
  },
--0x04 �ر�v3,ͬʱ�����븴λ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 �����������ڱ���ϴ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 1500,          -- 1500ticks = 7.5s
  valve     = {1, 3, 8, 12}
  },
--0x06 ��Һ��ֹͣ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 80,          -- 80ticks = 0.4s
  valve     = {3, 5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 ����������,��Һ�ø�λ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 320,          -- 320ticks = 1.6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x08 v3�����ͷ�ѹ��
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 200,          -- 200ticks = 1s
  valve     = {2, 3, 5, 8, 12}
  },
--0x09 V3�ر�,���������븴λ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x0a ���з��ر�,��Һ��ֹͣ,����
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 10,          -- 10ticks = 50ms
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- �������̽�����Ķ����ϴ����
local TIMING_SUB_TestCleanOthers = {
  name = "SUB-TestCleanOthers",
--0x01 �����������ڱ���ϴ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 800,          -- 800ticks = 4s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000}
  },
--0x02 ��������������,ͬʱ���������ϴ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = 15.0, rounds = 0.4}
  },
--0x03 ����������,ͬʱ���������ϴ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -15.0, rounds = 0.35}
  },
--0x04 �ر�v3,ͬʱ�����븴λ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 �����������ڱ���ϴ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 1000,          -- 1000ticks = 5s
  valve     = {1, 3, 8, 12}
  },
--0x06 ��Һ��ֹͣ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 80,          -- 80ticks = 0.4s
  valve     = {3, 5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 ����������,��Һ�ø�λ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 320,          -- 320ticks = 1.6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x08 v3�����ͷ�ѹ��
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 200,          -- 200ticks = 1s
  valve     = {2, 3, 5, 8, 12}
  },
--0x09 V3�ر�,���������븴λ
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x0a ���з��ر�,��Һ��ֹͣ,����
  {
  state     = TimingConst.MEASURE_Washing,
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
  state     = TimingConst.MEASURE_Boosting1,
  ticks     = 60,           -- 60ticks = 0.3s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = config.pmotor.omega, rounds = 100000}
  },
--0x02 �����������ڱ���ϴ
  {
  state     = TimingConst.MEASURE_Boosting1,
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {1, 3, 8, 12}
  },
--0x03 ��Һ��ֹͣ
  {
  state     = TimingConst.MEASURE_Boosting1,
  ticks     = 80,           -- 80ticks = 0.4s
  valve     = {3, 5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 ����������,��Һ�ø�λ
  {
  state     = TimingConst.MEASURE_Boosting1,
  ticks     = 320,           -- 320ticks = 1.6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4}, -- acc = acc or DEFAULT_ACC
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 v3�����ͷ�ѹ��
  {
  state     = TimingConst.MEASURE_Boosting1,
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 3, 5, 8, 12}
  },
--0x06 V3�ر�,���������븴λ
  {
  state     = TimingConst.MEASURE_Boosting1,
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x07 ���з��ر�,��Һ��ֹͣ,����
  {
  state     = TimingConst.MEASURE_Boosting1,
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
  ticks     = 64000,           -- 64000ticks = 320s ��ע5��
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x02 ��ע����������·
  {
  ticks     = 1000,           -- 1000ticks = 5s ��ע5��
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x03 ��עNovoCleanͰ��V11
  {
  ticks     = 7000,           -- 7000ticks = 35s ��ע����NovoRinse��flowchamber����ݻ���1.5��
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x04 ��עNovoRinseͰ��flowchamber��ڹ�·
  {
  ticks     = 28000,           -- 28000ticks = 140s ��ע����NovoRinse��flowchamber����ݻ���2��
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x05 ����Һ��ϴNovoRinse���͹�·
  {
  ticks     = 14000,           -- 14000ticks = 70s ��ϴV10��flowchamber���2��
  valve     = {7, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x06 �ͷ�chamberѹ��
  {
  ticks     = 1200,           -- 1200ticks = 6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 ��ע��Һ��·
  {
  ticks     = 16000,           -- 16000ticks = 80s ��ע2��
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x08 ֹͣ��Һ��,�ͷ�ѹ��
  {
  ticks     = 1600,           -- 1600ticks = 8s
  valve     = {3, 5, 8, 12},
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

-- InitPriming step 2: ѹ��������2��·��ע
local TIMING_SUB_InitPrimingStep2 = {
  name = "SUB-InitPrimingStep2",
--0x01 ������Һ��
  {
  ticks     = 6000,           -- 6000ticks = 30s ��ע10��
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x02 ֹͣ��Һ��
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- InitPriming step 3: ѹ��������1��ע
local TIMING_SUB_InitPrimingStep3 = {
  name = "SUB-InitPrimingStep3",
--0x01 ��V8�ϵ�,������Һ��
  {
  ticks     = 7000,           -- 7000ticks = 35s ��ע10��
  valve     = {5},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x02 ֹͣ��Һ��,����ŷ���λ
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- InitPriming step 4: dummy
local TIMING_SUB_InitPrimingStep4 = {
  name = "SUB-InitPrimingStep4",
-- 0x01 �ȴ���һ������
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- �ſ�----������;�����ʱ�䲻ʹ��,��Ҫ�ſ�
-- Drain step 1: �ó���ˮ��ϴ��·
local TIMING_SUB_DrainStep1 = {
  name = "SUB-DrainStep1",
--0x01 ��ϴNovoClean��·
  {
  ticks     = 52000,           -- 52000ticks = 260s ��NovoCleanͰ>��Һ��>V11 ��ϴ10��
  valve     = {7, 8, 9, 10},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x02 ��ϴNovoRinse��·
  {
  ticks     = 84000,           -- 84000ticks = 420s ��NovoRinseͰ>��Һ��>NovoRinse���͹�·>chamber>��ҺͰ ��ϴ10��
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 �ó���ˮ��ϴע������ǻ��������·
  {
  ticks     = 260000,           -- 260000ticks = 1300s ��ϴ20��
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 ע���������Ŷ���ǻ�е�����
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 5.0}
  },
--0x05 ע���������Ŷ���ǻ�е�����
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 5.0}
  },
--0x06 �ͷ�ѹ��
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {3, 5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 �ó���ˮ��ϴ����������·
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 271.0, rounds = 100000}
  },
--0x08 �ͷ�ѹ��
  {
  ticks     = 800,           -- 800ticks = 4s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 ��������������
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0a ��ϴ��Һ��·
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x0b ���������븴λ
  {
  ticks     = 77000,           -- 77000ticks = 385s ��ϴ10��
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0c ��������������
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0d �ͷ�ѹ��
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {2, 3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0e V3�ر�
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0f ���������븴λ,����
  {
  ticks     = 200,           -- 200ticks = 1s
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DrainStep1 = {
  name = "IDX-DrainStep1",
  -- NovoCleanͰ>>v11 ��ϴ10��
  0x01,
  -- NovoRinseͰ>��Һ��>NovoRinse���͹�·>chamber��� ��ϴ10��
  0x02,
  -- ��ҺͰ>��Һ��>ע����>chamber>V9>��Һ��·��ϴ20��
  0x03,
  -- ��ҺͰ>��Һ��>ע����>chamber>V9>��Һ��·��ϴ10��,ע���������Ŷ�126��
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  -- ��ҺͰ>��Һ��>ע����>V2>���������ܳ�ϴ,Һ����Ϊ������������+�����������ݻ���30��
  0x06, 0x07, 0x08, 0x09,
  -- ��ҺͰ>��Һ��>damper>flow chamber>V3>���ӹ�·��ϴ10��
  0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
}

-- Drain step 2: �ó���ˮ��ϴP2��·
local TIMING_SUB_DrainStep2 = {
  name = "SUB-DrainStep2",
--0x01 ��V8�ϵ�,������Һ��
  {
  ticks     = 6000,           -- 6000ticks = 30s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x02 ֹͣ��Һ��,�����е�ŷ��ϵ縴λ
  {
  ticks     = 100,           -- 100ticks = 0.5s
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- Drain step 3: �ó���ˮ��ϴP1��·
local TIMING_SUB_DrainStep3 = {
  name = "SUB-DrainStep3",
--0x01 ��V6��V8�ϵ�,������Һ��
  {
  ticks     = 7000,           -- 7000ticks = 35s
  valve     = {5},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x02 ֹͣ��Һ��,�����е�ŷ��ϵ縴λ
  {
  ticks     = 100,           -- 100ticks = 0.5s
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
}

-- Drain step 4: NovoClean��·��NovoRinse��·��������·����Һ��·�ſ�
local TIMING_SUB_DrainStep4 = {
  name = "SUB-DrainStep4",
--0x01 �ſ�NovoClean��·
  {
  ticks     = 16000,           -- 16000ticks = 80s ��NovoCleanͰ>v11 �ſ�3��
  valve     = {7, 8, 9, 10},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x02 �ſ�NovoRinse��·
  {
  ticks     = 26000,           -- 26000ticks = 130s ��NovoRinseͰ>��Һ��>NovoRinse���͹�·>chamber��� �ſ�3��
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 �ſ�ע������ǻ������������·��flowchamber��flowchamber��Һ��·
  {
  ticks     = 64000,           -- 64000ticks = 320s �ſ�3��
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 �ſ�����������·
  {
  ticks     = 4000,           -- 4000ticks = 20s �ſ�10��
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 271.0, rounds = 100000}
  },
--0x05 ��������������
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x06 �ſ���Һ��·
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x07 ���������븴λ
  {
  ticks     = 23000,           -- 23000ticks = 115s �ſ�3��
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x08 ��������������
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 V3�ر�,�븴λ
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {5, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0a ��Һ�������ӵķ�Һ��·
  {
  ticks     = 1600,           -- 1600ticks = 8s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0b ��Һ��ֹͣ��Һ,�����ӷ�Һ��·�е�Һ��ۼ�,�Ա���һ�α�����
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {3, 5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0c ע�����Ƶ�����λ��
  {
  ticks     = 2700,           -- 2700ticks = 13.5s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x0d ֹͣ��Һ��,�����е�ŷ��ϵ縴λ,ֹͣ��Һ��,����
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DrainStep4 = {
  name = "IDX-DrainStep4",
  -- NovoCleanͰ>v11 �ſ�3��
  0x01,
  -- NovoRinseͰ>��Һ��>NovoRinse���͹�·>chamber��� �ſ�3��
  0x02,
  -- ��ҺͰ>��Һ��>ע����>chamber>V9>��Һ��·�ſ�3��
  0x03,
  -- ��ҺͰ>��Һ��>ע����>V2>���������ܳ�ϴ,�ſ�����������·3��
  0x04,
  -- ��ҺͰ>��Һ��>damper>flow chamber>V3>���ӹ�·��ϴ10��
  0x05, 0x06, 0x07, 0x08, 0x09,
  -- �������ӵķ�Һ��·
  0x0A, 0x09, 0x0A, 0x09, 0x0A, 0x0B,
  -- ע������λ������,����
  0x0C, 0x0D
}

-- Drain step 5: P2�ſ�
local TIMING_SUB_DrainStep5 = {
  name = "SUB-DrainStep5",
--0x01 ������Һ��
  {
  ticks     = 6000,           -- 6000ticks = 30s �ſ�10��
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x02 ֹͣ��Һ��,�����е�ŷ��ϵ縴λ
  {
  ticks     = 100,           -- 100ticks = 0.5s
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- Drain step 6: P1�ſ�
local TIMING_SUB_DrainStep6 = {
  name = "SUB-DrainStep6",
--0x01 ��V6�ϵ�,������Һ��
  {
  ticks     = 7000,           -- 7000ticks = 35s �ſ�10��
  valve     = {5},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 1000000}
  },
--0x02 ֹͣ��Һ��,�����е�ŷ��ϵ縴λ
  {
  ticks     = 100,           -- 100ticks = 0.5s
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03
  {
  ticks     = 1200,           -- 1200ticks = 6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -225.0, rounds = 22.0}, -- ��֤ע��������ײ�Ҳ�ܸ�λ
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x04 �����е�ŷ��ϵ縴λ
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
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
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 1000000}
  },
--0x02 ����8��3��13��·
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 542.0}
  },
--0x03 ������Һ��·6��3��13
  {
  ticks     = 18000,           -- 18000ticks = 90s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x04 ��������������
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x05 ��Һ��ת�����
  {
  ticks     = 42000,           -- 42000ticks = 210s ��Һ��=22.75ml
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
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
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 420.0, rounds = 35.0}
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

-- Decontamination step 2: ��NovoClean����ѹ��������1��·��U1��
local TIMING_SUB_DeconStep2 = {
  name = "SUB-DeconStep2",
--0x01 ������Һ��,����Pressure1��·
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {5},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 1000000.0}
  },
--0x02 ֹͣ��Һ��
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 ����
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DeconStep2 = {
  name = "IDX-DeconStep2",
  0x01, 0x02, 0x03
}

-- Decontamination step 3: ��NovoClean����ѹ��������2��·��U2��
local TIMING_SUB_DeconStep3 = {
  name = "SUB-DeconStep3",
--0x01 ������Һ��,����Pressure2��·
  {
  ticks     = 6000,           -- 6000ticks = 30s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 1000000.0}
  },
--0x02 ֹͣ��Һ��
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 ����
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DeconStep3 = {
  name = "IDX-DeconStep3",
  0x01, 0x02, 0x03
}

-- Decontamination step 4: NovoClean���ݹ�·,����ɱ������
local TIMING_SUB_DeconStep4 = {
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

local TIMING_IDX_DeconStep4 = {
  name = "IDX-DeconStep4",
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
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
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
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000}
  },
--0x04 ��V6�Ŷ�
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
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
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000}
  },
--0x09 ��ϴpressure2��·
  {
  ticks     = 3000,           -- 3000ticks = 15s
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
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
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x0c ע��������
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
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
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x11 ע��������,��V9
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x12 ע��������,��V3��13
  {
  ticks     = 1700,           -- 2000ticks = 10s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x13 ������Һ��,��עע����
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x14 ע��������,��עע����
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x15 ע��������,��עע����
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
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
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000}
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
  -- ѭ��2-2
  0x10, 0x11, 0x10, 0x11, 0x10, 0x11,
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

  0x1E, 0x1F                                 -- �ͷ�ѹ��
}

-- Decontamination step 5-2: ��ϴע������ǻ,��Խ���ʱ�䳤��45min
local TIMING_SUB_DeconStep5_2 = {
  name = "SUB-DeconStep5_2",
--0x01 ������Һ��
  {
  ticks     = 24000,           -- 24000ticks = 120s ��Һ��=13ml
  valve     = {7, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000.0}
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
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000.0}
  },
--0x04 ��V6�Ŷ�
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
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
  ticks     = 3000,           -- 3000ticks = 15s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000.0}
  },
--0x09 ��ϴpressure2��·
  {
  ticks     = 3000,           -- 3000ticks = 15s
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
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
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x0c ע��������
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
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
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x11 ע��������,��V9
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x12 ע��������,��V3��13
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x13 ������Һ��,��עע����
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000.0}
  },
--0x14 ע��������,��עע����
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x15 ע��������,��עע����
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
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
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000.0}
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

local TIMING_IDX_DeconStep5_2 = {
  name = "IDX-DeconStep5_2",
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
  -- ѭ��1-2
  0x0A,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  -- ѭ��2-2
  0x10, 0x11, 0x10, 0x11, 0x10, 0x11,
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
  -- ѭ��2-3
  0x10, 0x11, 0x10, 0x11, 0x10, 0x11,
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
  -- ѭ��3-2
  0x06, 0x19, 0x1E, 0x1B, 0x04,
  0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x19, 0x1E, 0x1B, 0x04,
  0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x19, 0x1E, 0x1B, 0x09,
  -- ѭ��2-4
  0x10, 0x11, 0x10, 0x11, 0x10, 0x11,
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

  0x1E, 0x1F                                  -- �ͷ�ѹ��
}

-- Decontamination step 6-1: ��ϴchamber,��Խ��ݶ���45min
local TIMING_SUB_DeconStep6_1 = {
  name = "SUB-DeconStep6_1",
--0x01 ������Һ�� ��ϴ����������
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 271.0, rounds = 100000.0}
  },
--0x02 ������Һ�� ����Novorinse��Chamber
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x03 ע��������,��������
  {
  ticks     = 900,           -- 900ticks = 4.5s
  valve     = {1},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 10.0},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 ע��������,��V9������
  {
  ticks     = 900,           -- 900ticks = 4.5s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 10.0}
  },
--0x05 ע��������,��V3��V13������
  {
  ticks     = 900,           -- 900ticks = 4.5s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 10.0}
  },
--0x06 ������Һ�� ��ϴ4��3��13��·
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x07 ע��������,��ϴ4��3��13��·
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x08 ��V4�Ŷ�,��ϴ4��3��13��·
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 ��V4�Ŷ�,��ϴ4��3��13��·
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0a ��V4�Ŷ�,��ϴ4��3��13��·
  {
  ticks     = 400,           -- 400ticks = 2s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0b ע��������,��ϴ4��3��13��·
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x0c ������Һ�� ��ϴ4��9��·
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x0d ע��������,��ϴ4��9��·
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x0e ��V4�Ŷ�,��ϴ4��9��·
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0f ��V4�Ŷ�,��ϴ4��9��·
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x10 ��V4�Ŷ�,��ϴ4��9��·
  {
  ticks     = 400,           -- 400ticks = 2s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x11 ע��������,��ϴ4��9��·
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x12 ������Һ�� ��ϴ8��9��·
  {
  ticks     = 9000,           -- 9000ticks = 45s
  valve     = {7, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x13 ������Һ�� ��ϴ6��3��13��·
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000.0}
  },
--0x14 ��V6�Ŷ�,��ϴ6��3��13��·
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x15 ��V6�Ŷ�,��ϴ6��3��13��·
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x16 ��V6��ϴ,��ϴ6��3��13��·
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x17 ������Һ�� ��ϴ6��9��·
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x18 ��V6�Ŷ�,��ϴ6��9��·
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x19 ��V6�Ŷ�,��ϴ6��9��·
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1a ��V6��ϴ,��ϴ6��9��·
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1b ������Һ�� ��ϴ����������
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x1c ע��������,��ϴ4��3��13��·
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x1d ע��������,��ϴ4��9��·
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
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

local TIMING_IDX_DeconStep6_1 = {
  name = "IDX-DeconStep6_1",
  0x01,                                                                       -- ��ϴ����������

  -- ѭ��1-1
  0x02,                                                                       -- Chamber������NovoRinse

  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,                                         -- �ſ�Chamber

  0x01, 0x06, 0x07,                                                           -- ��ϴSyring��·4��3��13
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,                                                                 -- ��ϴSyring��·4��9
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��1-2
  0x02,

  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��2-1
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,                 -- ��ϴ��Һ��·
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17, 0x12, 0x1E,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17,

  -- ѭ��1-3
  0x02,

  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��3-1
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��2-2
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17, 0x12, 0x1E,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17,

  -- ѭ��3-2
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  0x1E, 0x1F                              -- ����
}

-- Decontamination step 6-2: ��ϴchamber,��Խ��ݳ���45min
local TIMING_SUB_DeconStep6_2 = {
  name = "SUB-DeconStep6_2",
--0x01 ������Һ�� ��ϴ����������
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 271.0, rounds = 100000.0}
  },
--0x02 ������Һ�� ����Novorinse��Chamber
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x03 ע��������,��������
  {
  ticks     = 900,           -- 900ticks = 4.5s
  valve     = {1},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 10.0},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 ע��������,��V9������
  {
  ticks     = 900,           -- 900ticks = 4.5s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 10.0}
  },
--0x05 ע��������,��V3��V13������
  {
  ticks     = 900,           -- 900ticks = 4.5s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 10.0}
  },
--0x06 ������Һ�� ��ϴ4��3��13��·
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x07 ע��������,��ϴ4��3��13��·
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x08 ��V4�Ŷ�,��ϴ4��3��13��·
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 ��V4�Ŷ�,��ϴ4��3��13��·
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0a ��V4�Ŷ�,��ϴ4��3��13��·
  {
  ticks     = 400,           -- 400ticks = 2s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0b ע��������,��ϴ4��3��13��·
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x0c ������Һ�� ��ϴ4��9��·
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x0d ע��������,��ϴ4��9��·
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x0e ��V4�Ŷ�,��ϴ4��9��·
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0f ��V4�Ŷ�,��ϴ4��9��·
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x10 ��V4�Ŷ�,��ϴ4��9��·
  {
  ticks     = 400,           -- 400ticks = 2s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x11 ע��������,��ϴ4��9��·
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x12 ������Һ�� ��ϴ8��9��·
  {
  ticks     = 9000,           -- 9000ticks = 45s
  valve     = {7, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x13 ������Һ�� ��ϴ6��3��13��·
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000.0}
  },
--0x14 ��V6�Ŷ�,��ϴ6��3��13��·
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x15 ��V6�Ŷ�,��ϴ6��3��13��·
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x16 ��V6��ϴ,��ϴ6��3��13��·
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x17 ������Һ�� ��ϴ6��9��·
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x18 ��V6�Ŷ�,��ϴ6��9��·
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x19 ��V6�Ŷ�,��ϴ6��9��·
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1a ��V6��ϴ,��ϴ6��9��·
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1b ������Һ�� ��ϴ����������
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x1c ע��������,��ϴ4��3��13��·
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x1d ע��������,��ϴ4��9��·
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
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

local TIMING_IDX_DeconStep6_2 = {
  name = "IDX-DeconStep6_2",
  0x01,                                                                       -- ��ϴ����������

  -- ѭ��1-1
  0x02,                                                                       -- Chamber������NovoRinse

  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,                                         -- �ſ�Chamber

  0x01, 0x06, 0x07,                                                           -- ��ϴSyring��·4��3��13
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,                                                                 -- ��ϴSyring��·4��9
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��1-2
  0x02,

  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��2-1
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,                -- ��ϴ��Һ��·
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17, 0x12, 0x1E,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17,

  -- ѭ��1-3
  0x02,

  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��1-4
  0x02,

  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��2-2
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17, 0x12, 0x1E,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17,

  -- ѭ��1-5
  0x02,

  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��1-6
  0x02,

  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��3-1
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��2-3
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17, 0x12, 0x1E,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17,

  -- ѭ��3-2
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��3-3
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��3-4
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- ѭ��3-5
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x01, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  0x1E, 0x1F                              -- ����
}

-- Decontamination step 7: ��ϴѹ��������1��·��U1��
local TIMING_SUB_DeconStep7 = {
  name = "SUB-DeconStep7",
--0x01 ������Һ��,��ϴPressure1��·
  {
  ticks     = 36000,           -- 36000ticks = 180s
  valve     = {5},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 1000000.0}
  },
--0x02 ֹͣ��Һ��
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 ����
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DeconStep7 = {
  name = "IDX-DeconStep7",
  0x01, 0x02, 0x03
}

-- Decontamination step 8: ��ϴѹ��������2��·��U2��
local TIMING_SUB_DeconStep8 = {
  name = "SUB-DeconStep8",
--0x01 ������Һ��,��ϴPressure2��·
  {
  ticks     = 36000,           -- 36000ticks = 180s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 1000000.0}
  },
--0x02 ֹͣ��Һ��
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 ����
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DeconStep8 = {
  name = "IDX-DeconStep8",
  0x01, 0x02, 0x03
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
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = config.pmotor.omega, rounds = 1000000.0}
  },
--0x02 ��ʼУ׼Ŀ��ѹ��ֵ
  {
  ticks     = 3000,             -- 3000ticks = 15s
  valve     = {5, 8, 12}
  },
--0x03 Ŀ��ѹ��ֵУ׼����
  {
  ticks     = 200,              -- 200ticks = 1s
  valve     = {5, 8, 12}
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
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = config.pmotor.omega, rounds = 1000000.0}
  },
--0x02 ֹͣ��Һ��
  {
  ticks     = 20,               -- 20ticks = 0.1s
  valve     = {5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 ��Һ�ø�λ,�ͷ�ѹ��
  {
  ticks     = 1200,             -- 1200ticks = 6s
  valve     = {5, 8, 12},
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
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = config.pmotor.omega, rounds = 1000000.0}
  },
--0x02 ֹͣ��Һ��
  {
  ticks     = 100,              -- 100ticks = 0.5s
  valve     = {5, 8, 12},
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
-- GRP-Timing definition
-------------------------------------------------------------------------
local TIMING_GRP_InitStartUp = {
  name = "InitStartUp",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_NovoRinse4Priming,  idx = TIMING_IDX_NovoRinse4Priming},
  {sub = TIMING_SUB_WashAwayNR,         idx = TIMING_IDX_WashAwayNR       },
  {sub = TIMING_SUB_Priming,            idx = TIMING_IDX_Priming          },
  {sub = TIMING_SUB_Priming,            idx = TIMING_IDX_Priming          },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_StartUp = {
  name = "StartUp",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_NovoRinseCleaning,  idx = TIMING_IDX_NovoRinseCleaning},
  {sub = TIMING_SUB_WashAwayNR,         idx = TIMING_IDX_WashAwayNR       },
  {sub = TIMING_SUB_Priming,            idx = TIMING_IDX_Priming          },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_MeasureNormal = {
  name = "MeasureNormal",
  {sub = TIMING_SUB_Ration100uL,        idx = nil                         }
}

local TIMING_GRP_MeasurePID = {
  name = "MeasurePID",
  {sub = TIMING_SUB_PIDRation100uL,     idx = nil                         }
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
  {sub = TIMING_SUB_WashAwayNC,         idx = TIMING_IDX_WashAwayNC       },
  {sub = TIMING_SUB_SheathCleaning,     idx = TIMING_IDX_SheathCleaning   },
  {sub = TIMING_SUB_Priming,            idx = TIMING_IDX_Priming          },
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
  {sub = TIMING_SUB_Debubble,           idx = nil                         },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_Cleaning = {
  name = "Cleaning",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_NovoCleanCleaning,  idx = TIMING_IDX_NovoCleanCleaning},
  {sub = TIMING_SUB_WashAwayNC,         idx = TIMING_IDX_WashAwayNC       },
  {sub = TIMING_SUB_SheathCleaning,     idx = TIMING_IDX_SheathCleaning   },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_Rinse = {
  name = "Rinse",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_Rinse,              idx = TIMING_IDX_Rinse            },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_ExtRinse = {
  name = "ExtRinse",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_NovoRinseCleaning,  idx = TIMING_IDX_NovoRinseCleaning},
  {sub = TIMING_SUB_Soak,               idx = nil                         },
  {sub = TIMING_SUB_WashAwayNR,         idx = TIMING_IDX_WashAwayNR       },
  {sub = TIMING_SUB_Priming,            idx = TIMING_IDX_Priming          },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_Priming = {
  name = "Priming",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_NovoRinse4Priming,  idx = TIMING_IDX_NovoRinse4Priming},
  {sub = TIMING_SUB_WashAwayNR,         idx = TIMING_IDX_WashAwayNR       },
  {sub = TIMING_SUB_Priming,            idx = TIMING_IDX_Priming          },
  {sub = TIMING_SUB_Priming,            idx = TIMING_IDX_Priming          },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_Unclog = {
  name = "Unclog",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_NovoCleanCleaning,  idx = TIMING_IDX_NovoCleanCleaning},
  {sub = TIMING_SUB_WashAwayNC,         idx = TIMING_IDX_WashAwayNC       },
  {sub = TIMING_SUB_SheathCleaning,     idx = TIMING_IDX_SheathCleaning   },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_Backflush = {
  name = "Backflush",
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         },
  {sub = TIMING_SUB_Backflush,          idx = TIMING_IDX_Backflush        },
  {sub = TIMING_SUB_PTCalibration,      idx = nil                         },
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil                         }
}

local TIMING_GRP_InitPriming = {
  name = "InitPriming",
  {sub = TIMING_SUB_InitPrimingStep1,   idx = TIMING_IDX_InitPrimingStep1,  ishand = true},
  {sub = TIMING_SUB_InitPrimingStep2,   idx = nil,                          ishand = true},
  {sub = TIMING_SUB_InitPrimingStep3,   idx = nil,                          ishand = true},
  {sub = TIMING_SUB_InitPrimingStep4,   idx = nil,                          ishand = true}
}

local TIMING_GRP_Drain = {
  name = "Drain",
  {sub = TIMING_SUB_DrainStep1,         idx = TIMING_IDX_DrainStep1,        ishand = true},
  {sub = TIMING_SUB_DrainStep2,         idx = nil,                          ishand = true},
  {sub = TIMING_SUB_DrainStep3,         idx = nil,                          ishand = true},
  {sub = TIMING_SUB_DrainStep4,         idx = TIMING_IDX_DrainStep4,        ishand = true},
  {sub = TIMING_SUB_DrainStep5,         idx = nil,                          ishand = true},
  {sub = TIMING_SUB_DrainStep6,         idx = nil,                          ishand = true}
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

local TIMING_GRP_SIPFiringResume = {
  name = "SIPFiringResume",
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
  {sub = TIMING_SUB_WashAwayNC,         idx = TIMING_IDX_WashAwayNC},
  {sub = TIMING_SUB_Rinse,              idx = TIMING_IDX_Rinse},
  {sub = TIMING_SUB_PTCalibration,      idx = nil},
  {sub = TIMING_SUB_MotorsGoHome,       idx = nil},
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
  {sub = TIMING_SUB_DeconStep2,         idx = TIMING_IDX_DeconStep2,    ishand = true},
  {sub = TIMING_SUB_DeconStep3,         idx = TIMING_IDX_DeconStep3,    ishand = true},
  {sub = TIMING_SUB_DeconStep4,         idx = TIMING_IDX_DeconStep4,    ishand = true},
  {sub = TIMING_SUB_DeconStep5_1,       idx = TIMING_IDX_DeconStep5_1,  ishand = true},   -- <45min Step5-1
  {sub = TIMING_SUB_DeconStep6_1,       idx = TIMING_IDX_DeconStep6_1,  ishand = true},   -- <45min Step6-1
  {sub = TIMING_SUB_DeconStep7,         idx = TIMING_IDX_DeconStep7,    ishand = true},
  {sub = TIMING_SUB_DeconStep8,         idx = TIMING_IDX_DeconStep8,    ishand = true},
  {sub = TIMING_SUB_DeconStep9,         idx = nil,                      ishand = true},

  {sub = TIMING_SUB_DeconStep5_2,       idx = TIMING_IDX_DeconStep5_2,  ishand = true},   -- >45min Step5-2
  {sub = TIMING_SUB_DeconStep6_2,       idx = TIMING_IDX_DeconStep6_2,  ishand = true}    -- >45min Step6-2
}


-------------------------------------------------------------------------
-- Timing Export
-------------------------------------------------------------------------
timing = const.newConst {
  version               = TIMING_VERSION,
  init_startup          = TIMING_GRP_InitStartUp,
  startup               = TIMING_GRP_StartUp,
  measure               = TIMING_GRP_MeasureNormal,
  measure_pid           = TIMING_GRP_MeasurePID,
  adjust_normal         = TIMING_GRP_AdjustNormal,
  test_clean_none       = TIMING_GRP_TestCleanNone,
  test_clean_first      = TIMING_GRP_TestCleanFirst,
  test_clean_others     = TIMING_GRP_TestCleanOthers,
  shutdown              = TIMING_GRP_Shutdown,
  maintain_debubble     = TIMING_GRP_Debubble,
  maintain_cleaning     = TIMING_GRP_Cleaning,
  maintain_rinse        = TIMING_GRP_Rinse,
  maintain_extrinse     = TIMING_GRP_ExtRinse,
  maintain_priming      = TIMING_GRP_Priming,
  maintain_unclog       = TIMING_GRP_Unclog,
  maintain_backflush    = TIMING_GRP_Backflush,
  initpriming           = TIMING_GRP_InitPriming,
  drain                 = TIMING_GRP_Drain,
  ptcali                = TIMING_GRP_PTCalibration,
  sleep_enter           = TIMING_GRP_SleepEnter,
  sleep_exit            = TIMING_GRP_SleepExit,
  motorgohome           = TIMING_GRP_MotorsGoHome,
  resume_sipfiring      = TIMING_GRP_SIPFiringResume,
  resume_pressure       = TIMING_GRP_PResume,
  resume_pressureext    = TIMING_GRP_PExtResume,
  resume_sipabnormal    = TIMING_GRP_SIPAbnormalResume,
  decontamination       = TIMING_GRP_Decontamination
}

return timing

--******************************************************************************
-- No More!
--******************************************************************************
