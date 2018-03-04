# by WaveTrader 
#see also https://cryptotrader.org/topics/836866/plotting-stochastic
talib   = require 'talib'

class functions
    @stoch: (high,low,close,lag,fastK_period,slowK_period, slowK_MAType,slowD_period,slowD_MAType) ->
      results = talib.STOCH
        high: high
        low: low
        close: close
        startIdx: 0
        endIdx: high.length - lag
        optInFastK_Period: fastK_period
        optInSlowK_Period: slowK_period
        optInSlowK_MAType: slowK_MAType 
        optInSlowD_Period: slowD_period
        optInSlowD_MAType: slowD_MAType
      result =
        K: _.last(results.outSlowK)
        D: _.last(results.outSlowD)
      result  
init: ->
    context.lag = 1
    context.fastK_period = 3
    context.slowK_period = 14
    context.slowK_MAType = 0
    context.slowD_period = 14
    context.slowD_MAType = 0
    setPlotOptions
        _k:
            color: 'black'
            secondary: true
        _d:
            color: 'red'
            secondary: true
        _0:
            color: 'blue'
            secondary: true
        _100: 
            color: 'green'
            secondary: true

handle: ->
    instrument = @data.instruments[0]
    price = instrument.price
    stoch = functions.stoch(instrument.high,instrument.low,instrument.close,context.lag,context.fastK_period,context.slowK_period, context.slowK_MAType,context.slowD_period,context.slowD_MAType)

    plot
        _k: stoch.K
        _d: stoch.D
        _0: 0
        _100: 100
