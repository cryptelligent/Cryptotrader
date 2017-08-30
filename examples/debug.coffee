#dutu
#https://cryptotrader.org/topics/749565/for-developers-how-to-turn-debug-on-to-log-your-debug-messages
trading = require "trading"
params = require "params"

PARAM1_DEFAULT_VALUE = "a default value"
param1 = params.add "param1", PARAM1_DEFAULT_VALUE

config:
  p1: PARAM1_DEFAULT_VALUE
  isDebugOn: false
  p3: "default 3"

class util
  @debug: (method, message) ->
    return unless config.isDebugOn
    if typeof method is "function"
      method "Debug: #{message}"
    else
      debug "Debug: #{method}"

handle: ->
  storage.processParam ?= _.once ->
    try
      _.merge(config, JSON.parse(param1))
    catch e
      if param1.indexOf("{") == -1
        config.p1 = param1
      else
        error "#{e.message}"

    debug " "
    debug "config = #{JSON.stringify(config)}"
    debug " "

  storage.processParam()

  debug "this is a normal message: param1 = '#{config.p1}'"
  util.debug("this is a debug message")
  util.debug(warn, "this is a WARN debug message")
  util.debug(info, "this is an INFO debug message")
  debug " "
