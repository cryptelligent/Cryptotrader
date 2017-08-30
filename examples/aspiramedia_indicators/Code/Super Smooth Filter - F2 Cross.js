###
Super Smooth Filter
As shown by LazyBear on Tradeview here: https://www.tradingview.com/v/mgxOwThP/

Converted by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###


init: (context) ->

    context.short   = 5
    context.long    = 8

handle: (context, data, storage)->
    
    ###
    BASICS
    ###

    instrument  =   data.instruments[0]
    price       =   instrument.close[instrument.close.length - 1]
    periodshort =   context.short  
    periodlong  =   context.long

    unless storage.first_time
       storage.shortb          =  price
       storage.shorta          =  price
       storage.longb          =  price
       storage.longa          =  price
       storage.first_time   =  true

    ###
    CALCULATIONS
    ###
    
    p2    =   (instrument.high[instrument.close.length - 1] + instrument.low[instrument.close.length - 1])/2
    

    # Short
    shorta2    =   Math.exp(-1.414*3.14159/periodshort)
    shortb2    =   2 * shorta2 * Math.cos(1.414*180/periodshort)
    shortcoef2 =   shortb2
    shortcoef3 =   -shorta2 * shorta2
    shortcoef1 =   1 - shortcoef2 - shortcoef3

    short = shortcoef1*p2+shortcoef2*storage.shorta+shortcoef3*storage.shortb

    storage.shortb = storage.shorta
    storage.shorta = short

     # Long
    longa2    =   Math.exp(-1.414*3.14159/periodlong)
    longb2    =   2 * longa2 * Math.cos(1.414*180/periodlong)
    longcoef2 =   longb2
    longcoef3 =   -longa2 * longa2
    longcoef1 =   1 - longcoef2 - longcoef3

    long = longcoef1*p2+longcoef2*storage.longa+longcoef3*storage.longb

    storage.longb = storage.longa
    storage.longa = long

    

  
    
    ###
    Debug
    ###



    ###
    Plots
    ###

    plot
      short: short
      long: long

    

    ###
    Example BUY/SELL Logic
    ###

    if (short - storage.shortb) > (long - storage.longb) * 5 and short - storage.shortb > 0 && (short - storage.shortb) / (long - storage.longb) > 0
      buy instrument
    if (short - storage.shortb) < (long - storage.longb) * 0.2 and short - storage.shortb < 0 && (short - storage.shortb) / (long - storage.longb) < 0
      sell instrument
    