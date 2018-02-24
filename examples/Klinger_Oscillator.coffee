###
    Klinger Volume Oscillator
    by cryptelligent 
###
trading = require 'trading' # import core trading module
talib = require 'talib' # import technical indicators library (https://cryptotrader.org/talib)
params = require 'params'
######################### Settings
_KVO_short = 34
_KVO_long = 55
_KVO_signal = 13
_lag = 1
######################## Functions
###
    function calculate Klinger Volume Oscillator
    @params - instrument, lag (usually 1), short period, long period, signal period
    @return: KVO, KVOsignal

###
kvo = (ins, lag, KVO_short, KVO_long, KVO_signal) ->
    results = {
        trends: []
        kvos: []
        kvosig: []
    }
    ticks = ins.ticks.slice(ins.ticks.length - (KVO_long + KVO_signal + 2)) #reduce array size to save on calculations
    for v, i in ticks
        if i 
            pr = (ticks[i].high + ticks[i].low + ticks[i].close)/3
            prev_pr = (ticks[i-1].high + ticks[i-1].low + ticks[i-1].close)/3
            if pr > prev_pr
                trend = ticks[i].volume
            else 
                trend = -ticks[i].volume
            results.trends.push trend
            if i > KVO_long
                results.kvos.push (ema(results.trends, lag, KVO_short) - ema(results.trends, lag, KVO_long))
                results.kvosig.push ema(results.kvos, lag, KVO_signal) #return array with only2 values
    result =
      KVO: _.last(results.kvos)
      KVOsignal: _.last(results.kvosig)
    result
###
    function calculate EMA using standard module
    @params - data, lag (usually 1) and period
    @return: EMA
###
ema = (data, lag, period) ->
    results = talib.EMA
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)
# Initialization method called before the script starts.
init: ->
setPlotOptions
        "KVO":
            color: 'black'
            secondary: true
        "KVOsignal":
            color: 'red'
            secondary: true

# This method is called for each tick
handle: ->
    ins = data.instruments[0]
    kvoResult = kvo(ins, _lag, _KVO_short, _KVO_long, _KVO_signal)
    KVO = kvoResult.KVO
    KVOsignal = kvoResult.KVOsignal
    debug "KVO:#{KVO.toFixed(2)} KVOsignal:#{KVOsignal.toFixed(2)}"
    # plot chart data
    plot
        "KVO": KVO
        "KVOsignal": KVOsignal
