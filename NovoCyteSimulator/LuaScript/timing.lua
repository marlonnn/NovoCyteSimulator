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
-- 停止电机和所有阀
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

-- 压力超限后的压力释放
local TIMING_SUB_PRelease = {
  name = "SUB-PRelease",
-- 0x01 复位
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 1200,   -- 1200ticks = 6s  保证注射器在最底部也能复位
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -225.0, rounds = 22.0},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x02 电磁阀打开,释放压力
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

-- 重启压力监控
local TIMING_SUB_PRecheck = {
  name = "SUB-PRecheck",
-- 0X01 释放压力结束,检测压力是否仍然高于200kPa
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 2000,   -- 2000ticks = 10s 每个通道检测2s
  --valve  = nil,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- 所有Motor复位到机械零点,同时释放压力
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

-- 浸泡流程
local TIMING_SUB_Soak = {
  name = "SUB-Soak",
-- 0x01 浸泡2min
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

-- 关机外置样本针整体浸泡流程
local TIMING_SUB_SIPSoak = {
  name = "SUB-SIPSoak",
-- 0x01 外置样本针下行,浸入超纯水中
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

-- 样本针擦拭完毕后的复位
local TIMING_SUB_SIPGoHome = {
  name = "SUB-SIPGoHome",
-- 0x01 外置样本针复位
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

-- 灌注流程
local TIMING_SUB_Priming = {
  name = "SUB-Priming",
-- 0x01 启动鞘液泵
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
-- 0x02 关闭V4进行扰动
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 20,
  valve     = {8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
--pmotor    = {op = TimingConst.MOTOR_KEEP}
  },
-- 0x03 打开V4进行扰动
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
--pmotor    = {op = TimingConst.MOTOR_KEEP}
  },
-- 0x04 注射器下拉,扰动其内部死区残留的NovoRinse
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 500,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 5.0}
--pmotor    = {op = TimingConst.MOTOR_KEEP}
  },
-- 0x05 注射器上推,扰动其内部死区残留的NovoRinse
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 500,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
-- 0x06 注射器静止,鞘液泵变速
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 400,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x07 从鞘液管路用鞘液清洗chamber(从V9出废液)
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x08 V6关闭扰动
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 20,
  valve     = {8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x09 V6打开扰动
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0a 释放chamber压力,提前打开废液泵,外置样本针下行,使V3流出液体受到拦截,同时释放样本管路压力
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 1200,
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0b 从鞘液管路用鞘液清洗chamber(从V3出废液)
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 500,
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
-- 0x0c 从鞘液管路用鞘液清洗chamber(从V3出废液),外置样本针上行,吸干表面
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 100,
  valve     = {2, 5, 12},
  smotor    = SIP_Reset,
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0d 从鞘液管路用鞘液清洗chamber(从V3出废液),外置样本针下行,拦截V3关闭溅出水滴
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 1000,
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0e 外置样本针上行
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {5, 8, 12},
  smotor    = SIP_Reset,
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0f V2提前打开
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x10 从样本管路用鞘液清洗外置样本管&外置样本针内壁
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 1000,
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
-- 0x11 打开V4进行扰动
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x12 停止鞘液泵
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 200,
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x13 关闭V2,释放压力
  {
  --opt    = nil,
  --state  = nil,
  ticks     = 100,
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x14 结束
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
  0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02,   -- V4开关扰动

  0x04, 0x05, 0x06, 0x04, 0x05, 0x06, 0x04, 0x05, 0x06,
  0x04, 0x05, 0x06, 0x04, 0x05, 0x06, 0x04, 0x05,               -- 注射器吸排

  0x07, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, -- V6开关扰动
  0x0a, 0x0b, 0x0c, 0x0d, 0x0c, 0x0d, 0x0e, 0x0f,               -- 从chamber侧口出废液,以清洗chamber内部
  0x10,                                                         -- 清洗外置样本内壁

  0x11, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02,
  0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02,
  0x04, 0x05, 0x06, 0x04, 0x05, 0x06, 0x04,
  0x05, 0x06, 0x04, 0x05, 0x06, 0x04, 0x05,
  0x07, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08,
  0x0a, 0x0b, 0x0c, 0x0d, 0x0c, 0x0d, 0x0e, 0x0f,
  0x10,

  0x12, 0x13, 0x14                                              -- 释放压力
}

-- 鞘液清洗流程
local TIMING_SUB_SheathCleaning = {
  name = "SUB-SheathCleaning",
-- 0x01 冲洗内置样本管路
  {
  ticks     = 6000,
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
-- 0x02 注射器下拉,扰动其内部死区残留的NovoRinse&NovoClean
  {
  ticks     = 220,
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 2.5}
  },
-- 0x03 注射器上推,扰动其内部死区残留的NovoRinse&NovoClean
  {
  ticks     = 520,
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 60.0, rounds = 2.5}
  },
-- 0x04 关闭V2进行扰动
  {
  ticks     = 200,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x05 打开V2进行扰动
  {
  ticks     = 20,
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x06 从样本管路用鞘液清洗外置样本针内壁
  {
  ticks     = 1600,
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
-- 0x07 关闭V2,转速提高
  {
  ticks     = 100,
  valve     = {3, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x08 从鞘液管路用鞘液清洗chamber(从V9出废液)
  {
  ticks     = 6000,
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x09 从左侧进水清洗chamber(从V9出废液)
  {
  ticks     = 6000,
  valve     = {5, 7, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0a 样本针下行,注射器下拉,降低chamber内部压力,液体切换至样本管路
  {
  ticks     = 620,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 7.5}
  },
-- 0x0b 从样本管路清洗chamber(从V3出废液),外置样本针上行,同时扰动拭子内部残留液体
  {
  ticks     = 200,
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x0c 外置样本针下行,同时扰动拭子内部残留液体
  {
  ticks     = 1000,
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4}
  },
-- 0x0d 从鞘液管路用鞘液清洗chamber(从V3出废液),外置样本针上行,吸干表面
  {
  ticks     = 200,
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0e 外置样本针下行,同时扰动拭子内部残留液体
  {
  ticks     = 1000,
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0f V3关闭,样本针复位
  {
  ticks     = 100,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x10 结束
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

  0x02, 0x03, 0x02, 0x03, 0x02, 0x03,                           -- 注射器吸排
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,   -- v2开关扰动
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x06, 0x07,                   -- 清洗外置样本针&管内壁
  0x08,                         -- 从鞘液管路清洗chamber(从v9出废液)
  0x09,                         -- 从左侧进水清洗chamber(从v9出废液)
  0x0a,                         -- 样本针下行,注射器下拉,降低chamber内部压力,液体切换至样本管路
  0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c,   -- 从样本管路清洗chamber(从v3出废液)
  0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e,   -- 从鞘液管路清洗chamber(从v3出废液)
  0x0f,                         -- 外置样本针复位

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

-- 冲洗流程
local TIMING_SUB_Rinse = {
  name = "SUB-Rinse",
-- 0x01 注射器下拉、清洗内置样本管
  {
  ticks     = 500,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
-- 0x02 注射器上推、清洗内置样本管
  {
  ticks     = 500,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
-- 0x03 清洗外置样本管
  {
  ticks     = 400,
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x04 注射器下拉、清洗内置样本管
  {
  ticks     = 500,
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x05 泵停止,释放压力
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

-- NovoRinse清洗流程
local TIMING_SUB_NovoRinseCleaning = {
  name = "SUB-NovoRinseCleaning",
-- 0x01 鞘液泵将NovoRinse运到Flow chamber,用NovoRinse对flowcell进行清洗
  {
  ticks     = 6000,
  valve     = {7, 8, 9},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 635.0, rounds = 100000}
  },
-- 0x02 用注射器将NovoRinse吸入内置及公共样本管路
  {
  ticks     = 1000,
  valve     = {7, 8, 9, 12},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -100.0, rounds = 7.8} --NovoRinse与NovoFlow之间的界面距注射器150mm
  },
-- 0x03 将NovoRinse推入外置样本管路
  {
  ticks     = 400,
  valve     = {1, 7, 8, 9, 12},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -65.0, rounds = 1.6}
  },
-- 0x04 柱塞泵停止,进行扰动,辅助清除柱塞泵内腔可能残留的气泡
  {
  ticks     = 200,
  valve     = {7, 8, 9},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x05 柱塞泵启动,进行扰动,辅助清除柱塞泵内腔可能残留的气泡
  {
  ticks     = 200,
  valve     = {7, 8, 9},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 300.0, rounds = 100000}
  },
-- 0x06 结束
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

-- 清洗V8-V10之间NovoRinse,同时浸泡Flowcell及样本管路
local TIMING_SUB_WashAwayNR = {
  name = "SUB-WashAwayNR",
-- 0x01 启动鞘液泵,将输送管路中的NovoRinse推到chamber及废液管路
  {
  ticks     = 3400,                   -- 3400ticks = 17s 3s释放chamber压力
  valve     = {7, 8},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 170.0}
  },
-- 0x02 用NovoFlow冲洗鞘液泵及输送管路
  {
  ticks     = 1000,                   -- 1000ticks = 5s
  valve     = {2, 7, 12},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000}
  },
-- 0x03 外置样本针上行
  {
  ticks     = 200,                    -- 200ticks = 1s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x04 外置样本针下行
  {
  ticks     = 1000,                   -- 1000ticks = 5s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4}
  },
-- 0x05 外置样本针下行
  {
  ticks     = 1000,                   -- 1000ticks = 5s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.15}
  },
-- 0x06 注射器复位,清洗chamber内腔及Flowcell
  {
  ticks     = 2000,                   -- 2000ticks = 10s
  valve     = {7, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x07 结束
  {
  ticks     = 10,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_WashAwayNR = {
  name = "IDX-WashAwayNR",
  0x01,                               -- 将输送管路中的NovoRinse推到chamber及废液管路
  0x02, 0x03, 0x04, 0x03, 0x05, 0x03, 0x04, 0x03, 0x05, 0x03,
  0x04, 0x03, 0x05, 0x03, 0x04, 0x03, 0x05, 0x03, 0x04,
                                      -- 用NovoFlow清洗V8—V10之间NovoRinse
  0x06,                               -- 注射器复位,清洗chamber内腔及Flowcell

  0x07                                -- 结束
}

-- 用于灌注的NovoRinse清洗流程
local TIMING_SUB_NovoRinse4Priming = {
  name = "SUB-NovoRinse4Priming",
-- 0x01 灌注filter5
  {
  ticks     = 6000,         -- 6000ticks = 30s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
-- 0x02 V6关闭扰动
  {
  ticks     = 20,           -- 20ticks = 0.1s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x03 V6打开扰动
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x04 灌注V4管路,注射器下拉至底部
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
-- 0x05 V4关闭扰动
  {
  ticks     = 20,           -- 20ticks = 0.1s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x06 用鞘液灌注注射器前面的管路,将气泡带入注射器,V4打开扰动,注射器上推扰动底部气泡
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 2.0}
  },
-- 0x07 用鞘液灌注注射器前面的管路,将气泡带入注射器,V4打开扰动,注射器下拉扰动底部气泡
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 2.0}
  },
-- 0x08 鞘液泵将NovoRinse运到Flow chamber,注射器复位
  {
  ticks     = 6000,         -- 6000ticks = 30s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x09 注射器将NovoRinse吸入内置样本管路(v2-chamber)、公共样本管路(V2-V1)一直吸入注射器中
  {
  ticks     = 1700,         -- 1700ticks = 8.5s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 2.0}
  },
-- 0x0a 注射器将NovoRinse推入flowcell
  {
  ticks     = 600,          -- 600ticks = 3s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -100.0, rounds = 20.0}
  },
-- 0x0b 柱塞泵停止,进行扰动,辅助清除柱塞泵内腔可能残留的气泡
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x0c 柱塞泵启动,进行扰动,辅助清除柱塞泵内腔可能残留的气泡
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
-- 0x0d 注射器在底部上推扰动
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 4.5},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
-- 0x0e 注射器在底部下吸扰动
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 4.5},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x0f 注射器将气泡从flowchamber推走
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
-- 0x10 鞘液泵提速
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
-- 0x11 v9关闭扰动
  {
  ticks     = 20,           -- 20ticks = 0.1s
  valve     = {7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x12 v9打开扰动
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x13 结束
  {
  ticks     = 100,          -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_NovoRinse4Priming = {
  name = "IDX-NovoRinse4Priming",
  0x01,                                   -- 灌注filter5
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03,
  0x02, 0x03, 0x02, 0x03,                 -- V6开关扰动

  0x04,                                   -- 注射器拉至底部, 灌注V4管路
  0x05, 0x06, 0x05, 0x07, 0x05, 0x06, 0x05, 0x07, 0x05, 0x06, 0x05, 0x07,
  0x05, 0x06, 0x05, 0x07, 0x05, 0x06, 0x05, 0x07, 0x05, 0x06, 0x05, 0x07,
                                          -- V4开关扰动, 注射器活塞上下扰动

  0x08,                                   -- 鞘液泵将NovoRinse运到Flow chamber
  0x09,                                   -- 将NovoRinse吸入注射器内腔
  0x0a,                                   -- 注射器将NovoRinse推入外置样本管路
  0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c,     -- 柱塞泵启动停止扰动内腔残留的气泡
  0x09,
  0x0a,
  0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c,
  0x09,
  0x0a,
  0x0b, 0x0c, 0x0b, 0x0c, 0x0b, 0x0c,
  0x09,

  0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e,
  0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e, 0x0d, 0x0e,
                                          -- 注射器活塞在底部上下扰动
  0x0f, 0x10,                             -- 注射器将气泡从flowchamber推走
  0x11, 0x12, 0x11, 0x12, 0x11, 0x12, 0x11, 0x12, 0x11, 0x12,
  0x11, 0x12, 0x11, 0x12, 0x11, 0x12, 0x11, 0x12, 0x11, 0x12,
                                          -- V9开关扰动flowchamber内的气泡
  0x13                                    -- 结束
}

-- NovoClean清洗流程
local TIMING_SUB_NovoCleanCleaning = {
  name = "SUB-NovoCleanCleaning",
--0x01 鞘液泵将NovoClean运到Flow chamber,用NovoClean对flowcell进行清洗
  {
  ticks     = 6000,         -- 6000ticks = 30s
  valve     = {7, 8, 9, 10},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x02 吸入隔离空气,防止NovoClean扩散到注射器内腔
  {
  ticks     = 800,          -- 800ticks = 4s
  valve     = {1, 7, 8, 9, 10, 12},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 40.0, rounds = 2.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 250.0}
  },
--0x03 将隔离空气推入内置样本管路
  {
  ticks     = 600,          -- 600ticks = 3s
  valve     = {7, 8, 9, 10},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -55.0, rounds = 2.0}
  },
--0x04 用注射器将NovoClean吸入公共样本管路
  {
  ticks     = 2400,         -- 2400ticks = 12s
  valve     = {7, 8, 9, 10},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 40.0, rounds = 6.5}   -- 隔离空气距注射器100mm
  },
--0x05 将NovoClean推入外置样本管路
  {
  ticks     = 1000,         -- 1000ticks = 5s 等待隔离空气恢复变形
  valve     = {1, 7, 8, 9, 10},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -50.0, rounds = 2.0},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x06 结束
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

-- 清洗V8-V10之间NovoClean,同时浸泡Flowcell及样本管路
local TIMING_SUB_WashAwayNC = {
  name = "SUB-WashAwayNC",
--0x01 启动鞘液泵,用NovoRinse填充V10-V11之间管路
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {7, 8, 9},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 135.0}
  },
--0x02 用NovoFlow将NovoClean从输送管路推到chamber及废液管路
  {
  ticks     = 1600,         -- 1600ticks = 8s
  valve     = {7, 8},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4}
  },
--0x03 用NovoFlow冲洗掉管路中的NovoClean&NovoRinse
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {2, 7, 12},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000}
  },
--0x04 外置样本针上行,用NovoFlow冲洗掉管路中的NovoRinse
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 外置样本针下行,针尖探出拭子
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4}
  },
--0x06 外置样本针下行,针尖停在拭子中
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.15}
  },
--0x07 将NovoClean推到V9与废液桶之间
  {
  ticks     = 5000,         -- 5000ticks = 25s
  valve     = {7, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x08 释放chamber压力
  {
  ticks     = 600,          -- 600ticks = 3s
  valve     = {7, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 注射器复位,清洗chamber内腔及Flowcell
  {
  ticks     = 3000,         -- 3000ticks = 15s
  valve     = {7, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x0a 结束
  {
  ticks     = 10,           -- 10ticks = 50ms
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_WashAwayNC = {
  name = "IDX-WashAwayNC",
  0x01,             -- 用NovoRinse清洗V10—V11之间管路
  0x02,             -- 用NovoFlow将NovoClean从输送管路推到chamber及废液管路
  0x03,
  0x04, 0x05, 0x04, 0x06, 0x04, 0x05, 0x04, 0x06, 0x04, 0x05,
  0x04, 0x06, 0x04, 0x05, 0x04, 0x06, 0x04, 0x05, 0x04, 0x06,
  0x04, 0x05, 0x04, 0x06, 0x04, 0x05, 0x04, 0x06, 0x04, 0x05,
                    -- 用NovoFlow冲洗掉管路中的NovoClean&NovoRinse
  0x07, 0x08,       -- 将NovoClean推到V9与废液桶之间
  0x03, 0x04, 0x06, 0x04, 0x05, 0x04, 0x06,
                    -- 用NovoFlow冲洗掉管路中的NovoClean&NovoRinse

  0x09,             -- 注射器复位,用NovoFlow清洗Flowchamber

  0x0a              -- 结束
}

-- 反冲
local TIMING_SUB_Backflush = {
  name = "SUB-Backflush",
--0x01 启动鞘液泵,打开电磁阀
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x02 注射器活塞下行,为向外置样本针反推液体做准备
  {
  ticks     = 500,          -- 500ticks = 2.5s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 5.0}
  },
--0x03 将鞘液泵输送的液体切换到鞘液管路
  {
  ticks     = 100,          -- 100ticks = 0.5s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 用注射器冲洗外置样本管路
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {1, 5, 8, 12},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -65.0, rounds = 5.0}
  },
--0x05 将鞘液泵输送的液体切换到样本管路
  {
  ticks     = 100,          -- 100ticks = 0.5s
  valve     = {3, 8, 12},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x06 冲洗flowcell
  {
  ticks     = 3000,         -- 3000ticks = 15s
  valve     = {5, 8, 12},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 打开V3之前,释放压力
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x08 清洗外置样本管外壁
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {2, 5, 12},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x09 泵停止,释放压力
  {
  ticks     = 600,          -- 600ticks = 3s
  valve     = {2, 3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0a 电磁阀关闭
  {
  ticks     = 100,          -- 100ticks = 0.5s
  valve     = {12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0b 结束
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

-- 排气泡
local TIMING_SUB_Debubble = {
  name = "SUB-Debubble",
--0x01 开启鞘液泵&电磁阀
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x02 外置样本针下行
  {
  ticks     = 260,          -- 260ticks = 1.3s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0},  -- auto rounds
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 吸入75%酒精
  {
  ticks     = 560,          -- 560ticks = 2.8s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 50.0, rounds = 2.0}
  },
--0x04 V2关闭
  {
  ticks     = 20,           -- 20ticks = 0.1s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x05 将酒精推入flow cell
  {
  ticks     = 560,          -- 560ticks = 2.8s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -50.0, rounds = 2.0}
  },
--0x06 吸入75%酒精
  {
  ticks     = 560,          -- 560ticks = 2.8s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 50.0, rounds = 2.0}
  },
--0x07 V2关闭
  {
  ticks     = 20,           -- 20ticks = 0.1s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x08 将酒精推入flow cell
  {
  ticks     = 560,          -- 560ticks = 2.8s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -50.0, rounds = 2.0}
  },
--0x09 V2打开
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0a 吸入75%酒精
  {
  ticks     = 560,          -- 560ticks = 2.8s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 50.0, rounds = 2.0}
  },
--0x0b 浸泡2min
  {
  ticks     = 24000,        -- 24000ticks = 120s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0c 将酒精推入flow cell
  {
  ticks     = 560,          -- 560ticks = 2.8s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -50.0, rounds = 2.0}
  },
--0x0d 冲洗内置样本管10s
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0e 外置样本针复位
  {
  ticks     = 280,          -- 280ticks = 1.4s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0f 外置样本针下行
  {
  ticks     = 800,          -- 800ticks = 4s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x10 提前关闭V3
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x11 外置样本针复位
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x12 清洗外置样本针内壁
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 271.0, rounds = 100000}
  },
--0x13 泵停止释放压力
  {
  ticks     = 600,          -- 600ticks = 3s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x14 结束
  {
  ticks     = 100,          -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- 100uL测试
local TIMING_SUB_Ration100uL = {
  name = "SUB-Ration100uL",
--0x01 电磁阀打开,鞘液泵启动,提前建立压力
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
--0x02 注射器拉到流体零点
  {
  beginhook = function (self, item)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 300,          -- 300ticks = 1.5s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*100.0, rounds = 2.4}
  },
--0x03 释放V4-V2之间压力
  {
  ticks     = 240,          -- 240ticks = 1.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 鞘液泵启动,阀开启
  {
  ticks     = 100,          -- 100ticks = 0.5s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = config.pmotor.omega, rounds = 100000}
  },
--0x05 v2打开
  {
  ticks     = 100,          -- 100ticks = 0.5s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x06 外置样本针下行
  {
  beginhook = function (self, item)
    item.smotor.rounds = config.smotor.lowrounds
  end,
  ticks     = 60,           -- 60ticks = 0.3s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0},  -- auto rounds
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 外置样本针下行过程中,吸入20ul隔离空气
  {
  beginhook = function (self, item)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 80,           -- 80ticks = 0.4s
  valve     = {1, 5, 8, 12},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 1000, omega = PULL*120.0, rounds = 0.4}
  },
--0x08 样本针探入样本中
  {
  ticks     = 180,          -- 180ticks = 0.9s
  valve     = {1, 5, 8, 12},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 吸入样本
  { -- todo: 注射器rounds
  beginhook = function (self, item)
    local _,size = subwork:sampleinfo()
    local extsize = config.imotor.boostrounds[TimingConst.TEST_IS_ABS]
    local omega = math.abs(item.imotor.omega)
    local extticks = omega / item.imotor.alpha * 2 * tmr.tickspersec() + 20
    item.ticks = (size + extsize) * (tmr.tickspermin()/config.imotor.volumperround)/omega + extticks;
    item.imotor.rounds = (size+extsize)/config.imotor.volumperround
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 340,          -- 340ticks = 1.7s  时间由Alex根据采样量控制,留有100ms余量
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PULL*40.0}
  },
--0x0a 针插在样本中,等待第一段隔离空气恢复变形,保证吸的样本量准确
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0b 外置样本针上行
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
--0x0d 将样本吸入公共样本管路
  {
  beginhook = function (self, item)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 640,          -- 640ticks = 3.2s
  valve     = {1, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PULL*40.0, rounds = 1.98}   -- v2容积从9ul更新为18ul/第二段隔离空气最小量从20降为10 20140418陈
  },
--0x0e 为boost时,减小压力峰值做准备,将鞘液泵转速降低为正常转速的88%
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
--0x0f 快速boost,将样本从公共样本管路推入flow cell
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
  ticks     = 1400,         -- 1400ticks = 7s,计算所得,时间预留50ms
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 25, omega = PUSH*55.0, rounds = 4.16}  -- 第二段隔离空气最小量从20降为10, rounds从配置获取
  },
--0x10 鞘液泵恢复正常转速
  {
  ticks     = 10,           -- 10ticks = 50ms
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = config.pmotor.omega}
  },
--0x11 boost后,进入流量第一次稳定期,注射器流量固定为35ul/min
  {
  beginhook = function (self, item)
    self.idr = self.idr + PUSH * item.imotor.rounds
  end,
  ticks     = 700,          -- 700ticks = 3.5s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*0.7*config.pmotor.omega, rounds = 0.05}
  },
--0x12 boost后,进入流量第二次稳定期,注射器流量与用户设定的样本流量相同
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
--0x13 正式测试,开始采集数据
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
--0x14 测试停止
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
--0x15 测试结束,注射器从内置样本针推走剩余样本及隔离空气,同时注射器活塞到达光耦
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

-- 100uL测试PID时序表
local TIMING_SUB_PIDRation100uL = {
  name = "SUB-PIDRation100uL",
--0x01 外置样本针下行
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step1      -- set step to step1
    --@ 忽略撞针检查
    self.idr  = 0
  end,
  ticks     = 30,            -- 30ticks = 0.15s,保证样本针尖露出拭子
  valve     = {6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = 150, rounds = config.smotor.lowrounds},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 650, rounds = 100000}
  },
--0x02 外置样本针下行过程中,吸入10uL隔离空气
  {
  beginhook = function (self, item)
    self.idr  = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 160,            -- 160ticks = 0.8s,保证样本针尖到达试管底部
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 1000, omega = PULL * 120.0, rounds = 0.3}  -- 去除注射器回程差
  },
--0x03 吸入样本
  {
  beginhook = function (self, item)
  	--@ 设置吸入样本量为用户设定测试量相同
    item.imotor.rounds = config.compensation[self.testsel].size + volum / config.imotor.volumperround
    --@ testsel表示TimingConst.TEST_IS_ABS或TimingConst.TEST_IS_PID
    --@ volum表示用户设定的测试体积,需要进行单位换算,1 round = 50 uL
  end,
  ticks     = 900,            -- 900ticks = 4.5s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PULL * 40, rounds = 2.6 }
  },
--0x04 外置样本针复位
  {
  beginhook = function (self, item)
    --@ 开启撞针检查
  end,
  ticks     = 120,            -- 900ticks = 0.6s
  valve     = {2, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = DN * (config.smotor.lowrounds - 0.4)}
  },
--0x05 将样本吸入公共样本管路
  {
  ticks     = 300,            -- 300ticks = 1.5s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PULL * 100.0, rounds = 1.75 }
  },
--[[
--0x06 将样本吸入公共样本管路
  {
    --@ 设置STATE为boosting1,
  ticks     = 260,            -- 260ticks = 1.3s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = -100.0, rounds = 1.75}
  },
--]]
--0x07 将样本boost到flowcell检测区
  {
  beginhook = function (self, item)
    item.imotor.rounds = config.imotor.boostrounds[self.testsel]
  end,
  ticks     = 40,            -- 40ticks = 0.2s
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PUSH * 100.0, rounds = 0.6}
  },
--0x08 PID调整鞘液压力开始
  {
  beginhook = function (self, item)
    subwork:pidcontrol(TimingConst.PID_Start)
  end,
  ticks     = 600,            -- 600ticks = 3.0s
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PUSH * 100.0, rounds = 1.75}
  },
--0x09 PID调整鞘液压力结束
  {
  beginhook = function (self, item)
    subwork:pidcontrol(TimingConst.PID_Stop)
  end,
  ticks     = 5,            -- 5ticks = 25ms
  valve     = {6, 9, 13}
  },
--0x0A 鞘液流量恢复为标准流量
  {
  ticks     = 45,            -- 45ticks = 225ms
  valve     = {6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = config.pmotor.omega}
  },
--0x0B 以正常测试过程状态稳定1S
  {
  beginhook = function (self, item)
  	--@ 注射器速度设定为用户设置的样本流速 ACTION_Stable
    item.imotor.omega = sample_speed * config.compensation[self.testsel].coef[config.instrumenttype]
    --sel表示TimingConst.TEST_IS_ABS或TimingConst.INSTRUMENT_IS_IVD
    -- sample_speed代表用户设定的样本流速,需要进行单位换算
    --@ state设定为stable STATE_Stable
  end,
  ticks     = 200,            -- 20ticks = 1s
  valve     = {6, 9},
  imotor    = {op = TimingConst.MOTOR_CHSPEED, alpha = 4800, omega = PUSH * 0.28},
  },
--0x0C 正式测试
  {
  beginhook = function (self, item)
    --@ state设定为START ACTION_Start
    --@ 时间控制根据实际测试情况计算
    --item.ticks = ?   --@ 如何定义？
  	--@ 注射器速度设定为用户设置的样本流速 ACTION_Stable
    item.imotor.omega = sample_speed * sample_speed * config.compensation[self.testsel].coef[config.instrumenttype]
    -- sample_speed代表用户设定的样本流速,需要进行单位换算
    --@ 注射器总转数设定为用户设置的测试体积
    item.imotor.rounds = volum / 50
    -- volum表示用户设定的测试体积,需要进行单位换算,1 round = 50 uL
  end,
  ticks     = 85715,            -- 85715ticks = 428.57s
  valve     = {6, 9},
  imotor    = {op = TimingConst.MOTOR_CHSPEED, alpha = 4800, omega = PUSH * 0.28, rounds = 2.0}
  },
--[[
--0x0D 用户点停止时,执行的推样本动作
  {
  --@ 这部分功能要如何实现？
  ticks     = 45,            -- 45ticks = 225ms
  valve     = {6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega_factor = 1.0}
  },
--]]
--0x0E 测试停止
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Resettting    -- set state to resetting
    self.ref2 = 0
  end,
  ticks     = 5,            -- 5ticks = 25ms
  valve     = {6, 9, 13}
  },
--0x0F 处理残余样本
  {
  beginhook = function (self, item)
    --@ 计算注射器需要上推的圈数及耗时
    tiem.ticks = (rounds + 0.3) /  item.imotor.omega
    item.imotor.rounds = rounds + 0.3 --@rounds是整个测试过程中注射器吸推动余量,需要计算获取
  end,
  ticks     = 100,            -- 100ticks = 0.5s
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_CHSPEED, alpha = 4800, omega = PUSH * 200, rounds = 2.0}
  }
}

-- 导管公差校准流程
local TIMING_SUB_AdjustNormal = {
  name = "SUB-AdjustNormal"
}

-- 测试流程结束后不清洗执行流程
local TIMING_SUB_TestCleanNone = {
  name = "SUB-TestCleanNone",
--0x01 外置样本管路填充,同时外置样本针上行
  {
  state     = TimingConst.MEASURE_Reset,
  ticks     = 500,          -- 500ticks = 2.5s
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x02 v2关闭,外置样本针下行,鞘液泵停止
  {
  state     = TimingConst.MEASURE_Reset,
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 鞘液泵复位,释放压力
  {
  state     = TimingConst.MEASURE_Reset,
  ticks     = 200,          -- 200ticks = 1s
  valve     = {2, 3, 5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x04 v3提前关闭
  {
  state     = TimingConst.MEASURE_Reset,
  ticks     = 30,           -- 30ticks = 0.15s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 所有阀关闭,结束
  {
  state     = TimingConst.MEASURE_Reset,
  ticks     = 10            -- 10ticks = 50ms
  }
}

-- 测试流程结束后的首次清洗流程
local TIMING_SUB_TestCleanFirst = {
  name = "SUB-TestCleanFirst",
--0x01 内置样本针内壁清洗
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 800,          -- 800ticks = 4s
  valve     = {3, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 542.0}
  },
--0x02 外置样本针上行,同时进行外壁清洗
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = 15.0, rounds = 0.4}
  },
--0x03 样本针下行,同时进行外壁清洗
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 15.0, rounds = 0.35}
  },
--0x04 关闭v3,同时样本针复位
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 外置样本针内壁清洗
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 1500,          -- 1500ticks = 7.5s
  valve     = {1, 3, 8, 12}
  },
--0x06 鞘液泵停止
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 80,          -- 80ticks = 0.4s
  valve     = {3, 5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 样本针下行,鞘液泵复位
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 320,          -- 320ticks = 1.6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x08 v3开启释放压力
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 200,          -- 200ticks = 1s
  valve     = {2, 3, 5, 8, 12}
  },
--0x09 V3关闭,外置样本针复位
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x0a 所有阀关闭,鞘液泵停止,结束
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 10,          -- 10ticks = 50ms
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- 测试流程结束后的多次清洗流程
local TIMING_SUB_TestCleanOthers = {
  name = "SUB-TestCleanOthers",
--0x01 内置样本针内壁清洗
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 800,          -- 800ticks = 4s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000}
  },
--0x02 外置样本针上行,同时进行外壁清洗
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = 15.0, rounds = 0.4}
  },
--0x03 样本针下行,同时进行外壁清洗
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -15.0, rounds = 0.35}
  },
--0x04 关闭v3,同时样本针复位
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 外置样本针内壁清洗
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 1000,          -- 1000ticks = 5s
  valve     = {1, 3, 8, 12}
  },
--0x06 鞘液泵停止
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 80,          -- 80ticks = 0.4s
  valve     = {3, 5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 样本针下行,鞘液泵复位
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 320,          -- 320ticks = 1.6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x08 v3开启释放压力
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 200,          -- 200ticks = 1s
  valve     = {2, 3, 5, 8, 12}
  },
--0x09 V3关闭,外置样本针复位
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x0a 所有阀关闭,鞘液泵停止,结束
  {
  state     = TimingConst.MEASURE_Washing,
  ticks     = 10,          -- 10ticks = 50ms
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- 撞针后的复位清洗流程
local TIMING_SUB_SIPHitClean = {
  name = "SUB-SIPHitClean",
--0x01 复位
  {
  state     = TimingConst.MEASURE_Boosting1,
  ticks     = 60,           -- 60ticks = 0.3s
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}, -- acc = acc or DEFAULT_ACC
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = config.pmotor.omega, rounds = 100000}
  },
--0x02 外置样本针内壁清洗
  {
  state     = TimingConst.MEASURE_Boosting1,
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {1, 3, 8, 12}
  },
--0x03 鞘液泵停止
  {
  state     = TimingConst.MEASURE_Boosting1,
  ticks     = 80,           -- 80ticks = 0.4s
  valve     = {3, 5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 样本针下行,鞘液泵复位
  {
  state     = TimingConst.MEASURE_Boosting1,
  ticks     = 320,           -- 320ticks = 1.6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4}, -- acc = acc or DEFAULT_ACC
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 v3开启释放压力
  {
  state     = TimingConst.MEASURE_Boosting1,
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 3, 5, 8, 12}
  },
--0x06 V3关闭,外置样本针复位
  {
  state     = TimingConst.MEASURE_Boosting1,
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x07 所有阀关闭,鞘液泵停止,结束
  {
  state     = TimingConst.MEASURE_Boosting1,
  ticks     = 10,           -- 10ticks = 50ms
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- 首次灌注----机器长途运输或长时间不使用,需要排空,再度装机或使用前进行首次灌注
-- InitPriming step 1: 鞘液管路、样本管路灌注
local TIMING_SUB_InitPrimingStep1 = {
  name = "SUB-InitPrimingStep1",
--0x01 灌注注射器内腔及内置样本管路、flowchamber及flowchamber废液管路
  {
  ticks     = 64000,           -- 64000ticks = 320s 灌注5倍
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x02 灌注外置样本管路
  {
  ticks     = 1000,           -- 1000ticks = 5s 灌注5倍
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x03 灌注NovoClean桶到V11
  {
  ticks     = 7000,           -- 7000ticks = 35s 灌注量是NovoRinse到flowchamber侧口容积的1.5倍
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x04 灌注NovoRinse桶到flowchamber侧口管路
  {
  ticks     = 28000,           -- 28000ticks = 140s 灌注量是NovoRinse到flowchamber侧口容积的2倍
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x05 用鞘液冲洗NovoRinse输送管路
  {
  ticks     = 14000,           -- 14000ticks = 70s 冲洗V10到flowchamber侧口2倍
  valve     = {7, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x06 释放chamber压力
  {
  ticks     = 1200,           -- 1200ticks = 6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 灌注鞘液管路
  {
  ticks     = 16000,           -- 16000ticks = 80s 灌注2倍
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x08 停止鞘液泵,释放压力
  {
  ticks     = 1600,           -- 1600ticks = 8s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 将电磁阀关闭
  {
  ticks     = 100           -- 100ticks = 0.5s
  }
}

local TIMING_IDX_InitPrimingStep1 = {
  name = "IDX-InitPrimingStep1",
  -- 灌注注射器内腔及内置样本管路、flowchamber及flowchamber废液管路
  0x01,
  -- 灌注外置样本管路
  0x02,
  -- 灌注NovoClean管路
  0x03,
  -- 灌注NovoRinse管路
  0x04,
  -- 冲洗NovoRinse输送管路
  0x05, 0x06,
  -- 灌注鞘液管路
  0x07,
  -- 停止鞘液泵,将电磁阀复位
  0x08, 0x09
}

-- InitPriming step 2: 压力传感器2管路灌注
local TIMING_SUB_InitPrimingStep2 = {
  name = "SUB-InitPrimingStep2",
--0x01 启动鞘液泵
  {
  ticks     = 6000,           -- 6000ticks = 30s 灌注10倍
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x02 停止鞘液泵
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- InitPriming step 3: 压力传感器1灌注
local TIMING_SUB_InitPrimingStep3 = {
  name = "SUB-InitPrimingStep3",
--0x01 将V8上电,启动鞘液泵
  {
  ticks     = 7000,           -- 7000ticks = 35s 灌注10倍
  valve     = {5},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x02 停止鞘液泵,将电磁阀复位
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- InitPriming step 4: dummy
local TIMING_SUB_InitPrimingStep4 = {
  name = "SUB-InitPrimingStep4",
-- 0x01 等待下一个命令
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- 排空----机器长途运输或长时间不使用,需要排空
-- Drain step 1: 用超纯水冲洗管路
local TIMING_SUB_DrainStep1 = {
  name = "SUB-DrainStep1",
--0x01 冲洗NovoClean管路
  {
  ticks     = 52000,           -- 52000ticks = 260s 从NovoClean桶>鞘液泵>V11 冲洗10倍
  valve     = {7, 8, 9, 10},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x02 冲洗NovoRinse管路
  {
  ticks     = 84000,           -- 84000ticks = 420s 从NovoRinse桶>鞘液泵>NovoRinse输送管路>chamber>废液桶 冲洗10倍
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 用超纯水冲洗注射器内腔及样本管路
  {
  ticks     = 260000,           -- 260000ticks = 1300s 冲洗20倍
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 注射器下拉扰动内腔中的死区
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 5.0}
  },
--0x05 注射器上推扰动内腔中的死区
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 5.0}
  },
--0x06 释放压力
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {3, 5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 用超纯水冲洗外置样本管路
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 271.0, rounds = 100000}
  },
--0x08 释放压力
  {
  ticks     = 800,           -- 800ticks = 4s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 外置样本针下行
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0a 冲洗鞘液管路
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x0b 外置样本针复位
  {
  ticks     = 77000,           -- 77000ticks = 385s 冲洗10倍
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0c 外置样本针下行
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0d 释放压力
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {2, 3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0e V3关闭
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0f 外置样本针复位,结束
  {
  ticks     = 200,           -- 200ticks = 1s
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DrainStep1 = {
  name = "IDX-DrainStep1",
  -- NovoClean桶>>v11 冲洗10倍
  0x01,
  -- NovoRinse桶>鞘液泵>NovoRinse输送管路>chamber侧口 冲洗10倍
  0x02,
  -- 鞘液桶>鞘液泵>注射器>chamber>V9>废液管路冲洗20倍
  0x03,
  -- 鞘液桶>鞘液泵>注射器>chamber>V9>废液管路冲洗10倍,注射器吸排扰动126次
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
  -- 鞘液桶>鞘液泵>注射器>V2>外置样本管冲洗,液体量为“外置样本管+外置样本针容积”30倍
  0x06, 0x07, 0x08, 0x09,
  -- 鞘液桶>鞘液泵>damper>flow chamber>V3>拭子管路冲洗10倍
  0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
}

-- Drain step 2: 用超纯水冲洗P2管路
local TIMING_SUB_DrainStep2 = {
  name = "SUB-DrainStep2",
--0x01 将V8上电,启动鞘液泵
  {
  ticks     = 6000,           -- 6000ticks = 30s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x02 停止鞘液泵,将所有电磁阀断电复位
  {
  ticks     = 100,           -- 100ticks = 0.5s
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- Drain step 3: 用超纯水冲洗P1管路
local TIMING_SUB_DrainStep3 = {
  name = "SUB-DrainStep3",
--0x01 将V6、V8上电,启动鞘液泵
  {
  ticks     = 7000,           -- 7000ticks = 35s
  valve     = {5},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x02 停止鞘液泵,将所有电磁阀断电复位
  {
  ticks     = 100,           -- 100ticks = 0.5s
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
}

-- Drain step 4: NovoClean管路、NovoRinse管路、样本管路、鞘液管路排空
local TIMING_SUB_DrainStep4 = {
  name = "SUB-DrainStep4",
--0x01 排空NovoClean管路
  {
  ticks     = 16000,           -- 16000ticks = 80s 从NovoClean桶>v11 排空3倍
  valve     = {7, 8, 9, 10},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x02 排空NovoRinse管路
  {
  ticks     = 26000,           -- 26000ticks = 130s 从NovoRinse桶>鞘液泵>NovoRinse输送管路>chamber侧口 排空3倍
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 排空注射器内腔及内置样本管路、flowchamber及flowchamber废液管路
  {
  ticks     = 64000,           -- 64000ticks = 320s 排空3倍
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 排空外置样本管路
  {
  ticks     = 4000,           -- 4000ticks = 20s 排空10倍
  valve     = {1, 3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 271.0, rounds = 100000}
  },
--0x05 外置样本针下行
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x06 排空鞘液管路
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x07 外置样本针复位
  {
  ticks     = 23000,           -- 23000ticks = 115s 排空3倍
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x08 外置样本针下行
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 V3关闭,针复位
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {5, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0a 废液泵吸拭子的废液管路
  {
  ticks     = 1600,           -- 1600ticks = 8s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0b 废液泵停止吸液,让拭子废液管路中的液体聚集,以便下一次被吸走
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {3, 5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0c 注射器推到光耦位置
  {
  ticks     = 2700,           -- 2700ticks = 13.5s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x0d 停止鞘液泵,将所有电磁阀断电复位,停止废液泵,结束
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DrainStep4 = {
  name = "IDX-DrainStep4",
  -- NovoClean桶>v11 排空3倍
  0x01,
  -- NovoRinse桶>鞘液泵>NovoRinse输送管路>chamber侧口 排空3倍
  0x02,
  -- 鞘液桶>鞘液泵>注射器>chamber>V9>废液管路排空3倍
  0x03,
  -- 鞘液桶>鞘液泵>注射器>V2>外置样本管冲洗,排空外置样本管路3倍
  0x04,
  -- 鞘液桶>鞘液泵>damper>flow chamber>V3>拭子管路冲洗10倍
  0x05, 0x06, 0x07, 0x08, 0x09,
  -- 吸干拭子的废液管路
  0x0A, 0x09, 0x0A, 0x09, 0x0A, 0x0B,
  -- 注射器复位到光耦,结束
  0x0C, 0x0D
}

-- Drain step 5: P2排空
local TIMING_SUB_DrainStep5 = {
  name = "SUB-DrainStep5",
--0x01 启动鞘液泵
  {
  ticks     = 6000,           -- 6000ticks = 30s 排空10倍
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 10000000}
  },
--0x02 停止鞘液泵,将所有电磁阀断电复位
  {
  ticks     = 100,           -- 100ticks = 0.5s
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- Drain step 6: P1排空
local TIMING_SUB_DrainStep6 = {
  name = "SUB-DrainStep6",
--0x01 将V6上电,启动鞘液泵
  {
  ticks     = 7000,           -- 7000ticks = 35s 排空10倍
  valve     = {5},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 1000000}
  },
--0x02 停止鞘液泵,将所有电磁阀断电复位
  {
  ticks     = 100,           -- 100ticks = 0.5s
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03
  {
  ticks     = 1200,           -- 1200ticks = 6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -225.0, rounds = 22.0}, -- 保证注射器在最底部也能复位
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x04 将所有电磁阀断电复位
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- 消毒----机器使用一段时间后滋生细菌,需要消毒
-- Decontamination step 1: 将NovoClean引入仪器管路
local TIMING_SUB_DeconStep1 = {
  name = "SUB-DeconStep1",
--0x01 启动鞘液泵,消毒注射器管路
  {
  ticks     = 42000,           -- 42000ticks = 210s 鞘液量=22.75ml
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 1000000}
  },
--0x02 浸泡8、3、13管路
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 542.0}
  },
--0x03 浸泡鞘液管路6、3、13
  {
  ticks     = 18000,           -- 18000ticks = 90s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x04 浸泡外置样本管
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x05 鞘液泵转速提高
  {
  ticks     = 42000,           -- 42000ticks = 210s 鞘液量=22.75ml
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x06 停止鞘液泵
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
  imotor    = {op = TimingConst.MOTOR_RESET}, -- 默认复位速度100rpm,保证注射器在最底部也能复位
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 420.0, rounds = 35.0}
  },
--0x08
  {
  ticks     = 1400,           -- 1400ticks = 7s
  valve     = {3, 5, 7, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x09 结束
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DeconStep1 = {
  name = "IDX-DeconStep1",
  0x07, 0x08, 0x09,      -- 复位

  0x01, 0x02, 0x03, 0x04,
  0x05, 0x02, 0x03, 0x04,

  0x06, 0x09
}

-- Decontamination step 2: 将NovoClean引入压力传感器1管路（U1）
local TIMING_SUB_DeconStep2 = {
  name = "SUB-DeconStep2",
--0x01 启动鞘液泵,浸泡Pressure1管路
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {5},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 1000000.0}
  },
--0x02 停止鞘液泵
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 结束
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

-- Decontamination step 3: 将NovoClean引入压力传感器2管路（U2）
local TIMING_SUB_DeconStep3 = {
  name = "SUB-DeconStep3",
--0x01 启动鞘液泵,浸泡Pressure2管路
  {
  ticks     = 6000,           -- 6000ticks = 30s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 1000000.0}
  },
--0x02 停止鞘液泵
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 结束
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

-- Decontamination step 4: NovoClean浸泡管路,进行杀菌消毒
local TIMING_SUB_DeconStep4 = {
  name = "SUB-DeconStep4",
--0x01 开启V4、V6、V8浸泡4min
  {
  ticks     = 48000,           -- 48000ticks = 240s
  valve     = {3, 5, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x02 关闭V4、V6、V8浸泡2min
  {
  ticks     = 24000,           -- 24000ticks = 120s
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 结束
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

-- Decontamination step 5-1: 清洗注射器内腔,针对浸泡时间短于45min
local TIMING_SUB_DeconStep5_1 = {
  name = "SUB-DeconStep5_1",
--0x01 启动鞘液泵
  {
  ticks     = 24000,           -- 24000ticks = 120s 鞘液量=13ml
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
  ticks     = 6000,           -- 6000ticks = 30s  3、8、13管路
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000}
  },
--0x04 关V6扰动
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x05 开V6扰动
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {5, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x06 开V6冲洗
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {5, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 冲洗8、9管路
  {
  ticks     = 3000,           -- 3000ticks = 15s
  valve     = {7, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x08 冲洗8、3、13管路
  {
  ticks     =3000,           -- 3000ticks = 15s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000}
  },
--0x09 冲洗pressure2管路
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
--0x0b 注射器下拉,引入NovoRinse
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x0c 注射器上推
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x0d 关V4扰动
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0e 开V4扰动
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0f 开V4扰动
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x10 注射器下拉,引入气泡,增加扰动
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x11 注射器上推,走V9
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x12 注射器上推,走V3、13
  {
  ticks     = 1700,           -- 2000ticks = 10s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x13 启动鞘液泵,灌注注射器
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000}
  },
--0x14 注射器上推,灌注注射器
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x15 注射器下拉,灌注注射器
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x16 关V4扰动
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x17 开V4扰动
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x18 开V4扰动
  {
  ticks     = 12000,           -- 12000ticks = 60s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x19 启动鞘液泵
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
--0x1c 关V6扰动
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1d 冲洗pressure2管路
  {
  ticks     = 3000,           -- 3000ticks = 15s
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1e 释放压力
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1f 结束
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DeconStep5_1 = {
  name = "IDX-DeconStep5_1",
  0x01, 0x02, 0x1E, 0x03,                                        -- 冲洗鞘液管路

  0x04, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x07, 0x1E, 0x08,
  0x04, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x07, 0x1E, 0x08,
  0x09,
  -- 循环1-1
  0x0A,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  -- 循环2-1
  0x10, 0x11, 0x10, 0x11, 0x10, 0x11,                             -- 排空灌注注射器
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
  -- 循环3-1
  0x06, 0x19, 0x1E, 0x1B, 0x04,
  0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x19, 0x1E, 0x1B, 0x04,
  0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x19, 0x1E, 0x1B, 0x09,
  -- 循环2-2
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

  0x1E, 0x1F                                 -- 释放压力
}

-- Decontamination step 5-2: 清洗注射器内腔,针对浸泡时间长于45min
local TIMING_SUB_DeconStep5_2 = {
  name = "SUB-DeconStep5_2",
--0x01 启动鞘液泵
  {
  ticks     = 24000,           -- 24000ticks = 120s 鞘液量=13ml
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
  ticks     = 6000,           -- 6000ticks = 30s  3、8、13管路
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000.0}
  },
--0x04 关V6扰动
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x05 开V6扰动
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {5, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x06 开V6冲洗
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {5, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 冲洗8、9管路
  {
  ticks     = 3000,           -- 3000ticks = 15s
  valve     = {7, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x08 冲洗8、3、13管路
  {
  ticks     = 3000,           -- 3000ticks = 15s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 542.0, rounds = 100000.0}
  },
--0x09 冲洗pressure2管路
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
--0x0b 注射器下拉,引入NovoRinse
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x0c 注射器上推
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x0d 关V4扰动
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0e 开V4扰动
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0f 开V4扰动
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x10 注射器下拉,引入气泡,增加扰动
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x11 注射器上推,走V9
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x12 注射器上推,走V3、13
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x13 启动鞘液泵,灌注注射器
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000.0}
  },
--0x14 注射器上推,灌注注射器
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0}
  },
--0x15 注射器下拉,灌注注射器
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x16 关V4扰动
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x17 开V4扰动
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x18 开V4扰动
  {
  ticks     = 12000,           -- 12000ticks = 60s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x19 启动鞘液泵
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
--0x1c 关V6扰动
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1d 冲洗pressure2管路
  {
  ticks     = 3000,           -- 3000ticks = 15s
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1e 释放压力
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1f 结束
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DeconStep5_2 = {
  name = "IDX-DeconStep5_2",
  0x01, 0x02, 0x1E, 0x03,                                        -- 冲洗鞘液管路

  0x04, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x07, 0x1E, 0x08,
  0x04, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x07, 0x1E, 0x08,
  0x09,
  -- 循环1-1
  0x0A,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  -- 循环2-1
  0x10, 0x11, 0x10, 0x11, 0x10, 0x11,                             -- 排空灌注注射器
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
  -- 循环1-2
  0x0A,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  0x0B, 0x0C, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0E, 0x0D, 0x0F,
  -- 循环2-2
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
  -- 循环3-1
  0x06, 0x19, 0x1E, 0x1B, 0x04,
  0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x19, 0x1E, 0x1B, 0x04,
  0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x19, 0x1E, 0x1B, 0x09,
  -- 循环2-3
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
  -- 循环3-2
  0x06, 0x19, 0x1E, 0x1B, 0x04,
  0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x19, 0x1E, 0x1B, 0x04,
  0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C, 0x05, 0x1C,
  0x06, 0x19, 0x1E, 0x1B, 0x09,
  -- 循环2-4
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

  0x1E, 0x1F                                  -- 释放压力
}

-- Decontamination step 6-1: 清洗chamber,针对浸泡短于45min
local TIMING_SUB_DeconStep6_1 = {
  name = "SUB-DeconStep6_1",
--0x01 启动鞘液泵 冲洗外置样本管
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 271.0, rounds = 100000.0}
  },
--0x02 启动鞘液泵 引入Novorinse进Chamber
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x03 注射器下拉,引入气泡
  {
  ticks     = 900,           -- 900ticks = 4.5s
  valve     = {1},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 10.0},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 注射器上推,走V9排气泡
  {
  ticks     = 900,           -- 900ticks = 4.5s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 10.0}
  },
--0x05 注射器上推,走V3、V13排气泡
  {
  ticks     = 900,           -- 900ticks = 4.5s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 10.0}
  },
--0x06 启动鞘液泵 冲洗4、3、13管路
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x07 注射器下拉,冲洗4、3、13管路
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x08 关V4扰动,冲洗4、3、13管路
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 开V4扰动,冲洗4、3、13管路
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0a 开V4扰动,冲洗4、3、13管路
  {
  ticks     = 400,           -- 400ticks = 2s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0b 注射器上推,冲洗4、3、13管路
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x0c 启动鞘液泵 冲洗4、9管路
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x0d 注射器下拉,冲洗4、9管路
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x0e 关V4扰动,冲洗4、9管路
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0f 开V4扰动,冲洗4、9管路
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x10 开V4扰动,冲洗4、9管路
  {
  ticks     = 400,           -- 400ticks = 2s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x11 注射器上推,冲洗4、9管路
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x12 启动鞘液泵 冲洗8、9管路
  {
  ticks     = 9000,           -- 9000ticks = 45s
  valve     = {7, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x13 启动鞘液泵 冲洗6、3、13管路
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000.0}
  },
--0x14 关V6扰动,冲洗6、3、13管路
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x15 开V6扰动,冲洗6、3、13管路
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x16 开V6冲洗,冲洗6、3、13管路
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x17 启动鞘液泵 冲洗6、9管路
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x18 关V6扰动,冲洗6、9管路
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x19 开V6扰动,冲洗6、9管路
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1a 开V6冲洗,冲洗6、9管路
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1b 启动鞘液泵 冲洗外置样本管
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x1c 注射器下拉,冲洗4、3、13管路
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x1d 注射器下拉,冲洗4、9管路
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x1e 释放压力
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1f 结束
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DeconStep6_1 = {
  name = "IDX-DeconStep6_1",
  0x01,                                                                       -- 冲洗外置样本管

  -- 循环1-1
  0x02,                                                                       -- Chamber中引入NovoRinse

  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,                                         -- 排空Chamber

  0x01, 0x06, 0x07,                                                           -- 冲洗Syring管路4、3、13
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,                                                                 -- 冲洗Syring管路4、9
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- 循环1-2
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

  -- 循环2-1
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,                 -- 冲洗鞘液管路
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17, 0x12, 0x1E,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17,

  -- 循环1-3
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

  -- 循环3-1
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

  -- 循环2-2
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

  -- 循环3-2
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

  0x1E, 0x1F                              -- 结束
}

-- Decontamination step 6-2: 清洗chamber,针对浸泡长于45min
local TIMING_SUB_DeconStep6_2 = {
  name = "SUB-DeconStep6_2",
--0x01 启动鞘液泵 冲洗外置样本管
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 271.0, rounds = 100000.0}
  },
--0x02 启动鞘液泵 引入Novorinse进Chamber
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {7, 8, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x03 注射器下拉,引入气泡
  {
  ticks     = 900,           -- 900ticks = 4.5s
  valve     = {1},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 10.0},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 注射器上推,走V9排气泡
  {
  ticks     = 900,           -- 900ticks = 4.5s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 10.0}
  },
--0x05 注射器上推,走V3、V13排气泡
  {
  ticks     = 900,           -- 900ticks = 4.5s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 10.0}
  },
--0x06 启动鞘液泵 冲洗4、3、13管路
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x07 注射器下拉,冲洗4、3、13管路
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x08 关V4扰动,冲洗4、3、13管路
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 开V4扰动,冲洗4、3、13管路
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0a 开V4扰动,冲洗4、3、13管路
  {
  ticks     = 400,           -- 400ticks = 2s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0b 注射器上推,冲洗4、3、13管路
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {2, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x0c 启动鞘液泵 冲洗4、9管路
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x0d 注射器下拉,冲洗4、9管路
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0}
  },
--0x0e 关V4扰动,冲洗4、9管路
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0f 开V4扰动,冲洗4、9管路
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x10 开V4扰动,冲洗4、9管路
  {
  ticks     = 400,           -- 400ticks = 2s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x11 注射器上推,冲洗4、9管路
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = -150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x12 启动鞘液泵 冲洗8、9管路
  {
  ticks     = 9000,           -- 9000ticks = 45s
  valve     = {7, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x13 启动鞘液泵 冲洗6、3、13管路
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 100000.0}
  },
--0x14 关V6扰动,冲洗6、3、13管路
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x15 开V6扰动,冲洗6、3、13管路
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x16 开V6冲洗,冲洗6、3、13管路
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x17 启动鞘液泵 冲洗6、9管路
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x18 关V6扰动,冲洗6、9管路
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x19 开V6扰动,冲洗6、9管路
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1a 开V6冲洗,冲洗6、9管路
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {5, 8},
  smotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1b 启动鞘液泵 冲洗外置样本管
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 271.0}
  },
--0x1c 注射器下拉,冲洗4、3、13管路
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x1d 注射器下拉,冲洗4、9管路
  {
  ticks     = 300,           -- 300ticks = 1.5s
  valve     = {3, 8},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = 150.0, rounds = 20.0},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = 748.0}
  },
--0x1e 释放压力
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x1f 结束
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DeconStep6_2 = {
  name = "IDX-DeconStep6_2",
  0x01,                                                                       -- 冲洗外置样本管

  -- 循环1-1
  0x02,                                                                       -- Chamber中引入NovoRinse

  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,                                         -- 排空Chamber

  0x01, 0x06, 0x07,                                                           -- 冲洗Syring管路4、3、13
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B, 0x1C,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x09, 0x08, 0x0A, 0x0B,

  0x0C, 0x0D,                                                                 -- 冲洗Syring管路4、9
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x1D,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10, 0x11,
  0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x0F, 0x0E, 0x10,

  -- 循环1-2
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

  -- 循环2-1
  0x03, 0x04, 0x03, 0x04, 0x03, 0x05,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,                -- 冲洗鞘液管路
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17, 0x12, 0x1E,

  0x13,
  0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15, 0x14, 0x15,
  0x14, 0x16, 0x17,
  0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19, 0x18, 0x19,
  0x18, 0x17,

  -- 循环1-3
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

  -- 循环1-4
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

  -- 循环2-2
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

  -- 循环1-5
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

  -- 循环1-6
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

  -- 循环3-1
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

  -- 循环2-3
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

  -- 循环3-2
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

  -- 循环3-3
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

  -- 循环3-4
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

  -- 循环3-5
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

  0x1E, 0x1F                              -- 结束
}

-- Decontamination step 7: 清洗压力传感器1管路（U1）
local TIMING_SUB_DeconStep7 = {
  name = "SUB-DeconStep7",
--0x01 启动鞘液泵,冲洗Pressure1管路
  {
  ticks     = 36000,           -- 36000ticks = 180s
  valve     = {5},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 1000000.0}
  },
--0x02 停止鞘液泵
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 结束
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

-- Decontamination step 8: 清洗压力传感器2管路（U2）
local TIMING_SUB_DeconStep8 = {
  name = "SUB-DeconStep8",
--0x01 启动鞘液泵,冲洗Pressure2管路
  {
  ticks     = 36000,           -- 36000ticks = 180s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = 748.0, rounds = 1000000.0}
  },
--0x02 停止鞘液泵
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 结束
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

-- Pressure Target Calibration: 目标压力校准
local TIMING_SUB_PTCalibration = {
  name = "SUB-PTCalibration",
--0x01 V6、V9开启,启动鞘液泵
  {
  ticks     = 3000,           -- 3000ticks = 15s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = config.pmotor.omega, rounds = 1000000.0}
  },
--0x02 开始校准目标压力值
  {
  ticks     = 3000,             -- 3000ticks = 15s
  valve     = {5, 8, 12}
  },
--0x03 目标压力值校准结束
  {
  ticks     = 200,              -- 200ticks = 1s
  valve     = {5, 8, 12}
  },
--0x04 鞘液泵停止,将所有电磁阀断电复位
  {
  ticks     = 100,              -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- 进入休眠
local TIMING_SUB_SleepEnter = {
  name = "SUB-SleepEnter",
--0x01 V6、V9开启,启动鞘液泵
  {
  ticks     = 5000,             -- 5000ticks = 25s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = config.pmotor.omega, rounds = 1000000.0}
  },
--0x02 停止鞘液泵
  {
  ticks     = 20,               -- 20ticks = 0.1s
  valve     = {5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 鞘液泵复位,释放压力
  {
  ticks     = 1200,             -- 1200ticks = 6s
  valve     = {5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x04 压力释放结束,将所有电磁阀断电复位
  {
  ticks     = 100               -- 100ticks = 0.5s
  }
}

-- 退出休眠
local TIMING_SUB_SleepExit = {
  name = "SUB-SleepExit",
--0x01 V6、V9开启,启动鞘液泵
  {
  ticks     = 3000,             -- 3000ticks = 15s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = config.pmotor.omega, rounds = 1000000.0}
  },
--0x02 停止鞘液泵
  {
  ticks     = 100,              -- 100ticks = 0.5s
  valve     = {5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 将所有电磁阀断电复位
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
