
require "LuaScript\\ErrorConst"

novoerror = novoerror or {}

function novoerror.analyse_error()
  local errorcode         = novoerror.get()
  local stoperrortbl      = ErrorConst.StopErrorConst
  local handleerrortbl    = ErrorConst.HandleErrorConst
  local diagnosiserrortbl = ErrorConst.DiagnosisErrorConst

  if not errorcode then                                   -- 不存在故障
    self.ststateTo = TimingConst.WORK_IDLE
    return
  else                                                    -- 存在故障
    for k, v in pairs(stoperrortbl) do                    -- 查询是否属于需要终止全部流程的故障
      if v == errorcode then
      self.ststateTo = TimingConst.WORK_STOP
      self.subref1   = k
      return  end
    end
    
    for k, v in pairs(handleerrortbl) do                  -- 查询是否属于需要诊断的故障
      if v == errorcode then
      self.ststateTo = TimingConst.WORK_ERRORHANDLE
      self.subref1   = k
      return  end
    end
    
    for k, v in pairs(diagnosiserrortbl) do               -- 查询是否属于需要自动处理的故障
      if v == errorcode then
      self.ststateTo = TimingConst.WORK_ERRORDIAGNOSIS
      self.subref1   = k
      return  end
    end
  end

end

return novoerror