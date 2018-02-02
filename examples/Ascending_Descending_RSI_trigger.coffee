# see also https://cryptotrader.org/topics/640062/coding-ascending-and-descending-trigger-for-rsi
# Credits    : Thanasis
# Address BTC: 33Bz67vHXaKAL2GC9f3xWTxxoVKDqPrZ3H

talib   = require 'talib'
trading = require 'trading'

init: -> 

    @context.period_rsi         = 15    # RSI period
    @context.threshold_rsi_up   = 26    # RSI threshold up
    @context.threshold_rsi_down = 26    # RSI threshold down

handle: ->

    instrument =   @data.instruments[0]
    price      =   instrument.close[instrument.close.length - 1]

    ohlc4 = []
    x = 0
    until x is instrument.close.length
        O = instrument.open[x]
        H = instrument.high[x]
        L = instrument.low[x]
        C = instrument.close[x]

        ohlc4.push ((O + H + L + C) / 4)
        x++  

    #RSI - Relative Strength Index  
    rsi = (data, lag, period) ->
        results = talib.RSI
            inReal   : data
            startIdx : 0
            endIdx   : data.length - lag
            optInTimePeriod : period

    rsiResults    =   rsi(instrument.close, 1, @context.period_rsi)
    rsi_last      =   rsiResults[rsiResults.length - 1] 
    rsi_previous  =   rsiResults[rsiResults.length - 2]
    #debug "rsi_last: #{rsi_last}"
    #debug "rsi_previous: #{rsi_previous}" 

    condition_buy   = rsi_previous < @context.threshold_rsi_up   and rsi_last > @context.threshold_rsi_up
    condition_sell  = rsi_previous > @context.threshold_rsi_down and rsi_last < @context.threshold_rsi_up

    currency_amount =  @portfolio.positions[instrument.curr()].amount
    asset_amount    =  @portfolio.positions[instrument.asset()].amount

    min_amount  =  0.001
    amount_buy  =  currency_amount / price
    amount_sell =  asset_amount  

    if condition_buy
        if amount_buy > min_amount
            trading.buy instrument, 'limit', amount_buy, price 
    else if condition_sell
        if amount_sell > min_amount
            trading.sell instrument, 'limit', amount_sell, price 
