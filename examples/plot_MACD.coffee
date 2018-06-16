# see also https://cryptotrader.org/topics/936217/plotting-other-indicators-macd-etc
# by litepresence
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
         histogram: _.last(results.outMACDHist)
        result

init: (context) ->
    context.lag         = 1
    context.lagb        = 5
    context.period      = 12
    context.close 		= 1
    context.FastPeriod  = 12       
    context.SlowPeriod  = 26
    context.SignalPeriod= 9

handle: (context, data) ->
    instrument = data.instruments[0]
    macd = Functions.macd(instrument.close,context.lag,context.FastPeriod,context.SlowPeriod,context.SignalPeriod)
    macd_zero = 600
    macdp = macd.macd*5 + 600
    signal = macd.signal*5 + 600
    histogram = macd.histogram*12 + 600

    plot
        macd_zeroa: macd_zero
        macd_zerob: macd_zero
        macd_zero: macd_zero
        histogram: histogram
        macd: macdp
        signal: signal
        
    
    if histogram < macd_zero - 10
        plot
         macd_zeroa: macd_zero - 10
    if histogram < macd_zero - 20
        plot
         macd_zeroa: macd_zero - 20   
    if histogram < macd_zero - 30
        plot
         macd_zeroa: macd_zero - 30
    if histogram < macd_zero - 40
        plot
         macd_zeroa: macd_zero - 40       
    if histogram < macd_zero - 50
        plot
         macd_zeroa: macd_zero - 50     
    if histogram < macd_zero - 60
        plot
         macd_zeroa: macd_zero - 60 
    if histogram < macd_zero - 70
        plot
         macd_zeroa: macd_zero - 70     
    if histogram < macd_zero - 80
        plot
         macd_zeroa: macd_zero - 80        
        
    if histogram > macd_zero + 10
        plot
         macd_zerob: macd_zero + 10
    if histogram > macd_zero + 20
        plot
         macd_zerob: macd_zero + 20   
    if histogram > macd_zero + 30
        plot
         macd_zerob: macd_zero + 30
    if histogram > macd_zero + 40
        plot
         macd_zerob: macd_zero + 40       
    if histogram > macd_zero + 50
        plot
         macd_zerob: macd_zero + 50     
    if histogram > macd_zero + 60
        plot
         macd_zerob: macd_zero + 60         
    if histogram > macd_zero + 70
        plot
         macd_zeroa: macd_zero + 70     
    if histogram > macd_zero + 80
        plot
         macd_zeroa: macd_zero + 80       
        
    if macd.macd > macd.signal  
        buy instrument
    if macd.macd < macd.signal 
        sell instrument
        
