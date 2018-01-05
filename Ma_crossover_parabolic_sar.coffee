# Credits : Thanasis
# Address : 33Bz67vHXaKAL2GC9f3xWTxxoVKDqPrZ3H

talib   = require 'talib'
trading = require 'trading'

init: -> 

    @context.period_fast        = 17    # EMA period fast
    @context.period_slow        = 72    # EMA period slow
    @context.period_rsi         = 14    # RSI period
    @context.threshold_rsi_low  = 30    # RSI threshold low
    @context.threshold_rsi_high = 70    # RSI threshold high
    @context.sar_accel          = 0.02  # SAR accelaration
    @context.sar_accelmax       = 0.2   # SAR max accelaration

handle: ->

    instrument =   @data.instruments[0]
    price      =   instrument.close[instrument.close.length - 1]

    #RSI - Relative Strength Index  
    rsi = (data, lag, period) ->
        results = talib.RSI
            inReal   : data
            startIdx : 0
            endIdx   : data.length - lag
            optInTimePeriod : period

    #SAR - Parabolic SAR
    sar = (high, low, lag, accel, accelmax) ->
        results = talib.SAR
            high     : high
            low      : low
            startIdx : 0
            endIdx   : high.length - lag
            optInAcceleration : accel
            optInMaximum      : accelmax

    rsiResults = rsi(instrument.close, 1, @context.period_rsi)
    rsi_last   = _.last(rsiResults)

    sarResults = sar(instrument.high, instrument.low, 1, @context.sar_accel, @context.sar_accelmax)
    sar_last   = _.last(sarResults)

    ema_fast   = instrument.ema(@context.period_fast)
    ema_slow   = instrument.ema(@context.period_slow)

    currency_amount =  @portfolio.positions[instrument.curr()].amount
    asset_amount    =  @portfolio.positions[instrument.asset()].amount

    min_amount  =  0.001
    amount_buy  =  currency_amount / price
    amount_sell =  asset_amount  

    if (ema_fast < ema_slow and rsi_last < @context.threshold_rsi_low) or price > sar_last
        if amount_buy > min_amount
            trading.buy instrument, 'limit', amount_buy, price 
    else if (ema_fast > ema_slow and rsi_last > @context.threshold_rsi_high) or price < sar_last
        if amount_sell > min_amount
            trading.sell instrument, 'limit', amount_sell, price
