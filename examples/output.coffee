#aspiramedia
#utputs a log of the value of your portfolio
#https://cryptotrader.org/backtests/sdYLpzo3Q56dvDgDG
handle: (context, data, storage)->

    ins = data.instruments[0]
    price = ins.close[ins.close.length - 1]


    # STATS CODE
    storage.TICK ?= 0
    context.price = ins.close[ins.close.length - 1]
    context.balance_curr = portfolio.positions[ins.curr()].amount
    context.balance_btc = portfolio.positions[ins.asset()].amount

    if storage.TICK == 0
        storage.balance_curr_start = portfolio.positions[ins.curr()].amount
        storage.balance_btc_start = portfolio.positions[ins.asset()].amount
        storage.price_start = price

    starting_btc_equiv  = storage.balance_btc_start + storage.balance_curr_start / storage.price_start
    current_btc_equiv   = context.balance_btc + context.balance_curr / price
    starting_fiat_equiv = storage.balance_curr_start + storage.balance_btc_start * storage.price_start
    current_fiat_equiv  = context.balance_curr + context.balance_btc * price
    efficiency          = Math.round((current_btc_equiv / starting_btc_equiv) * 1000) / 1000
    efficiency_percent  = Math.round((((current_btc_equiv / starting_btc_equiv) - 1) * 100) * 10) / 10
    market_efficiency   = Math.round((((context.price / storage.price_start) - 1) * 100) * 10) / 10
    bot_efficiency      = Math.round((((current_fiat_equiv / starting_fiat_equiv) - 1) * 100) * 10) / 10

    storage.TICK++

    warn "### Day " + storage.TICK + " Log"
    debug "Current Fiat: " + Math.round(context.balance_curr*100)/100 + " | Current BTC: " +  Math.round(context.balance_btc*100)/100
    debug "Starting Fiat: " + Math.round(storage.balance_curr_start*100)/100 + " | Starting BTC: " +  Math.round(storage.balance_btc_start*100)/100
    debug "Current Portfolio Worth: " + Math.round(((context.balance_btc * price) + context.balance_curr)*100)/100
    debug "Starting Portfolio Worth: " + Math.round(((storage.balance_btc_start * storage.price_start) + storage.balance_curr_start)*100)/100
    debug "Efficiency of Buy and Hold: " + market_efficiency + "%"
    debug "Efficiency of Bot: " + bot_efficiency + "%"
    debug "Efficiency Vs Buy and Hold: " + efficiency + " which equals " + efficiency_percent + "%"
    warn "###"
