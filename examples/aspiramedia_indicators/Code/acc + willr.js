###
aspiramedia accbands and willr bot
untuned
BTC: 13NaZc9w7H3WKBtjucY48fhh53tSKbXmTp
###

class Init

  @init_context: (context) ->

    context.lag              = 1
    context.period           = 20
    

class functions

  @accbands: (high, low, close, lag, period) ->
    results = talib.ACCBANDS
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
    result =
      UpperBand: _.last(results.outRealUpperBand)
      MiddleBand: _.last(results.outRealMiddleBand)
      LowerBand: _.last(results.outRealLowerBand)
    result
     
  @willr: (high, low, close, lag, period) ->
    results = talib.WILLR
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: 100
     _.last(results) 
     

  
init: (context) ->

  Init.init_context(context)

  context.ReadyToSell = 0
  context.ReadyToBuy = 0

serialize: (context)->

handle: (context, data)->

    instrument =  data.instruments[0]
    
    price      =  instrument.close[instrument.close.length - 1]
    open       =  instrument.open[instrument.open.length - 1]
    high       =  instrument.high[instrument.high.length - 1]
    low        =  instrument.low[instrument.low.length - 1]
    close      =  instrument.close[instrument.close.length - 1]
    volume     =  instrument.volumes[instrument.volumes.length - 1]
    
    price_lag  =  instrument.close[instrument.close.length - context.lag]
    open_lag   =  instrument.open[instrument.open.length - context.lag]
    high_lag   =  instrument.high[instrument.high.length - context.lag]
    low_lag    =  instrument.low[instrument.low.length - context.lag]
    close_lag  =  instrument.close[instrument.close.length - context.lag]
    volume_lag =  instrument.volumes[instrument.volumes.length - context.lag]



    accbands= functions.accbands(instrument.high, instrument.low, instrument.close, context.lag, context.period)
    willr = functions.willr(instrument.high,instrument.low,instrument.close, context.lag,context.period)

    plot 

        willr: willr + 400
        willrzero: 400
        willrthreshold: 360
        accUpper: accbands.UpperBand
        accMiddle: accbands.MiddleBand
        accLower: accbands.LowerBand



    if price < accbands.LowerBand && willr < -40
        sell instrument
        context.ReadyToSell = 0

    if price > accbands.UpperBand && willr > -40
        buy instrument
        context.ReadyToBuy = 0
   