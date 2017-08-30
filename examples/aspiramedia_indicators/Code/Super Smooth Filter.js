###
Super Smooth Filter
As shown by LazyBear on Tradeview here: https://www.tradingview.com/v/mgxOwThP/

Converted by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###


init: (context) ->

    context.period = 13

handle: (context, data, storage)->
    
    ###
    BASICS
    ###

    instrument  =   data.instruments[0]
    price       =   instrument.close[instrument.close.length - 1]
    period      =   context.period  

    unless storage.first_time
       storage.f2b          =  price
       storage.f2a          =  price
       
       storage.f3c          =  price
       storage.f3b          =  price
       storage.f3a          =  price

       storage.first_time   =  true

    ###
    CALCULATIONS
    ###
    
    # 2 Pole Super Smooth Filter
    p2    =   (instrument.high[instrument.close.length - 1] + instrument.low[instrument.close.length - 1])/2
    a2    =   Math.exp(-1.414*3.14159/period)
    b2    =   2 * a2 * Math.cos(1.414*180/period)
    f2coef2 =   b2
    f2coef3 =   -a2 * a2
    f2coef1 =   1 - f2coef2 - f2coef3

    f2 = f2coef1*p2+f2coef2*storage.f2a+f2coef3*storage.f2b

    storage.f2b = storage.f2a
    storage.f2a = f2

    # 3 Pole Super Smooth Filter
    p3    =   (instrument.high[instrument.close.length - 1] + instrument.low[instrument.close.length - 1])/2
    a3    =   Math.exp(-3.14159/period)
    b3    =   2 * a3 * Math.cos(1.414*180/period)
    c3    =   a3 * a3
    f3coef2 =   b3+c3
    f3coef3 =   -(c3+b3*c3)
    f3coef4 =   c3*c3
    f3coef1 =   1-f3coef2-f3coef3-f3coef4

    f3 = f3coef1*p3+f3coef2*storage.f3a+f3coef3*storage.f3b+f3coef4*storage.f3c

    storage.f3c = storage.f3b
    storage.f3b = storage.f3a
    storage.f3a = f3
    
    ###
    Debug
    ###

    debug "f2: " + f2 + " | f3: " + f3

    ###
    Plots
    ###

    plot
      f2: f2
      f3: f3
    

    ###
    Example BUY/SELL Logic
    ###

    if f3 < instrument.ema(10)
      buy instrument
    if f3 > instrument.ema(10)
      sell instrument