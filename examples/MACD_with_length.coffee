#see also https://cryptotrader.org/topics/020061/need-help-using-length-with-macd
#by Thanasis
talib = require "talib"
trading = require "trading"

class Functions
    @macd: (data, lag, FastPeriod,SlowPeriod,SignalPeriod) ->
        results = talib.MACD
         inReal: data
         startIdx: 0
         endIdx: data.length - lag - 1
         optInFastPeriod: FastPeriod
         optInSlowPeriod: SlowPeriod
         optInSignalPeriod: SignalPeriod
        result =
         macd: _.last(results.outMACD)
         signal: _.last(results.outMACDSignal)
         lastmacd: results.outMACD[results.outMACD.length - 3]
         lastsignal: results.outMACDSignal[results.outMACDSignal.length - 3]     
        result

init: (context) ->
    context.lag         = 10
    context.period      = 34
    context.close 		= 1
    context.FastPeriod  = 17       
    context.SlowPeriod  = 72
    context.SignalPeriod= 34

handle: (context, data) ->
    instrument = data.instruments[0]
    macd = Functions.macd(instrument.close,context.lag,context.FastPeriod,context.SlowPeriod,context.SignalPeriod)

    macdp = macd.macd*5 + 600
    signal = macd.signal*5 + 600
    


    plot
        macd: macdp
        signal: signal
        
    @storage.status ?= 'sold'    

    if macd.macd > macd.signal  and @storage.status == 'sold'
        trading.buy instrument
        @storage.status = 'bought'
    if macd.macd < macd.signal and @storage.status == 'bought'
        trading.sell instrument
        @storage.status = 'sold'        
        
    debug "MACD #{macd.macd}"
    debug "Last MACD #{macd.lastmacd}"
    debug "Signal #{macd.signal}"
    debug "Last Signal #{macd.lastsignal}"
