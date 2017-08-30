init: (context) ->

    context.angleshort = 45
    context.anglelong = 30

handle: (context, data)->

    instrument  =  data.instruments[0]
    balance_curr = portfolio.positions[instrument.curr()].amount
    balance_btc = portfolio.positions[instrument.asset()].amount

    priceactual = instrument.close[instrument.close.length - 1]
    price      =  instrument.close[instrument.close.length - 1] - instrument.close[instrument.close.length - 2]
    price10     =  instrument.close[instrument.close.length - 1] - instrument.close[instrument.close.length - 11]

    priceang = Math.atan(price / 1) * (180/Math.PI)
    price10ang = Math.atan(price10 / 10) * (180/Math.PI)

    ###
    Plots
    
    
    plot
        priceang : priceang
        price10ang : price10ang
    ###

    ###
    Example BUY/SELL Logic
    ###

    if balance_curr > 25
        if (priceang > context.angleshort && price10ang > context.anglelong)
            buy instrument, null, priceactual * 1.005, 5000
    if balance_btc > 0.05
        if (priceang < -context.angleshort && price10ang < -context.anglelong)
            sell instrument, null, priceactual * 0.995, 5000