###
aspiramedia apo bot
untuned
BTC: 13NaZc9w7H3WKBtjucY48fhh53tSKbXmTp
###

class Init

  @init_context: (context) ->

    context.lag             = 1
    context.FastPeriod      = 20
    context.SlowPeriod      = 21
    context.MAType          = 1
    

class functions

  @apo: (data, lag, FastPeriod, SlowPeriod, MAType) ->
    results = talib.APO
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInFastPeriod: FastPeriod
      optInSlowPeriod: SlowPeriod
      optInMAType: MAType
    _.last(results)      

  
init: (context) ->

  Init.init_context(context)

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



    apo = functions.apo(instrument.close,context.lag, 9 , 10 , context.MAType)
    apo2 = functions.apo(instrument.close,context.lag, 10 , 11 , context.MAType)

    plot 
        apo: apo*10 + 450
        apo2: apo2*10 + 450
        zero: 450

    debug "#{apo} #{apo2}"

    
    if apo > apo2 * 1.02
        buy instrument

    if apo < apo2 * 0.98
        sell instrument
    
   