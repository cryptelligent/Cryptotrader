###
Multi conditional check bot
- Decides to trade only if x of y criteria are met
by aspiramedia
BTC: 1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class functions

    @ema: (data, lag, period) ->
      results = talib.EMA
        inReal: data
        startIdx: 0
        endIdx: data.length - lag
        optInTimePeriod: period
      _.last(results)

    @kama: (data, lag, period) ->
      results = talib.KAMA
        inReal: data
        startIdx: 0
        endIdx: data.length - lag
        optInTimePeriod: period
      _.last(results)

    @macd: (data, lag, FastPeriod,SlowPeriod,SignalPeriod) ->
      results = talib.MACD
       inReal: data
       startIdx: 0
       endIdx: data.length - lag
       optInFastPeriod: FastPeriod
       optInSlowPeriod: SlowPeriod
       optInSignalPeriod: SignalPeriod
      result =
        macd: _.last(results.outMACD)
        signal: _.last(results.outMACDSignal)
        histogram: _.last(results.outMACDHist)
      result

    @mom: (data,lag, period) ->
      results = talib.MOM
        inReal: data
        startIdx: 0
        endIdx: data.length - lag
        optInTimePeriod: period
      _.last(results)


init: (context)->

    context.lag               = 1
    context.period            = 10
    context.period2           = 20
    context.FastPeriod        = 5
    context.SlowPeriod        = 10
    context.SignalPeriod      = 5

    context.criteria1 = context.criteria2 = context.criteria3 = context.criteria4 = 0
    context.met = 0
    context.buythreshold = 3
    context.sellthreshold = 2

handle: (context, data)->

    instrument = data.instruments[0]
    
    # Indicators
    emashort = functions.ema(instrument.close,context.lag,context.period)
    emalong  = functions.ema(instrument.close,context.lag,context.period2)
    kamashort = functions.kama(instrument.close,context.lag,context.period) 
    kamalong = functions.kama(instrument.close,context.lag,context.period2) 
    macd = functions.macd(instrument.close, context.lag, context.FastPeriod,context.SlowPeriod,context.SignalPeriod)
    mom = functions.mom(instrument.close,context.lag,context.period) 

    # Criteria
    if (emashort > emalong)
      context.criteria1 = 1
    else
      context.criteria1 = 0

    if (kamashort > kamalong)
      context.criteria2 = 1
    else
      context.criteria2 = 0

    if (macd.histogram > 0)
      context.criteria3 = 1
    else
      context.criteria3 = 0

    if (mom > 0)
      context.criteria4 = 1
    else
      context.criteria4 = 0

    context.met = context.criteria1 + context.criteria2 + context.criteria3 + context.criteria4

    # Trading
    if context.met >= context.buythreshold
      buy instrument
    if context.met <= context.sellthreshold
      sell instrument


    # Plot
    plot
      met: context.met
      buy_threshold: context.buythreshold
      sell_threshold: context.sellthreshold
    setPlotOptions
      met:
        secondary: true
        lineWidth: 3
        color: 'black'
      buy_threshold:
        secondary: true
        lineWidth: 1
        color: 'green'
      sell_threshold:
        secondary: true
        lineWidth: 1
        color: 'red'