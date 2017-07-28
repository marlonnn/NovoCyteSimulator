--******************************************************************************
-- config.lua
--
--   Copyright (C) 2010-2016 ACEA Biosciences, Inc. All rights reserved.
--   Author: AlexShi <shiweining123@163.com>
--
--******************************************************************************

config = {
  -- instrument type: IVD or RUO
  instrumenttype = TimingConst.INSTRUMENT_IS_IVD,

  compensation = {
    [TimingConst.TEST_IS_ABS] = {
      id = 0,
      coef = {
        [TimingConst.INSTRUMENT_IS_RUO] = 1.0,
        [TimingConst.INSTRUMENT_IS_IVD] = 1.0
      },
      size = 30       -- uL
    },
    [TimingConst.TEST_IS_PID] = {
      id = 1,
      coef = {
        [TimingConst.INSTRUMENT_IS_RUO] = 1.0,
        [TimingConst.INSTRUMENT_IS_IVD] = 1.0
      },
      size = 30       -- uL
    }
  },

  originflux = 6.5,   -- mL/min

  smotor = {
    lowrounds = 2.21  -- rounds
  },

  imotor = {
    volumperround = 50, -- 50uL/r
    boostrounds = {
      [TimingConst.TEST_IS_ABS] = 0.6,
      [TimingConst.TEST_IS_PID] = 0.6
    }
  },

  pmotor = {
    omega = 542       -- rpm
  }
}

return config


--******************************************************************************
-- No More!
--******************************************************************************
