#dutu
#Here is how you can change parameters without having them displayed in the parameter window.
#There could be times when (for troubleshooting purpose) you don’t want to stop the bot and change the code, but want to change certain parameters.
#Here is how you can do it without having the parameters displayed in the Parameters dialogue window (to be changeable by normal users)
#https://cryptotrader.org/topics/860867/for-developers-how-to-change-parameters-without-having-them-displayed-in-the-parameter-window
trading = require "trading"
params = require "params"
param1 = params.add "param1", ""

config:
  p1: "default 1"
  p2: "default 2"
  p3: "default 3"

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
