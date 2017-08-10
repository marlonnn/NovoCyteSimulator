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
-- 停止电机和所有阀
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

-- 所有Motor复位到机械零点,同时释放压力
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

-- 关机外置样本针整体浸泡流程
local TIMING_SUB_SIPSoak = {
  name = "SUB-SIPSoak",
-- 0x01 外置样本针下行,浸入超纯水中
  {
  ticks     = 400,  -- 400ticks = 2s
  --valve  = nil,
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 2.0},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- 样本针擦拭完毕后的复位
local TIMING_SUB_SIPGoHome = {
  name = "SUB-SIPGoHome",
-- 0x01 外置样本针复位
  {
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
-- 0x01 灌注filter1,filter5
  {
  ticks     = 11000,         -- 11000ticks = 55s
  valve     = {3, 6, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x02 灌注NovoClean预过滤器到V11,液体量为管路容积1倍
  {
  ticks     = 8000,         -- 8000ticks = 40s
  valve     = {8, 9, 10, 11, 13}
  },
-- 0x03 灌注NovoRinse预过滤器到鞘液泵,同时用NovoRinse去除鞘液泵中的气泡
  {
  ticks     = 9000,
  valve     = {8, 9, 10, 13}
  },
-- 0x04 鞘液泵停止,扰动内腔气泡
  {
  ticks     = 200,
  valve     = {8, 9, 10, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x05 鞘液泵启动,辅助清除内腔气泡
  {
  ticks     = 400,
  valve     = {8, 9, 10, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 100000}
  },
-- 0x06 用NovoFlow清洗V8-V10之间的NovoRinse
  {
  ticks     = 1000,
  valve     = {8, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
-- 0x07 用NovoFlow清洗V8-V10之间的NovoRinse
  {
  ticks     = 1000,
  valve     = {3, 8, 13}
  },
-- 0x08 外置样本针下行扰动拭子内可能残留的NovoClean
  {
  ticks     = 200,
  valve     = {3, 8, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4}
  },
-- 0x09 外置样本针上行扰动拭子内可能残留的NovoClean
  {
  ticks     = 200,
  valve     = {3, 8, 13},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x0A 冲洗内置样本针
  {
  ticks     = 400,
  valve     = {4, 9, 13}
  },
-- 0x0B 冲洗flowchamber鞘液入口
  {
  ticks     = 1000,
  valve     = {6, 9, 13}
  },
-- 0x0C 冲洗外置样本针
  {
  ticks     = 700,
  valve     = {2, 4, 13}
  },
-- 0x0D 结束
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

-- 排气泡
local TIMING_SUB_Debubble = {
  name = "SUB-Debubble",
-- 0x01 清洗公共样本管,防止将公共样本管中的样本等吸入注射器内腔
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {4, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x02 鞘液泵将NovoRinse输送到Flow chamber
  {
  ticks     = 3000,         -- 3000ticks = 15s
  valve     = {8, 9, 10, 13}
  },
-- 0x03 将NovoRinse吸入注射器内腔中
  {
  ticks     = 1700,         -- 1700ticks = 8.5s
  valve     = {8, 9, 10, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 20.0}
  },
-- 0x04 注射器将NovoRinse推入flowcell
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {8, 9, 10, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 20.0}
  },
-- 0x05 柱塞泵停止,进行扰动,辅助清除柱塞泵内腔可能残留的气泡
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {8, 9, 10, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x06 柱塞泵启动,进行扰动,辅助清除柱塞泵内腔可能残留的气泡
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 8, 9, 10, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 100000}
  },
-- 0x07 注射器在底部上推扰动
  {
  ticks     = 600,          -- 600ticks = 3.0s
  valve     = {2, 8, 9, 10, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 4.5}
  },
-- 0x08 注射器在底部下吸扰动
  {
  ticks     = 400,         -- 400ticks = 2.0s
  valve     = {8, 9, 10, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 4.5}
  },
-- 0x09 注射器复位
  {
  ticks     = 2500,         -- 2500ticks = 12.5s
  valve     = {8, 9, 10, 13},
  imotor    = {op = TimingConst.MOTOR_RESET},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*271.0}
  },
-- 0x0A 结束
  {
  ticks     = 100,          -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_Debubble = {
  name = "IDX-Debubble",
  0x01,          -- 清洗公共样本管,防止将公共样本管中的样本等吸入注射器内腔
  0x02,          -- 鞘液泵将NovoRinse输送到Flow chamber

  0x03,          -- 将NovoRinse吸入注射器内腔
  0x04,          -- 注射器将NovoRinse推入flowcell
  0x05, 0x06, 0x05, 0x06, 0x05, 0x06, 0x05, 0x06,
                 -- 柱塞泵启动停止扰动内腔残留的气泡
  0x03,
  0x04,
  0x05, 0x06, 0x05, 0x06, 0x05, 0x06, 0x05, 0x06,
  0x03,

  0x07, 0x08, 0x07, 0x08,
  0x07, 0x08, 0x07, 0x08,
                 -- 注射器活塞在底部上下扰动
  0x09, 0x0A     -- 结束
}

-- 清洗V8-V10之间NovoRinse
local TIMING_SUB_WashAwayNR = {
  name = "SUB-WashAwayNR",
-- 0x01 清洗NovoRinse输送管路
  {
  ticks     = 2000,                   -- 2000ticks = 10s
  valve     = {8, 9},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x02 用NovoFlow冲洗鞘液泵及输送管路
  {
  ticks     = 800,                   -- 800ticks = 4s
  valve     = {3, 8, 9, 13}
  },
--0x03 外置样本针向下运动,扰动拭子内腔中可能残留的NovoRinse
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4}
  },
--0x04 外置样本针向上运动,扰动拭子内腔中可能残留的NovoRinse
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x05 结束
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
                    -- 外置样本针上下运动,扰动拭子内腔中可能残留的NovoRinse
  0x05
}

-- 冲洗流程
local TIMING_SUB_Rinse = {
  name = "SUB-Rinse",
-- 0x01 冲洗内置样本管路
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {4, 9},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x02 冲洗外置样本管路
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {2, 4, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
-- 0x03 注射器下拉扰动,清洗内置样本管路
  {
  ticks     = 500,         -- 500ticks = 2.5s
  valve     = {4, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
-- 0x04 注射器上推扰动,清洗内置样本管路
  {
  ticks     = 700,         -- 700ticks = 3.5s
  valve     = {4, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*271.0}
  },
-- 0x05 注射器上推扰动,清洗外置样本管路及flowchamber鞘液入口
  {
  ticks     = 1000,         -- 1000ticks = 5.0s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 5.0}
  },
-- 0x06 从chamber左侧入口清洗内腔
  {
  ticks     = 1000,         -- 1000ticks = 5.0s
  valve     = {8, 9, 13}
  },
-- 0x07 鞘液泵停止
  {
  ticks     = 100,         -- 100ticks = 0.5s
  valve     = {8, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x08 鞘液泵反向吸液240ul
  {
  ticks     = 500,         -- 500ticks = 2.5s
  valve     = {8, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CW*542.0, rounds = 20.0}
  },
-- 0x09 鞘液泵正向推液300ul
  {
  ticks     = 600,         -- 600ticks = 3.0s
  valve     = {8, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 25.0}
  },
-- 0x0A 清洗拭子管路
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 13},
  },
-- 0x0B 外置样本针向下运动,扰动拭子内腔中可能残留的NovoClean
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4}
  },
-- 0x0C 外置样本针向上运动,扰动拭子内腔中可能残留的NovoClean
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 13},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x0D 从鞘液管路冲洗chamber
  {
  ticks     = 1500,         -- 1500ticks = 7.5s
  valve     = {6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
-- 0x0E 从鞘液管路冲洗chamber
  {
  ticks     = 1500,         -- 1500ticks = 7.5s
  valve     = {6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x0F 清洗拭子管路
  {
  ticks     = 200,         -- 600ticks = 1.0s
  valve     = {8, 3, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x10 冲洗内置样本管路
  {
  ticks     = 1500,         -- 1500ticks = 7.5s
  valve     = {4, 9}
  },
-- 0x11 结束
  {
  ticks     = 100,
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_RinseNR = {
  name = "IDX-RinseNR",
  0x01, 0x02,                -- 清洗内&外置样本管
  0x03, 0x04, 0x03, 0x05,
  0x03, 0x04, 0x03, 0x05,    -- 清洗内&外置样本管,注射器上下扰动
  0x06, 0x0D,                -- 清洗chamber
  0x0A,
  0x0B, 0x0C, 0x0B, 0x0C,    -- 清洗拭子

  0x03, 0x04, 0x03, 0x05,
  0x03, 0x04, 0x03, 0x05,
  0x06, 0x0D,
  0x0A,
  0x0B, 0x0C, 0x0B, 0x0C,
  0x11
}

local TIMING_IDX_RinseNC = {
  name = "IDX-RinseNC",
  0x01,                      -- 清洗内置样本管
  0x03, 0x04, 0x03, 0x04,    -- 清洗内置样本管,注射器上下扰动
  0x02,                      -- 清洗外置样本管
  0x0D, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09,
  0x0E,                      -- 清洗chamber
  0x0A,
  0x0B, 0x0C, 0x0B, 0x0C,    -- 清洗拭子

  0x03, 0x04, 0x03, 0x04,
  0x0D, 0x06, 0x07,
  0x08, 0x09, 0x08, 0x09,
  0x0E,
  0x0A,
  0x0B, 0x0C, 0x0B, 0x0C,

  0x10, 0x0D, 0x11
}

-- NovoClean清洗流程
local TIMING_SUB_NovoCleanCleaning = {
  name = "SUB-NovoCleanCleaning",
-- 0x01 清洗公共样本管,防止将公共样本管中的样本等吸入注射器内腔
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {4, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x02 清洗外置样本管,防止将外置样本管中的样本等吸入注射器内腔
  {
  ticks     = 1000,         -- 1000ticks = 5s
  valve     = {2, 4, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x03 鞘液泵将NovoClean运到flowchamber,用NovoClean对flowcell进行清洗
  {
  ticks     = 6000,         -- 6000ticks = 30s  2.25倍
  valve     = {2, 8, 9, 10, 11, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*100.0, rounds = 2.0}
  },
-- 0x04 用注射器将NovoClean吸入公共样本管路
  {
  ticks     = 840,         -- 840ticks = 4.2s
  valve     = {8, 9, 10, 11},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*100.0, rounds = 6.5}
  },
-- 0x05 将NovoClean推入外置样本管路
  {
  ticks     = 100,         -- 100ticks = 0.5s
  valve     = {2, 8, 9, 10, 11, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 6.5},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
-- 0x06 鞘液泵反向吸液240ul
  {
  ticks     = 500,         -- 500ticks = 2.5s
  valve     = {2, 8, 9, 10, 11, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CW*542.0, rounds = 20.0}
  },
-- 0x07 鞘液泵正向推液300ul
  {
  ticks     = 600,         -- 600ticks = 3.0s
  valve     = {2, 8, 9, 10, 11, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 25.0}
  },
-- 0x08 用注射器将NovoClean吸入公共样本管路
  {
  ticks     = 870,         -- 870ticks = 4.35s
  valve     = {8, 9, 10, 11},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*100.0, rounds = 6.5},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 50}
  },
-- 0x09 将NovoClean运到废液泵管路
  {
  ticks     = 1000,         -- 1000ticks = 5.0s
  valve     = {3, 8, 10, 11, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
-- 0x0A 结束
  {
  ticks     = 100,          -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_NovoCleanCleaning = {
  name = "IDX-NovoCleanCleaning",
  0x01, 0x02,              -- 清洗公共样本管及外置样本管,防止将公共样本管中的样本等被吸入注射器内腔
  0x03,                    -- 鞘液泵将NovoClean运到Flow chamber,用NovoClean对flowcell进行清洗
  0x04, 0x05,              -- 用注射器将NovoClean吸入公共样本管路,推到外置样本管路
  0x06, 0x07,              -- 鞘液泵正转反转,清洗flowcell

  0x08, 0x05,
  0x06, 0x07,

  0x08, 0x05,
  0x06, 0x07,

  0x08,
  0x06, 0x07,
  0x09, 0x0A               -- 结束
}

-- 浸泡Flowcell及样本管路,并行进行部分管路的清洗
local TIMING_SUB_Soak = {
  name = "SUB-Soak",
--0x01 浸泡
  {
  ticks     = 6000,         -- 6000ticks = 30s
  valve     = {8, 9, 10, 11},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*20.0, rounds = 100000}
  },
--0x02 用NovoRinse填充V10-V11之间管路
  {
  ticks     = 1400,         -- 1400ticks = 7s
  valve     = {3, 8, 10, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
--0x03 用NovoFlow清洗NovoClean输送管路,V10-flow hamber左侧三通接头之间管路的3倍
  {
  ticks     = 800,         -- 800ticks = 4s
  valve     = {3, 8, 13}
  },
--0x04 外置样本针向下运动,扰动拭子内腔中可能残留的NovoClean
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4}
  },
--0x05 外置样本针向上运动,扰动拭子内腔中可能残留的NovoClean
  {
  ticks     = 200,         -- 200ticks = 1.0s
  valve     = {3, 8, 13},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x06 注射器复位
  {
  ticks     = 1200,         -- 1200ticks = 6.0s
  valve     = {2, 3, 8, 13},
  imotor    = {op = TimingConst.MOTOR_RESET},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*271.0}
  },
-- 0x07 冲洗外置样本管
  {
  ticks     = 2000,         -- 2000ticks = 10s
  valve     = {2, 4, 13},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
-- 0x08 注射器下拉扰动
  {
  ticks     = 500,         -- 500ticks = 2.5s
  valve     = {2, 4, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
-- 0x09 注射器上推扰动
  {
  ticks     = 700,         -- 700ticks = 3.5s
  valve     = {2, 4, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*271.0}
  },
--0x0A 结束
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_Soak = {
  name = "IDX-Soak",
  0x01,             -- 浸泡
  0x02,             -- 用NovoRinse清洗V10—V11之间管路
  0x03,             -- 用NovoFlow清洗NovoClean输送管路
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
  0x04, 0x05, 0x04, 0x05, 0x04, 0x05,
                    -- 外置样本针上下运动,扰动拭子内腔中可能残留的NovoClean
  0x06,             -- 注射器复位
  0x07,             -- 冲洗外置样本管
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09,
  0x08, 0x09, 0x08, 0x09, 0x08, 0x09,
                    -- 冲洗外置样本管,注射器活塞上下扰动
  0x0A              -- 结束
}

-- 绝对计数测试时序
local TIMING_SUB_AbsSampleAcquisition = {
  name = "SUB-AbsSampleAcquisition",
--0x01 外置样本针下行
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
  ticks     = 30,           -- 30ticks = 0.15s,保证样本针尖露出拭子
  valve     = {2, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*650.0, rounds = 100000.0}
  },
--0x02 外置样本针下行过程中,吸入10ul隔离空气
  {
  beginhook = function (self, item)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 160,           -- 160ticks = 0.8s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 1000, omega = PULL*120.0, rounds = 0.3}  --去除注射器5uL回程差
  },
--0x03 吸入样本
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
--0x04 外置样本针上行
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
--0x05 将样本吸入公共样本管路
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step2      -- set step to step2
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 300,          -- 300ticks = 1.5s   0.4s针尖即可复位
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PULL*100.0, rounds = 1.90}
  },
--[[
--0x06 将样本吸入公共样本管路
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step2      -- set step to step2
  end,
  ticks     = 220,          -- 220ticks = 1.1s
  valve     = {2, 6, 9, 13}
  },
--]]
--0x07 将样本从公共样本管路boost到flow cell监测区
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
--0x08 PID调整鞘液压力开始,注射器提前启动,为开始测试做准备
  {
  beginhook = function (self, item)
    self.idr = self.idr + PUSH * item.imotor.rounds
    subwork:pidcontrol(TimingConst.PID_Start)
  end,
  ticks     = 600,           -- 6000ticks = 3.0s
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 200, omega = PUSH*5.0, rounds = 0.5}
  },
--0x09 boost后,进入流量稳定期,注射器流量与用户设定的样本流量相同
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
--0x0A 正式测试,开始采集数据
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
--0x0B 测试停止
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
--0X0C 测试结束,注射器从内置样本针推走剩余样本及隔离空气,同时注射器活塞到达光耦
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

-- 非绝对计数测试时序
local TIMING_SUB_NoAbsSampleAcquisition = {
  name = "SUB-NoAbsSampleAcquisition",
--0x01 外置样本针下行
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
  ticks     = 30,           -- 60ticks = 0.15s,保证样本针尖露出拭子
  valve     = {2, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*748.0, rounds = 100000.0}
  },
--0x02 外置样本针下行过程中,吸入10ul隔离空气
  {
  beginhook = function (self, item)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 160,           -- 160ticks = 0.8s
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 4800, omega = PULL*120.0, rounds = 0.3}  --去除注射器5uL回程差
  },
--0x03 吸入样本
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
--0x04 外置样本针上行
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
--0x05 将样本吸入公共样本管路
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step2      -- set step to step2
    subwork:stateset(self.stateTo, self.ref1, self.ref2)
    self.idr = self.idr + PULL * item.imotor.rounds
  end,
  ticks     = 150,          -- 150ticks = 0.75s   0.4s针尖即可复位
  valve     = {2, 6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 500, omega = PULL*200.0, rounds = 1.90}
  },
--[[
--0x06 将样本吸入公共样本管路
  {
  beginhook = function (self, item)
    self.ref1 = TimingConst.MEASURE_Boosting    -- set state to boosting
    self.ref2 = TimingConst.BOOSTING_Step2      -- set step to step2
  end,
  ticks     = 220,          -- 220ticks = 1.1s
  valve     = {2, 6, 9, 13}
  },
--]]
--0x07 将样本从公共样本管路boost到flow cell监测区
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
--0x08 PID调整鞘液压力开始,注射器提前启动,为开始测试做准备
  {
  beginhook = function (self, item)
    self.idr = self.idr + PUSH * item.imotor.rounds
    subwork:pidcontrol(TimingConst.PID_Start)
  end,
  ticks     = 600,           -- 6000ticks = 3.0s
  valve     = {6, 9, 13},
  imotor    = {op = TimingConst.MOTOR_RUN, alpha = 200, omega = PUSH*5.0, rounds = 0.5}
  },
--0x09 boost后,进入流量稳定期,注射器流量与用户设定的样本流量相同
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
--0x0A 正式测试,开始采集数据
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
--0x0B 测试停止
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
--0x0C 测试结束,注射器从内置样本针推走剩余样本及隔离空气,同时注射器活塞到达光耦
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

-- 导管公差校准流程
local TIMING_SUB_AdjustNormal = {
  name = "SUB-AdjustNormal"
}

-- 测试流程结束后不清洗执行流程
local TIMING_SUB_TestCleanNone = {
  name = "SUB-TestCleanNone",
--0x01 鞘液泵停止
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
--0x02 填充外置样本管路
  {
  ticks     = 90,          -- 90ticks = 0.45s
  valve     = {2, 4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542, rounds = 3.0}
  },
--0x03 鞘液泵复位,释放压力
  {
  ticks     = 160,           -- 160ticks = 0.8s
  valve     = {2, 4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x04 所有阀关闭,结束
  {
  ticks     = 10            -- 10ticks = 50ms
  }
}

-- 测试流程结束后的首次清洗流程
local TIMING_SUB_TestCleanFirst = {
  name = "SUB-TestCleanFirst",
--0x01 内置样本针内壁清洗
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
--0x02 外置样本针上行,同时进行外壁清洗
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {3, 4, 6, 8, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = UP*30.0, rounds = 0.4}
  },
--0x03 外置样本针内壁清洗
  {
  ticks     = 700,          -- 700ticks = 3.5s
  valve     = {2, 3, 4, 9, 13}
  },
--0x04 鞘液泵停止
  {
  ticks     = 80,          -- 80ticks = 0.4s
  valve     = {3, 4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x05 样本针下行,鞘液泵复位
  {
  ticks     = 200,          -- 200ticks = 1.0s
  valve     = {3, 4, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.45},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x06 V3关闭,外置样本针复位
  {
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {4, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x07 所有阀关闭,鞘液泵停止,结束
  {
  ticks     = 10,          -- 10ticks = 50ms
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- 测试流程结束后的多次清洗流程
local TIMING_SUB_TestCleanOthers = {
  name = "SUB-TestCleanOthers",
--0x01 内置样本针内壁清洗
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
--0x02 外置样本针上行,同时进行外壁清洗
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = UP*15.0, rounds = 0.4}
  },
--0x03 样本针下行,同时进行外壁清洗
  {
  ticks     = 400,          -- 400ticks = 2s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*15.0, rounds = 0.35}
  },
--0x04 关闭v3,同时样本针复位
  {
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 外置样本针内壁清洗
  {
  ticks     = 1000,          -- 1000ticks = 5s
  valve     = {1, 3, 8, 12}
  },
--0x06 鞘液泵停止
  {
  ticks     = 80,          -- 80ticks = 0.4s
  valve     = {3, 5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 样本针下行,鞘液泵复位
  {
  ticks     = 320,          -- 320ticks = 1.6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x08 v3开启释放压力
  {
  ticks     = 200,          -- 200ticks = 1s
  valve     = {2, 3, 5, 8, 12}
  },
--0x09 V3关闭,外置样本针复位
  {
  ticks     = 40,          -- 40ticks = 0.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x0a 所有阀关闭,鞘液泵停止,结束
  {
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
--0x02 外置样本针内壁清洗
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {1, 3, 8, 12}
  },
--0x03 鞘液泵停止
  {
  ticks     = 80,           -- 80ticks = 0.4s
  valve     = {3, 5, 8, 12},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x04 样本针下行,鞘液泵复位
  {
  ticks     = 320,           -- 320ticks = 1.6s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RUN, omega = DN*150.0, rounds = 0.4}, -- acc = acc or DEFAULT_ACC
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x05 v3开启释放压力
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {2, 3, 5, 8, 12}
  },
--0x06 V3关闭,外置样本针复位
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x07 所有阀关闭,鞘液泵停止,结束
  {
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
  ticks     = 141000,           -- 141000ticks = 705s 灌注5倍
  valve     = {4, 9},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
--0x02 灌注外置样本管路
  {
  ticks     = 500,           -- 500ticks = 2.5s 灌注5倍
  valve     = {2, 4, 9, 13}
  },
--0x03 灌注NovoClean桶到V11
  {
  ticks     = 17000,           -- 17000ticks = 85s 灌注量是NovoClean到V11容积的2倍
  valve     = {8, 9, 10, 11}
  },
--0x04 灌注NovoRinse桶到flowchamber侧口管路
  {
  ticks     = 17400,           -- 17400ticks = 87s 灌注量是NovoRinse到V10容积的2倍
  valve     = {8, 9, 10}
  },
--0x05 用鞘液冲洗NovoRinse输送管路
  {
  ticks     = 4200,           -- 4200ticks = 21s 冲洗V10到flowchamber侧口2倍
  valve     = {8, 9}
  },
--0x06 释放chamber压力
  {
  ticks     = 1200,           -- 1200ticks = 6s
  valve     = {4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 灌注鞘液管路
  {
  ticks     = 11500,           -- 12000ticks = 57.5s 灌注2倍
  valve     = {3, 6, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
--0x08 停止鞘液泵,释放压力
  {
  ticks     = 1600,           -- 1600ticks = 8s
  valve     = {4, 6, 9, 13},
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


-- 排空----机器长途运输或长时间不使用,需要排空
-- Drain step 1: 用超纯水冲洗管路
local TIMING_SUB_DrainStep1 = {
  name = "SUB-DrainStep1",
--0x01 冲洗NovoClean管路，10倍
  {
  ticks     = 85000,           -- 85000ticks = 425s 从NovoClean桶>V11 冲洗10倍
  valve     = {8, 9, 10, 11},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 10000000}
  },
--0x02 冲洗NovoRinse管路，10倍
  {
  ticks     = 100700,           -- 107000ticks = 503.5s 从NovoRinse桶>鞘液泵>NovoRinse输送管路>chamber左侧接头 冲洗10倍
  valve     = {8, 9, 10}
  },
  --0x03 冲洗鞘液管路，10倍
  {
  ticks     = 222500,           -- 222500ticks = 1125.5s
  valve     = {3, 6, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 10000000}
  },
--0x04 用超纯水冲洗注射器内腔及样本管路，25倍
  {
  ticks     = 152200,           -- 152200ticks = 761s 冲洗20倍
  valve     = {4, 9}
  },
--0x05 注射器下拉扰动内腔中的死区
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {4, 9},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 5.0}
  },
--0x06 注射器上推扰动内腔中的死区
  {
  ticks     = 700,           -- 700ticks = 3.5s
  valve     = {4, 9},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*100.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*271.0}
  },
--0x07 注射器下拉扰动内腔中的死区
  {
  ticks     = 500,           -- 500ticks = 2.5s
  valve     = {4, 9},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 5.0},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
--0x08 释放压力
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x09 用超纯水冲洗外置样本管路，30倍
  {
  ticks     = 3000,           -- 3000ticks = 15s
  valve     = {2, 4, 9, 13},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
--0x0A 释放压力
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {2, 4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x0B 结束
  {
  ticks     = 200,           -- 200ticks = 1s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DrainStep1 = {
  name = "IDX-DrainStep1",
  -- NovoClean桶>>v11 冲洗10倍
  0x01,
  -- NovoRinse桶>鞘液泵>NovoRinse输送管路>chamber左侧三通 冲洗10倍
  0x02,
  -- 鞘液桶>鞘液泵>damper>flow chamber>V3>拭子管路冲洗10倍
  0x03,
  -- 鞘液桶>鞘液泵>注射器>chamber>V9>废液管路冲洗25倍
  0x04,
  -- 鞘液桶>鞘液泵>注射器>chamber>V9>废液管路冲洗15倍,注射器吸排扰动121次
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
  -- 鞘液桶>鞘液泵>注射器>V2>外置样本管冲洗,液体量为“外置样本管+外置样本针容积”30倍
  0x09, 0x0A, 0x0B
}

-- Drain step 2: NovoClean管路、NovoRinse管路、样本管路、鞘液管路排空
local TIMING_SUB_DrainStep2 = {
  name = "SUB-DrainStep2",
--0x01 排空NovoClean管路
  {
  ticks     = 25500,           -- 25500ticks = 127.5s 从NovoClean桶>v11 排空3倍
  valve     = {8, 9, 10, 11},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 10000000}
  },
--0x02 排空NovoRinse管路
  {
  ticks     = 30300,           -- 30300ticks = 151.5s 从NovoRinse桶>鞘液泵>NovoRinse输送管路>chamber侧口 排空3倍
  valve     = {8, 9, 10}
  },
--0x03 排空注射器内腔及内置样本管路、flowchamber及flowchamber废液管路
  {
  ticks     = 84600,           -- 84600ticks = 423s 排空3倍
  valve     = {4, 9}
  },
--0x04 排空外置样本管路
  {
  ticks     = 1000,           -- 1000ticks = 5s 排空10倍
  valve     = {2, 4, 9, 13}
  },
--0x05 排空鞘液管路
  {
  ticks     = 17200,           -- 17200ticks = 86s
  valve     = {3, 6, 13}
  },
--0x06 废液泵吸拭子的废液管路
  {
  ticks     = 1600,           -- 1600ticks = 8s
  valve     = {3, 4, 6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x07 废液泵停止吸液,让拭子废液管路中的液体聚集,以便下一次被吸走
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {3, 4, 6, 9, 13}
  },
--0x08 所有电机复位
  {
  ticks     = 2700,           -- 2700ticks = 13.5s
  valve     = {3, 5, 8, 12},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RESET},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
--0x09 停止鞘液泵,将所有电磁阀关闭,停止废液泵,结束
  {
  ticks     = 100,           -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

local TIMING_IDX_DrainStep2 = {
  name = "IDX-DrainStep2",
  -- NovoClean桶>v11 排空3倍
  0x01,
  -- NovoRinse桶>鞘液泵>NovoRinse输送管路>chamber侧口 排空3倍
  0x02,
  -- 鞘液桶>鞘液泵>注射器>chamber>V9>废液管路排空3倍
  0x03,
  -- 鞘液桶>鞘液泵>注射器>V2>外置样本管冲洗,排空外置样本管路3倍
  0x04,
  -- 鞘液桶>鞘液泵>damper>flow chamber>V3>拭子管路冲洗3倍
  0x05,
  -- 吸干拭子的废液管路
  0x06, 0x07, 0x06, 0x07, 0x06, 0x07,
  -- 电机复位,阀关闭,结束
  0x08, 0x09
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
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 1000000}
  },
--0x02 浸泡8、3、13管路
  {
  ticks     = 6000,           -- 6000ticks = 30s
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*542.0}
  },
--0x03 浸泡鞘液管路6、3、13
  {
  ticks     = 18000,           -- 18000ticks = 90s
  valve     = {2, 5, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
  },
--0x04 浸泡外置样本管
  {
  ticks     = 1000,           -- 1000ticks = 5s
  valve     = {1, 3, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*271.0}
  },
--0x05 鞘液泵转速提高
  {
  ticks     = 42000,           -- 42000ticks = 210s 鞘液量=22.75ml
  valve     = {3, 8, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
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
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*420.0, rounds = 35.0}
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


-- Decontamination step 2: NovoClean浸泡管路,进行杀菌消毒
local TIMING_SUB_DeconStep2 = {
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

local TIMING_IDX_DeconStep2 = {
  name = "IDX-DeconStep2",
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
  ticks     = 6000,           -- 6000ticks = 30s  3、8、13管路
  valve     = {2, 7, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 100000}
  },
--0x04 关V6扰动
  {
  ticks     = 40,           -- 40ticks = 0.2s
  valve     = {7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_CHSPEED, omega = CCW*750.0}
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
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 100000}
  },
--0x09 冲洗pressure2管路
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
--0x0b 注射器下拉,引入NovoRinse
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 20.0}
  },
--0x0c 注射器上推
  {
  ticks     = 200,           -- 200ticks = 1s
  valve     = {3, 7, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*150.0, rounds = 20.0}
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
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 20.0},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x11 注射器上推,走V9
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {8},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*150.0, rounds = 20.0}
  },
--0x12 注射器上推,走V3、13
  {
  ticks     = 1700,           -- 2000ticks = 10s
  valve     = {2, 12},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*150.0, rounds = 20.0}
  },
--0x13 启动鞘液泵,灌注注射器
  {
  ticks     = 2000,           -- 2000ticks = 10s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*750.0, rounds = 100000}
  },
--0x14 注射器上推,灌注注射器
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*150.0, rounds = 20.0}
  },
--0x15 注射器下拉,灌注注射器
  {
  ticks     = 1700,           -- 1700ticks = 8.5s
  valve     = {3, 7},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PULL*150.0, rounds = 20.0}
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
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 100000}
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

  0x1E, 0x1F                                 -- 释放压力
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
  valve     = {6, 9},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*config.pmotor.omega, rounds = 1000000.0}
  },
--0x02 开始校准目标压力值
  {
  beginhook = function (self, item)
    subwork:pidcontrol(TimingConst.PTC_Start)
  end,
  ticks     = 3000,             -- 3000ticks = 15s
  valve     = {6, 9}
  },
--0x03 目标压力值校准结束
  {
  beginhook = function (self, item)
    subwork:pidcontrol(TimingConst.PTC_Stop)
  end,
  ticks     = 200,              -- 200ticks = 1s
  valve     = {6, 9}
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
  valve     = {6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*config.pmotor.omega, rounds = 1000000.0}
  },
--0x02 停止鞘液泵
  {
  ticks     = 20,               -- 20ticks = 0.1s
  valve     = {6, 9, 13},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  },
--0x03 鞘液泵复位,释放压力
  {
  ticks     = 1200,             -- 1200ticks = 6s
  valve     = {6, 9, 13},
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
  valve     = {6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*config.pmotor.omega, rounds = 1000000.0}
  },
--0x02 停止鞘液泵
  {
  ticks     = 100,              -- 100ticks = 0.5s
  valve     = {6, 9, 13},
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
-- 故障诊断模块
-------------------------------------------------------------------------
-- 压力超限后的压力释放
local TIMING_SUB_PRelease = {
  name = "SUB-PRelease",
-- 0x01 复位
  {
  ticks     = 1200,   -- 1200ticks = 6s  保证注射器在最底部也能复位
  valve     = {3, 4, 6, 9, 13},
  smotor    = {op = TimingConst.MOTOR_RESET},
  imotor    = {op = TimingConst.MOTOR_RUN, omega = PUSH*225.0, rounds = 22.0},
  pmotor    = {op = TimingConst.MOTOR_RESET}
  },
-- 0x02 电磁阀打开,释放压力
  {
  ticks     = 1000,   -- 1000ticks = 5s
  valve     = {2, 3, 4, 6, 9, 13}
  }
}

-- V8>V3,检测拭子管路
local TIMING_SUB_DiagnosticateStep1 = {
  name = "SUB-DiagnosticateStep1",
--0x01 开启阀，启动鞘液泵
  {
  ticks     = 4000,             -- 4000ticks = 20s
  valve     = {3, 8, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 1000000.0}
  },
--0x02 采集10s压力
  {
  ticks     = 2000,              -- 2000ticks = 10s
  valve     = {3, 8, 13}
  },
--0x03 将所有电磁阀断电复位
  {
  ticks     = 100,              -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- V8>V9,检测flowcell及废液管路
local TIMING_SUB_DiagnosticateStep2 = {
  name = "SUB-DiagnosticateStep2",
--0x01 开启阀，启动鞘液泵
  {
  ticks     = 4000,             -- 4000ticks = 20s
  valve     = {8, 9},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 1000000.0}
  },
--0x02 采集10s压力
  {
  ticks     = 2000,              -- 2000ticks = 10s
  valve     = {8, 9}
  },
--0x03 将所有电磁阀断电复位
  {
  ticks     = 100,              -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- V6>V3, 检测鞘液输送管路
local TIMING_SUB_DiagnosticateStep3 = {
  name = "SUB-DiagnosticateStep3",
--0x01 开启阀，启动鞘液泵
  {
  ticks     = 4000,             -- 4000ticks = 20s
  valve     = {3, 6, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 1000000.0}
  },
--0x02 采集10s压力
  {
  ticks     = 2000,              -- 2000ticks = 10s
  valve     = {3, 6, 13}
  },
--0x03 将所有电磁阀断电复位
  {
  ticks     = 100,              -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- V4>V9, 检测内置样本针及管路
local TIMING_SUB_DiagnosticateStep4 = {
  name = "SUB-DiagnosticateStep4",
--0x01 开启阀，启动鞘液泵
  {
  ticks     = 4000,             -- 4000ticks = 20s
  valve     = {4, 9},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 1000000.0}
  },
--0x02 采集10s压力
  {
  ticks     = 2000,              -- 2000ticks = 10s
  valve     = {4, 9}
  },
--0x03 将所有电磁阀断电复位
  {
  ticks     = 100,              -- 100ticks = 0.5s
  smotor    = {op = TimingConst.MOTOR_STOP},
  imotor    = {op = TimingConst.MOTOR_STOP},
  pmotor    = {op = TimingConst.MOTOR_STOP}
  }
}

-- V4>V2, 检测外置样本针及管路
local TIMING_SUB_DiagnosticateStep5 = {
  name = "SUB-DiagnosticateStep5",
-- 0x01 开启阀，启动鞘液泵
  {
  ticks     = 4000,             -- 4000ticks = 20s
  valve     = {4, 2, 13},
  pmotor    = {op = TimingConst.MOTOR_RUN, omega = CCW*542.0, rounds = 1000000.0}
  },
-- 0x02 采集10s压力
  {
  ticks     = 2000,              -- 2000ticks = 10s
  valve     = {4, 2, 13}
  },
-- 0x03 将所有电磁阀断电复位
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