###
aspiramedia: Golden Ratio EMA plotter
BTC: 13NaZc9w7H3WKBtjucY48fhh53tSKbXmTp
###



init: (context) ->

handle: (context, data)->

    instrument =  data.instruments[0]
    price      =  instrument.close[instrument.close.length - 1]
    


    ###
    Plotting the Golden Ratio of EMAs
    ###

    plot
      ema1:     instrument.ema(250)
      ema2:     instrument.ema(155)
      ema3:     instrument.ema(95)
      ema4:     instrument.ema(59)
      ema5:     instrument.ema(36)
      ema6:     instrument.ema(22)
      ema7:     instrument.ema(13)
      ema8:     instrument.ema(9)


    ###
    Buy/Sell
    ###

    if instrument.ema(9) > instrument.ema(13) > instrument.ema(22) > instrument.ema(36) > instrument.ema(59) > instrument.ema(95) > instrument.ema(155) > instrument.ema(250)
        buy instrument
    else if instrument.ema(9) < instrument.ema(13) < instrument.ema(22) < instrument.ema(36) < instrument.ema(59) < instrument.ema(95) < instrument.ema(155) < instrument.ema(250)
        sell instrument