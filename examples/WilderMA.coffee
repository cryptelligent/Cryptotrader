#see also https://cryptotrader.org/topics/589301/calculating-a-running-moving-average
#by Thanasis 
talib = require 'talib'

init  : (context)->

handle: (context, data)->

    instrument = data.instruments[0]

    runMA = (x, period, y) ->
        alpha = y
        sum = 0.0
        for n in [1..period]
            sum = (instrument.close[instrument.close.length - n] + (alpha - 1) * sum) / alpha

    runMA_Results         = runMA(instrument.close, 30, 15)
    runMA_Results_current = _.last(runMA_Results) 
    debug runMA_Results_current
