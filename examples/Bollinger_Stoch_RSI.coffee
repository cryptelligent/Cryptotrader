#by Thanasis
#see also:https://cryptotrader.org/topics/030570/litepresence-bollinger-banded-stochastic-rsi
talib = require 'talib'

init: (context)->
    context.bottom = 0
    context.FEAR = 20
    context.GREED = 80

handle: (context, data)->

    ins = data.instruments[0]

    rsi = (data, lag, period) ->
        results = talib.RSI
            inReal   : data
            startIdx : 0
            endIdx   : data.length - 1
            optInTimePeriod : period

    rsiResults = rsi(ins.close, 1, 14)
    rsi_last   = _.last(rsiResults)

    ##BBANDS - Bollinger Bands
    bbands = (data, lag, period, NbDevUp, NbDevDn, MAType) ->
        results = talib.BBANDS
            inReal   : data
            startIdx : 0
            endIdx   : data.length - lag
            optInTimePeriod : period
            optInNbDevUp    : NbDevUp
            optInNbDevDn    : NbDevDn
            optInMAType     : MAType
    bbandsResults  = bbands(rsiResults, 1, 14, 2, 2, 0)
    UpperBand_rsi  =  bbandsResults.outRealUpperBand
    MiddleBand_rsi =  bbandsResults.outRealMiddleBand
    LowerBand_rsi  =  bbandsResults.outRealLowerBand
    UpperBand_rsi_last  =  _.last(UpperBand_rsi)
    MiddleBand_rsi_last =  _.last(MiddleBand_rsi)
    LowerBand_rsi_last  =  _.last(LowerBand_rsi)

    plot
        upperband   : 0.1*(UpperBand_rsi_last + context.bottom)
        middleband  : 0.1*(MiddleBand_rsi_last + context.bottom)
        lowerband   : 0.1*(LowerBand_rsi_last + context.bottom)
        GREED       : 0.1*(context.GREED + context.bottom)
        FEAR        : 0.1*(context.FEAR + context.bottom)
