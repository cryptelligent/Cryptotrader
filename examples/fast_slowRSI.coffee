#see also https://cryptotrader.org/topics/226846/rsi-based-on-rsi
# Credits    : Thanasis
# Address BTC: 33Bz67vHXaKAL2GC9f3xWTxxoVKDqPrZ3H

talib   = require 'talib'
trading = require 'trading'

init: (context, storage) ->

    context.period_fast = 10
    context.period_slow = 10

handle: (context, data) ->
    instrument =   data.instruments[0]

    rsi_fast = (data, period, last = true) ->
        period = data.length unless data.length >= period
        results_fast = talib.RSI
          inReal: data
          startIdx: 0
          endIdx: data.length - 1
          optInTimePeriod: context.period_fast
        if last then _.last(results_fast) else results_fast
    rsi_fast_Results  = rsi_fast(instrument.close, context.period_fast, false)
    rsi_fast_Results1 = rsi_fast(instrument.close, context.period_fast, true)

    rsi_slow = (data, period, last = true) ->
        period = data.length unless data.length >= period
        results_slow = talib.RSI
          inReal: rsi_fast_Results
          startIdx: 0
          endIdx: rsi_fast_Results.length - 1
          optInTimePeriod: context.period_slow
        if last then _.last(results_slow) else results_slow
    rsi_slow_Results  = rsi_slow(instrument.close, context.period_slow, false)
    rsi_slow_Results2 = rsi_slow(instrument.close, context.period_slow, true)

    info "rsi1: #{rsi_fast_Results1}"    
    info "rsi2: #{rsi_slow_Results2}"   
