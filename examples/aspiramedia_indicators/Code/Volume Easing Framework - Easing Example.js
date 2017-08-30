###
aspiramedia: Volume Easing Framework
BTC: 13NaZc9w7H3WKBtjucY48fhh53tSKbXmTp
###

class Init

  @init_context: (context) ->

    context.lag              = 1
    context.period           = 20
    
    ###
    Volume Easing Parameters    
    ###

    context.easing           = 0.99  # How much to ease things through. Must be positive. Go higher than 1 to make it harder to buy/sell in high volumes
    context.trigger          = 4  # When to make the easing occur. Positive value. (Natr)

class functions

  @natr: (high, low, close, lag, period) ->
    results = talib.NATR
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results)  
     

init: (context) ->

  Init.init_context(context)

serialize: (context)->

handle: (context, data)->

    instrument =  data.instruments[0]
    price      =  instrument.close[instrument.close.length - 1]
    
    natr = functions.natr(instrument.high,instrument.low,instrument.close,context.lag,context.period) 

    easing = context.easing

    if natr < context.trigger
      easing = 1
    else
      easing = context.easing



    ###
    Plots
    ###

    plot
      trigger: context.trigger*100
      natr: natr*100

    if natr < context.trigger
      plot
        easingonoff: 0
    else
      plot 
        easingonoff: 100

    ###
    Example Logic
    ###

    if price > (instrument.ema(21) * 1.01) * easing
      buy instrument
    if price < (instrument.ema(21) * 0.99) / easing
      sell instrument
