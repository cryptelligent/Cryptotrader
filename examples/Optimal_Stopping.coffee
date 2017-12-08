# Credits : Thanasis
# Address : 33Bz67vHXaKAL2GC9f3xWTxxoVKDqPrZ3H
#see also original requiest: https://cryptotrader.org/topics/718513/optimal-stopping-strategy

talib   = require 'talib'
trading = require 'trading'

init: -> 

    @context.hours_for_checking = 10 
    @context.win_threshold      = 37       

handle: ->

    instrument =   @data.instruments[0]
    price      =   instrument.close[instrument.close.length - 1]

    wins = 0
    for n in [1 .. @context.hours_for_checking]
        current_close    =  instrument.close[instrument.close.length - n]
        previous_close   =  instrument.close[instrument.close.length - (n+1)]
        if current_close >  previous_close
            wins += 1

    win_ratio = (wins / @context.hours_for_checking) * 100

    currency_amount =  @portfolio.positions[instrument.curr()].amount
    asset_amount    =  @portfolio.positions[instrument.asset()].amount

    min_amount  =  0.001
    amount_buy  =  currency_amount / price
    amount_sell =  asset_amount  

    if win_ratio > @context.win_threshold
        if amount_buy > min_amount
            trading.buy instrument, 'limit', amount_buy, price 
    else 
        if amount_sell > min_amount
            trading.sell instrument, 'limit', amount_sell, price   
