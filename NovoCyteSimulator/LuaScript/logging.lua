-------------------------------------------------------------------------------
-- includes a new tostring function that handles tables recursively
--
-- @author Danilo Tuler (tuler@ideais.com.br)
-- @author Andre Carregal (info@keplerproject.org)
-- @author Thiago Costa Ponte (thiago@ideais.com.br)
--
-- @copyright 2004-2007 Kepler Project
-- @release $Id: logging.lua,v 1.12 2007/10/30 19:57:59 carregal Exp $
-------------------------------------------------------------------------------

local _tostring = tostring

logging ={
-- Meta information
  _COPYRIGHT = "Copyright (C) 2004-2007 Kepler Project",
  _DESCRIPTION = "A simple API to use logging features in Lua",
  _VERSION = "LuaLogging 1.1.4",

-- The DEBUG Level designates fine-grained instring.formational events that are most
-- useful to debug an application
  DEBUG = "DEBUG",

-- The INFO level designates instring.formational messages that highlight the
-- progress of the application at coarse-grained level
  INFO = "INFO",

-- The WARN level designates potentially harmful situations
  WARN = "WARN",

-- The ERROR level designates error events that might still allow the
-- application to continue running
  ERROR = "ERROR",

-- The FATAL level designates very severe error events that will presumably
-- lead the application to abort
  FATAL = "FATAL",

  OFF = "OFF",
}

LEVEL = {
  [logging.DEBUG] = 1,
  [logging.INFO]  = 2,
  [logging.WARN]  = 3,
  [logging.ERROR] = 4,
  [logging.FATAL] = 5,
  [logging.OFF]   = 32
}

COLOR = {
  [logging.DEBUG] = "\27[1;36m",
  [logging.INFO]  = "\27[1;32m",
  [logging.WARN]  = "\27[1;33m",
  [logging.ERROR] = "\27[1;31m",
  [logging.FATAL] = "\27[1;35m",
  [logging.OFF]   = "\27[m"
}


-------------------------------------------------------------------------------
-- Converts a Lua value to a string
--
-- Converts Table fields in alphabetical order
-------------------------------------------------------------------------------
local tostring
tostring = function (value)
  local str = ""

  if (type(value) ~= 'table') then
    if (type(value) == 'string') then
      str = string.format("%q", value)
    else
      str = _tostring(value)
    end
  else
    local auxTable = {}
    table.foreach(value, function(i, v)
      if (tonumber(i) ~= i) then
        table.insert(auxTable, i)
      else
        table.insert(auxTable, tostring(i))
      end
    end)
    table.sort(auxTable)

    str = str..'{'
    local separator = ""
    local entry = ""
    table.foreachi (auxTable, function (i, fieldName)
      if ((tonumber(fieldName)) and (tonumber(fieldName) > 0)) then
        entry = tostring(value[tonumber(fieldName)])
      else
        entry = fieldName.." = "..tostring(value[fieldName])
      end
      str = str..separator..entry
      separator = ", "
    end)
    str = str..'}'
  end
  return str
end


-------------------------------------------------------------------------------
-- Creates a new logger object
-- @param append Function used by the logger to append a message with a
--  log-level to the log stream.
-- @return Table representing the new logger object.
-------------------------------------------------------------------------------
logging.new = function (self, append)

  if type(append) ~= "function" then
    return nil, "Appender must be a function."
  end

  local logger = {}
  logger.level = self.DEBUG
  logger.append = append

  logger.setLevel = function (self, level)
    assert(LEVEL[level], string.format("undefined level `%s'", tostring(level)))
    self.level = level
  end

  logger.log = function (self, level, ...)
    assert(LEVEL[level], string.format("undefined level `%s'", tostring(level)))
    if LEVEL[level] < LEVEL[self.level] then
      return
    end
    local message = ""
    for i=1, select('#', ...) do
      local arg = select(i, ...)
      if type(arg) == "string" then
        message = message .. arg
      else
        message = message .. tostring(arg)
      end
      message = message .. " "
    end
    return logger:append(string.format("%s[%s]:\27[m", COLOR[level], level), message)
  end

  logger.debug = function (logger, ...) return logger:log(self.DEBUG, ...) end
  logger.info  = function (logger, ...) return logger:log(self.INFO,  ...) end
  logger.warn  = function (logger, ...) return logger:log(self.WARN,  ...) end
  logger.error = function (logger, ...) return logger:log(self.ERROR, ...) end
  logger.fatal = function (logger, ...) return logger:log(self.FATAL, ...) end
  return logger
end


-------------------------------------------------------------------------------
-- Prepares the log message
-------------------------------------------------------------------------------
local prepareLogMsg = function (pattern, dt, level, message)

  local logMsg = pattern or "%date %level %message\r\n"
  message = string.gsub(message, "%%", "%%%%")
  logMsg = string.gsub(logMsg, "%%date", dt)
  logMsg = string.gsub(logMsg, "%%level", level)
  logMsg = string.gsub(logMsg, "%%message", message)
  return logMsg
end


-------------------------------------------------------------------------------
-- Prints logging information to console
-------------------------------------------------------------------------------
logging.console = function (self, logPattern)
  return self:new(function(self, level, message)
                    io.stdout:write(prepareLogMsg(logPattern, os.date(), level, message))
                    return true
                  end
                  )
end


-------------------------------------------------------------------------------
-- Saves logging information in a file
-------------------------------------------------------------------------------
logging.file = function (self, filename, datePattern, logPattern)

  if type(filename) ~= "string" then
      filename = "lualogging.log"
  end
  filename = string.format(filename, os.date(datePattern))
  local f = io.open(filename, "a")
  if not f then
     return nil, string.format("file `%s' could not be opened for writing", filename)
  end
  f:setvbuf ("line")

  return self:new(function(self, level, message)
                    local s = prepareLogMsg(logPattern, os.date(), level, message)
                    f:write(s)
                    return true
                  end
                  )
end

return logging
