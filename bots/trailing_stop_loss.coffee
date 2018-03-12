###########################################################  
# see also:https://cryptotrader.org/topics/746664/thanasis-trailing-stop-loss                                                        #
# Thanasis      trailing stop loss                        #
#                                                         #
# Full name:    Thanasis Efthymiou                        #
#                                                         #
# BTC:          1P9EX4NMawDy1NR1EvYUUzyv8vEonwfwEZ        #
#                                                         #
# e-mail:       cryptotrader.thanasis@gmail.com           #
#                                                         #
###########################################################

class Init

########################################
#### define basic constants ############

  @init_context: (context) ->

   
   
    context.zig_zag_threshold   =  0.015   #%
    context.stop_percent        =  0.065   #%
    




    #context.NbDevUp         = 2
    #context.NbDevDn         = 2
    #context.FastPeriod      = 5
    #context.SlowPeriod      = 10
    #context.MAType          = 1
    #context.SignalPeriod    = 5
    #context.FastMAType      = 1
    #context.SlowMAType      = 1
    #context.SignalMAType    = 1
    #context.FastLimitPeriod = 5
    #context.SlowLimitPeriod = 10
    #context.periods         = 10
    #context.MinPeriod       = 5
    #context.MaxPeriod       = 10
    #context.StartValue      = 0
    #context.OffsetOnReverse = 0
    #context.accel           = 0.02
    #context.accelmax        = 0.20
    #context.AccelerationInitLong   = 0.02
    #context.AccelerationLong     = 0.02
    #context.AccelerationMaxLong    = 2.00
    #context.AccelerationInitShort  = 0.02
    #context.AccelerationShort      = 0.02
    #context.AccelerationMaxShort   = 2.00
    #context.fastK_period = 5
    #context.slowK_period = 10
    #context.slowK_MAType = 1
    #context.slowD_period = 10
    #context.slowD_MAType = 1
    #context.fastD_period = 5
    #context.fastD_MAType = 1
    #context.vfactor    = 1
    #context.Period1            = 5
    #context.Period2            = 10
    #context.Period3            = 20
    #context.NbDev              = 1
    #context.NbVar              = 1
    
    
 ######## flags #############################################

    context.plot_flag               = on
    context.stats_flag              = off

###### Serialized constants - don't touch bellow ###########

    context.stop                      =   0
    context.price_buy                 =   0
    context.price_sell                =   0 
    context.first_price               =   0
    context.number_of_orders          =   0
    context.have_fiat                 =   null
    context.have_coins                =   null
    context.commisions_paid           =   0
    context.price_of_last_order       =   null
    context.last_action_was           =   null


#################################################################################  

class ZigZag

    constructor: (@threshold) ->

        @data = 0.0
        @zigzag = 0.0

    filter: (@data) ->

        if @zigzag == 0.0
            @zigzag = @data
        d = (@data/@zigzag)-1
        if (d >= @threshold) or (d <= -@threshold)
            @zigzag = @data
        return @zigzag

#################################################################################

class functions

########################################
#### basic functions #############

  @diff: (x, y) ->
    (( x - y ) / (( x + y ) / 2)) * 100
    
  @percent: (x,y) ->

    (( x - y ) / y) * 100
    
  @norm_growth: (a,x) ->

    1 - Math.exp( - a * x )
    

########################################
####### indicatots ##################### 


  @accbands: (high, low, close, lag, period) ->
    results = talib.ACCBANDS
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
    result =
      UpperBand: _.last(results.outRealUpperBand)
      MiddleBand: _.last(results.outRealMiddleBand)
      LowerBand: _.last(results.outRealLowerBand)
    result
    
  @ad: (high,low,close,volume,lag,period) ->
    results = talib.AD
        high: high
        low: low
        close: close
        volume: volume
        startIdx: 0
        endIdx: high.length - lag
        optInTimePeriod: period
    _.last(results)  

  @adosc: (high, low, close, volume,lag,FastPeriod,SlowPeriod) ->
    results = talib.ADOSC
      high: high
      low: low
      close: close
      volume: volume
      startIdx: 0
      endIdx: high.length - lag
      optInFastPeriod: FastPeriod
      optInSlowPeriod: SlowPeriod
    _.last(results)
  
  @adx: (high, low, close, lag, period) ->
    results = talib.ADX
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results)
     
  @adxr: (high,low,close,lag,period) ->
    results = talib.ADXR
        high: high
        low: low
        close: close
        startIdx: 0
        endIdx: high.length - lag
        optInTimePeriod: period
     _.last(results)
     
  @apo: (data, lag, FastPeriod, SlowPeriod, MAType) ->
    results = talib.APO
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInFastPeriod: FastPeriod
      optInSlowPeriod: SlowPeriod
      optInMAType: MAType
    _.last(results)   
     
  @aroon: (high, low, lag, period) ->
    results = talib.AROON
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
    result =
      up: _.last(results.outAroonUp)
      down: _.last(results.outAroonDown)
    result
    
  @aroonosc: (high, low, lag, period) ->
    results = talib.AROONOSC
        high: high
        low: low
        startIdx: 0
        endIdx: high.length - lag
        optInTimePeriod: period
     _.last(results)
     
  @atr: (high, low, close, lag, period) ->
    results = talib.ATR
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results)
  
  @avgprice: (open,high,low,close,lag,period) ->
    results = talib.AVGPRICE
        open: open
        high: high
        low: low
        close: close
        startIdx: 0
        endIdx: open.length - lag
        optInTimePeriod: period
     _.last(results)
     
  @bbands: (data, period, lag, NbDevUp, NbDevDn,MAType) ->
    results = talib.BBANDS
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
      optInNbDevUp: NbDevUp
      optInNbDevDn: NbDevDn
      optInMAType: MAType
    result =
      UpperBand: _.last(results.outRealUpperBand)
      MiddleBand: _.last(results.outRealMiddleBand)
      LowerBand: _.last(results.outRealLowerBand)
    result
  
  @beta: (data_0,data_1,lag,period) ->
    results = talib.BETA
        inReal0: data_0
        inReal1: data_1
        startIdx: 0
        endIdx: data_0.length - lag
        optInTimePeriod: period
     _.last(results)
  
  @bop: (open, high, low, close, lag) ->
    results = talib.BOP
      open: open
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
     _.last(results)
  
  
  @cci: (high, low, close, lag, period) ->
    results = talib.CCI
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results)
  
  @cmo: (data,lag, period) ->
    results = talib.CMO
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results) 
  
  @correl: (data_0, data_1, lag, period) ->
    results = talib.CORREL
      inReal0: data_0
      inReal1: data_1
      startIdx: 0
      endIdx: data_0.length - lag
      optInTimePeriod: period
    _.last(results) 
   
  @dema: (data, lag, period) ->
    results = talib.DEMA
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)
    
  @dx: (high, low, close, lag, period) ->
    results = talib.DX
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results)
  
  @ema: (data, lag, period) ->
    results = talib.EMA
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)
 
  @ht_dcperiod: (data,lag) ->
    results = talib.HT_DCPERIOD
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
    _.last(results)
    
  @ht_dcphase: (data,lag) ->
    results = talib.HT_DCPHASE
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
    _.last(results)
    
  @ht_phasor: (data,lag) ->
    results = talib.HT_PHASOR
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
    result =
      phase: _.last(results.outInPhase)
      quadrature: _.last(results.outQuadrature)
    result
   
  
  @ht_sine: (data,lag) ->
    results = talib.HT_SINE
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
    _.last(results)   
    result =
      sine: _.last(results.outSine)
      leadsine: _.last(results.outLeadSine)
    result
  
   @ht_trendline: (data,lag) ->
    results = talib.HT_TRENDLINE
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
    _.last(results) 

  @ht_trendmode: (data,lag) ->
    results = talib.HT_TRENDMODE
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
    _.last(results)
 
  @imi: (high, close, lag, period) ->
    results = talib.IMI
      open: open
      close: close
      startIdx: 0
      endIdx: open.length - lag
      optInTimePeriod: period
     _.last(results)
 
  @kama: (data, lag, period) ->
    results = talib.KAMA
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)
 
  @linearreg: (data, lag, period) ->
    results = talib.LINEARREG
      inReal : data
      startIdx: 0
      endIdx: data.length-lag
      optInTimePeriod:period
    _.last(results)

  @linearreg_angle: (data, lag, period) ->
    results = talib.LINEARREG_ANGLE
      inReal : data
      startIdx: 0
      endIdx: data.length-lag
      optInTimePeriod:period
    _.last(results)


  @linearreg_intercept: (data, lag, period) ->
    results = talib.LINEARREG_INTERCEPT
      inReal : data
      startIdx: 0
      endIdx: data.length-lag
      optInTimePeriod:period
    _.last(results)
  
    
  @linearreg_slope: (data, lag, period) ->
    results = talib.LINEARREG_SLOPE
      inReal : data
      startIdx: 0
      endIdx: data.length-lag
      optInTimePeriod:period
    _.last(results)
    
 
  @ma: (data, lag, period,MAType) ->
    results = talib.MA
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
      optInMAType: MAType
    _.last(results)

  
  @macd: (data, lag, FastPeriod,SlowPeriod,SignalPeriod) ->
    results = talib.MACD
     inReal: data
     startIdx: 0
     endIdx: data.length - lag
     optInFastPeriod: FastPeriod
     optInSlowPeriod: SlowPeriod
     optInSignalPeriod: SignalPeriod
    result =
      macd: _.last(results.outMACD)
      signal: _.last(results.outMACDSignal)
      histogram: _.last(results.outMACDHist)
    result
 
 
  @macdext: (data, lag, FastPeriod,FastMAType, SlowPeriod,SlowMAType, SignalPeriod,SignalMAType) ->
    results = talib.MACDEXT
     inReal: data
     startIdx: 0
     endIdx: data.length - lag
     optInFastPeriod: FastPeriod
     optInFastMAType: FastMAType
     optInSlowPeriod: SlowPeriod
     optInSlowMAType: SlowMAType
     optInSignalPeriod: SignalPeriod
     optInSignalMAType: SignalMAType
    result =
      macd: _.last(results.outMACD)
      signal: _.last(results.outMACDSignal)
      histogram: _.last(results.outMACDHist)
    result
 
  @macdfix: (data,lag, SignalPeriod) ->
    results = talib.MACDFIX
     inReal: data
     startIdx: 0
     endIdx: data.length - lag
     optInSignalPeriod: SignalPeriod
    result =
      macd: _.last(results.outMACD)
      signal: _.last(results.outMACDSignal)
      histogram: _.last(results.outMACDHist)
    result

  @mama: (data, lag, FastLimitPeriod, SlowLimitPeriod) ->
    results = talib.MAMA
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInFastLimit: FastLimitPeriod
      optInSlowLimit: SlowLimitPeriod
    result =
      mama: _.last(results.outMAMA)
      fama: _.last(results.outFAMA)
    result   

  @mavp: (data,periods, lag,MinPeriod,MaxPeriod, MAType) ->
    results = talib.MAVP
      inReal: data
      inPeriods: periods
      startIdx: 0
      endIdx: data.length - lag
      optInMinPeriod: MinPeriod
      optInMaxPeriod: MaxPeriod
      optInMAType: MAType
     _.last(results)
      
  @max: (data, lag,period) ->
    results = talib.MAX
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results) 
  
  @maxindex: (data, lag,period) ->
    results = talib.MAXINDEX
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)
    
  
  @medprice: (high,low,lag,period) ->
    results = talib.MEDPRICE
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
    _.last(results)
  
  @mfi: (high, low, close, volume,lag, period) ->
    results = talib.MFI
      high: high
      low: low
      close: close
      volume: volume
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
    _.last(results)
   
  @midpoint: (data,lag,period) ->
    results = talib.MIDPOINT
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)  
  
  @midprice: (high, low, lag, period) ->
    results = talib.MIDPRICE
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
    _.last(results) 

  @min: (data, lag,period) ->
    results = talib.MIN
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)

  @minindex: (data, lag,period) ->
    results = talib.MININDEX
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)
    
  @minmax: (data,lag,period) ->
    results = talib.MINMAX
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    result =
      min: _.last(results.outMin)
      max: _.last(results.outMax)
    result  
  
   @minmaxindex: (data, lag,period) ->
    results = talib.MINMAXINDEX
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    result =
      min: _.last(results.outMinIdx)
      max: _.last(results.outMaxIdx)
    result
   
    
  @minus_di: (high, low, close, lag, period) ->
    results = talib.MINUS_DI
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results)
     
  @minus_dm: (high, low, lag, period) ->
    results = talib.MINUS_DM
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results)
     
  @mom: (data,lag, period) ->
    results = talib.MOM
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)
    
  @natr: (high, low, close, lag, period) ->
    results = talib.NATR
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results)  
  
  @obv: (data,volume,lag) ->
    results = talib.OBV
      inReal: data
      volume: volume
      startIdx: 0
      endIdx: data.length - lag
     _.last(results)  
     
  @plus_di: (high, low, close,lag, period) ->
    results = talib.PLUS_DI
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results)
  
  @plus_dm: (high, low, lag, period) ->
    results = talib.PLUS_DM
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results)   
  
  @ppo: (data, lag, FastPeriod, SlowPeriod, MAType) ->
    results = talib.PPO
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInFastPeriod: FastPeriod
      optInSlowPeriod: SlowPeriod
      optInMAType: MAType
    _.last(results)  
  
  @roc: (data, lag, period) ->
    results = talib.ROC
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results) 
  
  @rocp: (data, lag, period) ->
    results = talib.ROCP
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results) 
  
  @rocr: (data, lag, period) ->
    results = talib.ROCR
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results) 
  
  @rocr100: (data, lag, period) ->
    results = talib.ROCR100
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results) 
  
  @rsi: (data, lag, period) ->
    results = talib.RSI
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results) 
    
  @sar: (high, low, lag, accel, accelmax) ->
    results = talib.SAR
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - lag
      optInAcceleration: accel
      optInMaximum: accelmax
    _.last(results) 
  
  @sarext: (high,low,lag,StartValue, OffsetOnReverse, AccelerationInitLong,AccelerationLong,AccelerationMaxLong,AccelerationInitShort, AccelerationShort, AccelerationMaxShort) ->
    results = talib.SAREXT
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - lag
      optInStartValue: StartValue
      optInOffsetOnReverse: OffsetOnReverse
      optInAccelerationInitLong: AccelerationInitLong
      optInAccelerationLong: AccelerationLong
      optInAccelerationMaxLong: AccelerationMaxLong
      optInAccelerationInitShort: AccelerationInitShort
      optInAccelerationShort: AccelerationShort
      optInAccelerationMaxShort: AccelerationMaxShort
    _.last(results)   
  
  @sma: (data, lag, period) ->
    results = talib.SMA
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results) 
    
    
  @stddev: (data,  lag, period,NbDev) ->
    results = talib.STDDEV
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
      optInNbDev: NbDev
    _.last(results)
    
  @stoch: (high,low,close,lag,fastK_period,slowK_period, slowK_MAType,slowD_period,slowD_MAType) ->
    results = talib.STOCH
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInFastK_Period: fastK_period
      optInSlowK_Period: slowK_period
      optInSlowK_MAType: slowK_MAType 
      optInSlowD_Period: slowD_period
      optInSlowD_MAType: slowD_MAType
    result =
      K: _.last(results.outSlowK)
      D: _.last(results.outSlowD)
    result  

  @stochf: (high, low, close, lag, fastK_period,fastD_period,fastD_MAType) ->
    results = talib.STOCHF
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInFastK_Period: fastK_period
      optInFastD_Period: fastD_period
      optInFastD_MAType: fastD_MAType
    result =
      K: _.last(results.outFastK)
      D: _.last(results.outFastD)
    result
  
  @stochrsi: (data, lag, period, fastK_period,fastD_period,fastD_MAType) ->
    results = talib.STOCHRSI
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
      optInFastK_Period: fastK_period
      optInFastD_Period: fastD_period
      optInFastD_MAType: fastD_MAType
    result =
      K: _.last(results.outFastK)
      D: _.last(results.outFastD)
    result
  
  @sum: (data, lag, period) ->
    results = talib.SUM
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)
  
  @t3: (data, lag, period,vfactor ) ->
    results = talib.T3
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
      optInVFactor: vfactor
    _.last(results)
    
  @tema: (data, lag, period) ->
    results = talib.TEMA
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)
 
  @trange: (high, low, close,lag, period) ->
    results = talib.TRANGE
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results)  
  
  @trima: (data, lag, period) ->
    results = talib.TRIMA
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)
    
  @trix: (data, lag, period) ->
    results = talib.TRIX
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)  
    
  @tsf: (data,  lag, period) ->
    results = talib.TSF
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)
    
  @typprice: (high, low, close, lag, period) ->
    results = talib.TYPPRICE
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results)
     
  @ultosc: (high, low, close, lag, Period1,Period2,Period3) ->
    results = talib.ULTOSC
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod1: Period1
      optInTimePeriod2: Period2
      optInTimePeriod3: Period3
    _.last(results) 
  
  @variance: (data,  lag, period,NbVar) ->
    results = talib.VAR
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
      optInNbDev: NbVar
    _.last(results)   
  
  @wclprice: (high, low, close, lag, period) ->
    results = talib.WCLPRICE
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results)
     
  @willr: (high, low, close, lag, period) ->
    results = talib.WILLR
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
     _.last(results) 
     
  @wma: (data, lag, period) ->
    results = talib.WMA
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    _.last(results)
    
#################################################################################

  
init: (context) ->

  Init.init_context(context)

  context.zigzag = new ZigZag(context.zig_zag_threshold) 

#################################################################################

serialize: (context)->

    stop_loss_buy       =   context.stop
    price_of_last_order =   context.price_of_last_order   
    context.price_buy   =   context.price_buy
    context.price_sell  =   context.price_sell
    number_of_orders    =   context.number_of_orders 
    have_fiat           =   context.have_fiat
    have_coins          =   context.have_coins 
    first_price         =   context.first_price
    first_price_found   =   context.first_price_found
    first_capital       =   context.first_capital
    commisions_paid     =   context.commisions_paid
    last_action_was     =   context.last_action_was
    
  
#################################################################################

handle: (context, data)->

 
########################################
####### define instrument ##############

    instrument =  data.instruments[0]
    
    price      =  instrument.close[instrument.close.length - 1]
    open       =  instrument.open[instrument.open.length - 1]
    high       =  instrument.high[instrument.high.length - 1]
    low        =  instrument.low[instrument.low.length - 1]
    close      =  instrument.close[instrument.close.length - 1]
    volume     =  instrument.volumes[instrument.volumes.length - 1]
    
    price_lag  =  instrument.close[instrument.close.length - 1 - context.lag]
    open_lag   =  instrument.open[instrument.open.length - 1 - context.lag]
    high_lag   =  instrument.high[instrument.high.length - 1 - context.lag]
    low_lag    =  instrument.low[instrument.low.length - 1 - context.lag]
    close_lag  =  instrument.close[instrument.close.length - 1 - context.lag]
    volume_lag =  instrument.volumes[instrument.volumes.length - 1 - context.lag]

########################################
##### calculate capital ################    

    
    unless context.first_price_found
      context.first_price           =  price
      fiat                          =  portfolio.positions[instrument.curr()].amount
      coins                         =  portfolio.positions[instrument.asset()].amount
      context.first_capital         =  fiat + coins * price
      last_action_was               =  null
      maximum = Math.max(fiat, coins * price)
      if maximum == fiat
         context.have_fiat          = true
         context.have_coins         = false 
      else 
         context.have_fiat          = false
         context.have_coins         = true  
      context.first_price_found     = true
    
    fiat     =  portfolio.positions[instrument.curr()].amount
    coins    =  portfolio.positions[instrument.asset()].amount
    capital  =  fiat + coins * price

    period_in_minutes = (instrument.ticks[2].at - instrument.ticks[1].at) / 60000
    fee      =  instrument.fee

    volume_sum1 = 0
    volume_sum2 = 0
    for i in [0..4]
       volume_sum1 = volume_sum1 + instrument.volumes[instrument.volumes.length - 1 - i]
       volume_sum2 = volume_sum2 + instrument.volumes[instrument.volumes.length - 6 - i]
    volume_trend = volume_sum1 / volume_sum2
    
   

########################################
##### define basic functions ###########

    #high_low_percent = functions.percent(high, low)



########################################
##### define indicator functions ####### 
  
    #ad = functions.ad(instrument.high,instrument.low,instrument.close,instrument.volumes,context.lag,context.period)
    #accbands= functions.accbands(instrument.high, instrument.low, instrument.close, context.lag, context.period)
    #adosc = functions.adosc(instrument.high, instrument.low, instrument.close, instrument.volumes,context.lag,context.FastPeriod,context.SlowPeriod)    
    #adx = functions.adx(instrument.high, instrument.low, instrument.close,context.lag, context.period) 
    #adxr = functions.adxr(instrument.high,instrument.low,instrument.close,context.lag,context.period) 
    #apo = functions.apo(instrument.close,context.lag,context.FastPeriod,context.SlowPeriod,context.MAType)
    #aroon = functions.aroon(instrument.high, instrument.low,context.lag,context.period)    
    #aroonosc = functions.aroonosc(instrument.high,instrument.low,context.lag,context.period) 
    #atr = functions.atr(instrument.high, instrument.low, instrument.close, context.lag, context.period) 
    #avgprice = functions.avgprice(instrument.open,instrument.high,instrument.low,instrument.close,context.lag,context.period)
    #bbands =  functions.bbands(instrument.close, context.period, context.lag, context.NbDevUp, context.NbDevDn,context.MAType) 
    #beta =  functions.beta(instrument.high,instrument.low,context.lag,context.period) 
    #bop = functions.bop(instrument.open,instrument.high,instrument.low,instrument.close,context.lag)
    #cci = functions.cci(instrument.high, instrument.low, instrument.close, context.lag,context.period) 
    #cmo = functions.cmo(instrument.close,context.lag, context.period) 
    #correl = functions.correl(instrument.high, instrument.low, context.lag, context.period)     
    #dema = functions.dema(instrument.close,context.lag,context.period) 
    #dx = functions.dx(instrument.high,instrument.low,instrument.close,context.lag,context.period) 
    #ema  = functions.ema(instrument.close,context.lag,context.period)
    #ht_dcperiod = functions.ht_dcperiod(instrument.close,context.lag)
    #ht_dcphase = functions.ht_dcphase(instrument.close,context.lag) 
    #ht_phasor = functions.ht_phasor(instrument.close,context.lag) 
    #ht_sine = functions.ht_sine(instrument.close,context.lag)
    #ht_trendline= functions.ht_trendline(instrument.close,context.lag)
    #ht_trendmode = functions.ht_trendmode(instrument.close,context.lag)
    #imi = functions.imi(instrument.open,instrument.close,context.lag,context.period) 
    #kama = functions.kama(instrument.close,context.lag,context.period) 
    #linearreg = functions.linearreg(instrument.close,context.lag,context.period) 
    #linearreg_angle = functions.linearreg_angle(instrument.close,context.lag,context.period) 
    #linearreg_intercept = functions.linearreg_intercept(instrument.close,context.lag,context.period) 
    #linearreg_slope = functions.linearreg_slope(instrument.close,context.lag,context.period)
    #ma = functions.ma(instrument.close,context.lag,context.period,context.MAType) 
    #macd = functions.macd(instrument.close, context.lag, context.FastPeriod,context.SlowPeriod,context.SignalPeriod)
    #macdext = functions.macdext(instrument.close, context.lag, context.FastPeriod,context.FastMAType, context.SlowPeriod,context.SlowMAType, context.SignalPeriod,context.SignalMAType) 
    #macdfix = functions.macdfix(instrument.close,context.lag,context.SignalPeriod) 
    #mama = functions.mama(instrument.close,context.lag,context.FastLimitPeriod,context.SlowLimitPeriod) 
    #mavp= functions.mavp(instrument.close,context.periods,context.lag,context.MinPeriod,context.MaxPeriod, context.MAType) 
    #max_high = functions.max(instrument.high, context.lag,context.period)
    #max_high = functions.max(instrument.high, context.lag,context.period)
    #maxindex = functions.maxindex(instrument.close,context.lag,context.period) 
    #medprice = functions.medprice(instrument.high,instrument.low,context.lag,context.period) 
    #mfi = functions.mfi(instrument.high, instrument.low, instrument.close, instrument.volumes, context.lag,context.period) 
    #midpoint = functions.midpoint(instrument.close,context.lag,context.period) 
    #midprice = functions.midprice(instrument.high, instrument.low,context.lag, context.period) 
    #min_low = functions.min(instrument.low, context.lag,context.period)
    #minindex = functions.minindex(instrument.close,context.lag,context.period) 
    #minmax = functions.minmax(instrument.close,context.lag,context.period) 
    #minmaxindex = functions.minmaxindex(instrument.close,context.lag,context.period) 
    #minus_di = functions.minus_di(instrument.high, instrument.low, instrument.close, context.lag, context.period)    
    #minus_dm = functions.minus_dm(instrument.high,instrument.low,context.lag,context.period)
    #mom = functions.mom(instrument.close,context.lag,context.period) 
    #natr = functions.natr(instrument.high,instrument.low,instrument.close,context.lag,context.period) 
    #obv = functions.obv(instrument.close,instrument.volumes,context.lag)
    #plus_di = functions. plus_di(instrument.high, instrument.low, instrument.close,context.lag, context.period) 
    #plus_dm = functions.plus_dm(instrument.high,instrument.low,context.lag,context.period) 
    #ppo = functions.ppo(instrument.close, context.lag, context.FastPeriod,context.SlowPeriod,context.MAType)
    #roc  = functions.roc(instrument.close,context.lag,context.period)
    #rocp = functions.rocp(instrument.close,context.lag,context.period) 
    #rocr = functions.rocr(instrument.close,context.lag,context.period) 
    #rocr100 = functions.rocr100(instrument.close,context.lag,context.period) 
    #rsi  = functions.rsi(instrument.close,context.lag,context.period)
    #sar = functions.sar(instrument.high, instrument.low, context.lag,context.accel, context.accelmax)    
    #sarext = functions.sarext(instrument.high,instrument.low,context.lag,context.StartValue, context.OffsetOnReverse, context.AccelerationInitLong,context.AccelerationLong,context.AccelerationMaxLong,context.AccelerationInitShort, context.AccelerationShort, context.AccelerationMaxShort) 
    #sma = functions.sma(instrument.close,context.lag,context.period) 
    #stddev = functions.stddev(instrument.close,  context.lag, context.period,context.NbDev) 
    #stoch = functions.stoch(instrument.high,instrument.low,instrument.close,context.lag,context.fastK_period,context.slowK_period, context.slowK_MAType,context.slowD_period,context.slowD_MAType)
    #stochf = functions.stochf(instrument.high, instrument.low, instrument.close, context.lag, context.fastK_period,context.fastD_period,context.fastD_MAType)
    #stochrsi = functions.stochrsi(instrument.close,context.lag,context.period,context.fastK_period,context.fastD_period,context.fastD_MAType) 
    #sum = functions.sum(instrument.close,context.lag,context.period) 
    #t3 = functions.t3(instrument.close,context.lag,context.period,context.vfactor)
    #tema = functions.tema(instrument.close,context.lag,context.period)
    #trange = functions.trange(instrument.high,instrument.low,instrument.close, context.lag,context.period)
    #trima = functions.trima(instrument.close,context.lag,context.period) 
    #trix = functions.trix(instrument.close,context.lag,context.period)
    #tsf = functions.tsf(instrument.close, context.lag, context.period) 
    #typprice = functions.typprice(instrument.high, instrument.low, instrument.close, context.lag, context.period) 
    #ultosc = functions.ultosc(instrument.high, instrument.low, instrument.close,context.lag, context.Period1,context.Period2,context.Period3) 
    #variance = functions.variance(instrument.close,context.lag,context.period,context.NbVar) 
    #wclprice = functions.wclprice(instrument.high,instrument.low,instrument.close, context.lag,context.period) 
    #willr = functions.willr(instrument.high,instrument.low,instrument.close, context.lag,context.period)
    #wma = functions.wma(instrument.close,context.lag,context.period)


    
###########################################
######    debug indicators ################ 
    
 
    #debug "#{ad}"
    #debug "#{accbands.UpperBand}  #{accbands.MiddleBand} #{accbands.LowerBand}"
    #debug "#{adosc}"
    #debug "#{adx}" 
    #debug "#{adxr}"
    #debug "#{apo}"
    #debug "#{aroon.up} #{aroon.down}"
    #debug "#{aroonosc}"
    #debug "#{atr} "
    #debug "#{avgprice}"
    #debug "#{bbands.UpperBand} #{bbands.MiddleBand} #{bbands.LowerBand}"
    #debug "#{beta}"
    #debug "#{bop}"
    #debug "#{cci}"
    #debug "#{cmo}"
    #debug "#{correl}"
    #debug "#{dema}"
    #debug "#{dx}"
    #debug "#{ema}"
    #debug "#{ht_dcperiod}"
    #debug "#{ht_dcphase}"
    #debug "#{ht_phasor.phase} #{ht_phasor.quadrature}"
    #debug "#{ht_sine.sine} #{ht_sine.leadsine}"
    #debug "#{ht_trendline}"   
    #debug "#{ht_trendmode}"
    #debug "#{imi}"
    #debug "#{kama}"
    #debug "#{linearreg}"
    #debug "#{linearreg_angle}"
    #debug "#{linearreg_intercept}"
    #debug "#{linearreg_slope}"
    #debug "#{ma}" 
    #debug "#{macd.macd}  #{macd.signal}  #{macd.histogram}"
    #debug "#{macdext.macd}  #{macdext.signal} #{macdext.histogram}"
    #debug "#{macdfix.macd}  #{macdfix.signal} #{macdfix.histogram}"
    #debug "#{mama.mama} #{mama.fama}"
    #debug "#{mavp}"
    #debug "#{max_high}
    #debug "#{maxindex}"
    #debug "#{medprice}"
    #debug "#{mfi}"
    #debug "#{midpoint}"
    #debug "#{midprice}"
    #debug "#{min_low}"
    #debug "#{minindex}"
    #debug "#{minmax.min} #{minmax.max}"
    #debug "#{minmaxindex.min} #{minmaxindex.max}"
    #debug "#{minus_di}"
    #debug "#{minus_dm}"
    #debug "#{mom}"
    #debug "#{natr}"
    #debug "#{obv}" 
    #debug "#{plus_di}"
    #debug "#{plus_dm}"
    #debug "#{ppo}"
    #debug "#{roc}"
    #debug "#{rocp}"
    #debug "#{rocr}"
    #debug "#{rocr100}"
    #debug "#{rsi}"
    #debug "#{sar}"
    #debug "#{sarext}"
    #debug "#{sma}"
    #debug "#{stddev}"
    #debug "#{stoch.K} #{stoch.D}"
    #debug "#{stochf.K} #{stochf.D}"
    #debug "#{stochrsi.K}#{stochrsi.D} "
    #debug "#{sum}"
    #debug "#{t3}"
    #debug "#{tema}"
    #debug "#{trange}"
    #debug "#{trima}"
    #debug "#{trix}"
    #debug "#{tsf }"
    #debug "#{typprice}"   
    #debug "#{ultosc} "   
    #debug "#{variance}"
    #debug "#{wclprice}"
    #debug "#{willr}"
    #debug "#{wma}"
  


########################################
###### bot strategy      ###############

    buy_signal   =  off
    sell_signal  =  off

    


    if context.have_fiat == true
      if context.zigzag.filter(instrument.price)   >  context.stop
        buy_signal   =  on
        sell_signal  =  off
        context.stop =  context.zigzag.filter(instrument.price)  - context.stop_percent * price  
      else if context.stop > context.zigzag.filter(instrument.price)  + context.stop_percent * price
        context.stop =  context.zigzag.filter(instrument.price)  + context.stop_percent * price

    if context.have_coins ==  true   
      if   context.zigzag.filter(instrument.price) <  context.stop
        buy_signal   =  off
        sell_signal  =  on
        context.stop =   context.zigzag.filter(instrument.price) + context.stop_percent * price  
      else if context.stop <  context.zigzag.filter(instrument.price)  - context.stop_percent * price
        context.stop =  context.zigzag.filter(instrument.price)  - context.stop_percent * price 


    
########################################
######    buy or sell orders  ##########

       
    
    if buy_signal and fiat > 10
 
        ######  don't touch bellow #####
        if context.have_fiat
           buy instrument, null, price * 1.001, 295
           context.number_of_orders    =  context.number_of_orders + 1
           context.price_buy           =  price
           context.commisions_paid     =  context.commisions_paid + fee * capital / 100
           context.price_of_last_order =  context.price_buy
           context.last_action_was     =  "buy"
           context.have_coins          =  true
           context.have_fiat           =  false

    
    
    if sell_signal
        
        ######  don't touch bellow #####
        if context.have_coins 
           sell instrument, null, price * 0.999, 295
           context.number_of_orders    =  context.number_of_orders + 1
           context.price_sell          =  price
           context.commisions_paid     =  context.commisions_paid + fee * capital / 100    
           context.price_of_last_order =  context.price_sell   
           context.last_action_was     =  "sell"
           context.have_coins          =  false
           context.have_fiat           =  true
    
########################################
######    plot  signals ################

    if context.plot_flag
       
      plot 
    
        zigzag: context.zigzag.filter(instrument.price)    
        stop: context.stop
   

#########################################
######   recalculate capital ############

    fiat     =  portfolio.positions[instrument.curr()].amount
    coins    =  portfolio.positions[instrument.asset()].amount
    capital  =  fiat + coins * price
    
    if context.have_fiat
       efficiency_of_last_trade = -functions.percent(price, context.price_of_last_order)
    else 
       efficiency_of_last_trade = functions.percent(price, context.price_of_last_order) 
   
    percent_buy_and_hold     =  Math.round(100 * functions.percent(price, context.first_price))/100
    percent_bot              =  Math.round(100 * functions.percent(capital, context.first_capital))/100
    efficiency_of_last_trade =  Math.round(100 * efficiency_of_last_trade)/100
    context.commisions_paid  =  Math.round(100 * context.commisions_paid)/100
    context.first_capital    =  Math.round(100 * context.first_capital)/100
    capital   =  Math.round(100 * capital)/100

 
############################################ 
######   debug  stats ######################    

  
    if context.stats_flag

       debug "###########################################################"
       debug "price now:  #{price}"
       debug "last action was '#{context.last_action_was}' at the price of:  #{context.price_of_last_order}"
       debug "smartness of the bot from the last trade:  #{efficiency_of_last_trade} %"
       debug "total number of buy/sell orders:  #{context.number_of_orders}"
       debug "total commisions paid by now:  #{context.commisions_paid}"
       debug "start capital:  #{context.first_capital}"
       debug "capital now:  #{capital}"
       debug "total buy and hold efficiency:  #{percent_buy_and_hold} %"    
       debug "total bot efficiency:  #{percent_bot} % "
   
   
 
    

    
    
