see also: https://cryptotrader.org/topics/640062/coding-ascending-and-descending-trigger-for-rsi
# Credits    : Thanasis
# Address BTC: 33Bz67vHXaKAL2GC9f3xWTxxoVKDqPrZ3H

talib   = require 'talib'
trading = require 'trading'

init: -> 

    @context.period_MA          = 30    # Moving Average Length
    @context.threshold_bottom   = 1     # %
    @context.threshold_top      = 1     # %

handle: ->

    instrument =   @data.instruments[0]
    price      =   instrument.close[instrument.close.length - 1]

    # MA - Moving average  
    ma = (data, lag, period, MAType) ->
        results = talib.MA
            inReal   : data
            startIdx : 0
            endIdx   : data.length - lag
            optInTimePeriod : period
            optInMAType     : MAType
    maResults = ma(instrument.close, 1, @context.period_MA, 0)   
    ma_last   = _.last(maResults)
    #debug ma_last

    ma_bottom  =  _.min(maResults)
    ma_top     =  _.max(maResults)
    #debug  ma_top
    #debug  ma_bottom 

    buy_condition  = ma_last <  ma_bottom * (1 + @context.threshold_bottom / 100)
    sell_condition = ma_last >  ma_top    * (1 - @context.threshold_top / 100)     

    currency_amount =  @portfolio.positions[instrument.curr()].amount
    asset_amount    =  @portfolio.positions[instrument.asset()].amount

    min_amount  =  0.001
    amount_buy  =  currency_amount / price
    amount_sell =  asset_amount  

    if buy_condition
        if amount_buy > min_amount
            trading.buy instrument, 'limit', amount_buy, price 
    else if sell_condition
        if amount_sell > min_amount
            trading.sell instrument, 'limit', amount_sell, price  
