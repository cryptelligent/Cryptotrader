###
	# benchmarking function#
	# usage:
	# t = timer('Some label');
	# // code to benchmark
	# t.stop(); // prints the time elapsed to the js console
	# by cryptelligent
###
talib = require 'talib' # import technical indicators library (https://cryptotrader.org/talib)


timer = (name) ->
    start = new Date
    { stop: ->
        end = new Date
        time = end.getTime() - start.getTime()
        debug 'Timer: ' + name + ' finished in ' + time + ' ms'
    }
#Example
###
    function calculate RSI using standard module
    @params - data, lag (usually 1) and period
    @return: RSI
###
rsi = (data, lag, period) ->
    period = data.length unless data.length >= period
    results = talib.RSI
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    if _.last then _.last(results) else results
############### Init Initialization method called before trading logic starts
init: (context) ->

    context.lag  = 1
    context.period = 14

############## Main Called on each tick according to the tick interval that was set (e.g 1 hour)
handle: (context, data)->
    ins = data.instruments[0]
    t = timer('RSI')
    rsiResults  = rsi(ins.close, context.lag, context.period)
    t.stop()
