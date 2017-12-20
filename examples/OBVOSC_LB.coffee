talib   = require 'talib' 
### by Thanasis 
### see: https://cryptotrader.org/topics/244098/lazybear-on-balance-volume-oscillator

init: -> 

    @context.period = 20

handle: ->

    #  EMA - Exponential Moving Average  
    ema = (data, lag, period) ->
        results = talib.EMA
            inReal   : data
            startIdx : 0
            endIdx   : data.length - lag
            optInTimePeriod : period

    #  OBV - On Balance Volume  
    obv = (data, volume, lag) ->
        results = talib.OBV
            inReal   : data
            volume   : volume
            startIdx : 0
            endIdx   : data.length - lag

    instrument =   @data.instruments[0] 

    obvResults = obv(instrument.close, instrument.volumes, 1)
    emaResults = ema(obvResults, 1, @context.period)

    obv_osc  = _.last(obvResults) - _.last(emaResults)

    debug "obv_osc: #{obv_osc}"

    setPlotOptions
        obv_osc:
            secondary: true
        zero:  
            secondary: true
    plot
        obv_osc:obv_osc
        zero: 0
