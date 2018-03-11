###
by litepresence
see also: https://cryptotrader.org/topics/030570/litepresence-bollinger-banded-stochastic-rsi
Bollinger Banded Stochastic RSI
###

init: (context)->
    context.bottom = 0
    context.FEAR = 20
    context.GREED = 80

handle: (context, data)->

    instrument = data.instruments[0]

    results = talib.STOCH
        high: instrument.high
        low: instrument.low
        close: instrument.close
        startIdx: 0
        endIdx: instrument.close.length-1
        optInFastK_Period: 14
        optInSlowK_Period: 3
        optInSlowK_MAType: 1
        optInSlowD_Period: 3
        optInSlowD_MAType: 1
    K = (_.last results.outSlowK) 
    D = (_.last results.outSlowD)

    results = talib.BBANDS
        inReal : results.outSlowD
        startIdx: 0
        endIdx: results.outSlowD.length-1
        optInTimePeriod:14
        optInNbDevUp : 2
        optInNbDevDn: 2
        # MAType: 0=SMA, 1=EMA, 2=WMA, 3=DEMA, 4=TEMA, 5=TRIMA, 6=KAMA, 7=MAMA, 8=T3 (Default=SMA)
        optInMAType : 0
    upperband = _.last(results.outRealUpperBand)
    middleband = _.last(results.outRealMiddleBand)
    lowerband = _.last(results.outRealLowerBand)
    
    plot
        upperband   : 0.1*(upperband + context.bottom)
        middleband  : 0.1*(middleband + context.bottom)
        lowerband   : 0.1*(lowerband + context.bottom)
        GREED       : 0.1*(context.GREED + context.bottom)
        FEAR        : 0.1*(context.FEAR + context.bottom)
        K           : 0.1*(K + context.bottom)
        D           : 0.1*(D + context.bottom)
     


