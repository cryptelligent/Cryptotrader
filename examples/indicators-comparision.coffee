### 
    This bot allow you to compare several indicators at once
    Just insert code to indicator and define it's trading logic
    by Cryptelligent
###
trading = require 'trading'
talib = require 'talib'
params = require 'params'
######################### Settings
_MFI_upper_treshold =  80
_MFI_lower_treshold =  20
_MFIperiod =  14
_RSI_upper_treshold =  70
_RSI_lower_treshold =  30
_RSIperiod =  14
_SAR_accel = 0.0025
_SAR_accel_max = 0.025
_minAmount = 0.001
######################## Functions
###
    function calculate RSI using standard module
    @params - data, lag (usually 1) and period
    @return: RSI
###
rsi = (data, lag, period) ->
    period = data.length unless data.length >= period
    results = talib.RSI
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    if _.last then _.last(results) else results
###
    function calculate MFI using standard module
    @params - data, lag (usually 1) and period
    @return: MFI
###
mfi = (high, low, close, volume,lag, period) ->
    results = talib.MFI
      high: high
      low: low
      close: close
      volume: volume
      startIdx: 0
      endIdx: high.length - lag
      optInTimePeriod: period
    if _.last then _.last(results) else results
###
    function calculate parabolic SAR using standard module
    @params - data, lag (usually 1), acceleration, max acceleration 
    @return: last SAR
###
sar = (high, low, lag, accel, accelmax) ->
    results = talib.SAR
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - lag
      optInAcceleration: accel
      optInMaximum: accelmax
    _.last(results)
###
    function calculate EMA (Exponential moving average) using standard module
    @params - data, lag (usually 1) and period
    @return: last EMA
###
ema = (data, lag, period) ->
    period = data.length unless data.length >= period
    results = talib.MA
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
      optInMAType: 0 #simple moving average. For more see:https://cryptotrader.org/topics/417406/developer-university-lesson-4-ta-lib-making-your-bot-smarter-part-1
    _.last(results)
###
    function exercise  rsi trading strategy
    @params - instrument
    @return: none
###
tradeRSI = (ins) ->
    price = ins.price
    currency = @portfolios[ins.market].positions[ins.curr()].amount
    assets = @portfolios[ins.market].positions[ins.asset()].amount
    maximumSellAmount = assets
    maximumBuyAmount = currency/ price
    minimumBuySellAmount = _minAmount

    if storage.indObjS[0].last_buy
        currency = 100
        maximumSellAmount = currency/storage.indObjS[0].last_buy
        maximumBuyAmount = 0
    else
        currency = 100
        maximumSellAmount = 0
        maximumBuyAmount = currency/price

    if ((storage.indObjS[0].val < _RSI_lower_treshold) and (maximumBuyAmount > minimumBuySellAmount))
#        if trading.buy ins, 'market', maximumBuyAmount, price
            storage.indObjS[0].last_buy = price
            storage.indObjS[0].last_sell = 0
#            dumpObj(storage.indObjS[0])
    else if ((storage.indObjS[0].val > _RSI_upper_treshold)  and (maximumSellAmount > minimumBuySellAmount))
#        if trading.sell ins, 'market', maximumSellAmount, price
            storage.indObjS[0].last_sell = price
            if storage.indObjS[0].last_buy > 0
                storage.indObjS[0].pl += (price - storage.indObjS[0].last_buy) *100 / storage.indObjS[0].last_buy
            storage.indObjS[0].last_buy = 0
#            dumpObj(storage.indObjS[0])

###
    function exercise  mfi trading strategy
    @params - instrument
    @return: none
###
tradeMFI = (ins) ->
    price = ins.price
    currency = @portfolios[ins.market].positions[ins.curr()].amount
    assets = @portfolios[ins.market].positions[ins.asset()].amount
    maximumSellAmount = assets
    maximumBuyAmount = currency/ price
    minimumBuySellAmount = _minAmount
    if storage.indObjS[1].last_buy
        currency = 100
        maximumSellAmount = currency/storage.indObjS[0].last_buy
        maximumBuyAmount = 0
    else
        currency = 100
        maximumSellAmount = 0
        maximumBuyAmount = currency/price
        
    if ((storage.indObjS[1].val < _MFI_lower_treshold) and (maximumBuyAmount > minimumBuySellAmount))
#        if trading.buy ins, 'market', maximumBuyAmount, price
            storage.indObjS[1].last_buy = price
            storage.indObjS[1].last_sell = 0
#            dumpObj(storage.indObjS[1])
    else if ((storage.indObjS[1].val > _MFI_upper_treshold)  and (maximumSellAmount > minimumBuySellAmount))
#        if trading.sell ins, 'market', maximumSellAmount, price
            storage.indObjS[1].last_sell = price
            if storage.indObjS[1].last_buy > 0
                storage.indObjS[1].pl += (price - storage.indObjS[1].last_buy) *100 / storage.indObjS[1].last_buy
            storage.indObjS[1].last_buy = 0
#            dumpObj(storage.indObjS[1])

###
    function exercise  SAR trading strategy
    @params - instrument, smothed price
    @return: none
###
tradeSAR = (ins, sar, ema) ->
    price = ins.price
    currency = @portfolios[ins.market].positions[ins.curr()].amount
    assets = @portfolios[ins.market].positions[ins.asset()].amount
    maximumSellAmount = assets
    maximumBuyAmount = currency/ price
    minimumBuySellAmount = _minAmount
    if storage.indObjS[2].last_buy
        currency = 100
        maximumSellAmount = currency/storage.indObjS[2].last_buy
        maximumBuyAmount = 0
    else
        currency = 100
        maximumSellAmount = 0
        maximumBuyAmount = currency/price
        
    if ((ema > sar) and (maximumBuyAmount > minimumBuySellAmount))
#        if trading.buy ins, 'market', maximumBuyAmount, price
            storage.indObjS[2].last_buy = price
            storage.indObjS[2].last_sell = 0
#            dumpObj(storage.indObjS[2])
    else if ((ema < sar)   and (maximumSellAmount > minimumBuySellAmount))
#        if trading.sell ins, 'market', maximumSellAmount, price
            storage.indObjS[2].last_sell = price
            if storage.indObjS[2].last_buy > 0
                storage.indObjS[2].pl += (price - storage.indObjS[2].last_buy) *100 / storage.indObjS[2].last_buy
            storage.indObjS[2].last_buy = 0
#            dumpObj(storage.indObjS[2])

###
    function dump complex object to the log
    @params - object
    @return: none
###
dumpObj = (obj) ->
    str = JSON.stringify(obj)
    debug "#{str}"

######################## Init Initialization method called before trading logic starts
init: ->
    info "==== Indicators comparison bot ===="
    setPlotOptions
        "MFI" :
            color: 'red'
            lineWidth: 1
            secondary: true
        "RSI" :
            color: 'blue'
            lineWidth: 1
            secondary: true
        "SAR" :
            color: 'orange'
            lineWidth: 2
        "EMA" :
            color: 'black'
            lineWidth: 1
        

############## Main Called on each tick according to the tick interval that was set (e.g 1 hour)
handle: ->
    ins = @data.instruments[0]

    #initialize
    storage.TICK ?= 0
    if storage.TICK < 1
	    storage.indObjS =
            [{
                name: "RSI",
                val: (rsi(ins.close,1, _RSIperiod)).toFixed(2),
                pl: 0
                last_buy: 0
                last_sell: 0
            },
            {
                name: "MFI",
                val: (mfi(ins.high, ins.low, ins.close, ins.volumes, 1, _MFIperiod)).toFixed(2),
                pl: 0
                last_buy: 0
                last_sell: 0
            },
            {
                name: "SAR",
                val: (sar(ins.high, ins.low, 1, _SAR_accel, _SAR_accel_max)).toFixed(2),
                pl: 0
                last_buy: 0
                last_sell: 0
            }]
    else
        price = ins.price
        currency = @portfolios[ins.market].positions[ins.curr()].amount
        assets = @portfolios[ins.market].positions[ins.asset()].amount
        maximumSellAmount = assets
        maximumBuyAmount = currency/ price
        minimumBuySellAmount = _minAmount
        #calculate indicators
        mfiResult  = mfi(ins.high, ins.low, ins.close, ins.volumes, 1, _MFIperiod)
        rsiResult  = rsi(ins.close, 1, _RSIperiod)
        sarResult  = sar(ins.high, ins.low, 1, _SAR_accel, _SAR_accel_max)
        emaResult  = ema(ins.close, 1, 2)
        #fill in obj properties
        storage.indObjS[0].val = (rsi(ins.close,1, _RSIperiod)).toFixed(2)
        storage.indObjS[1].val = (mfi(ins.high, ins.low, ins.close, ins.volumes, 1, _MFIperiod)).toFixed(2)
        storage.indObjS[2].val = (sar(ins.high, ins.low, 1, _SAR_accel, _SAR_accel_max)).toFixed(2)
        tradeRSI(ins)
        tradeMFI(ins)
        tradeSAR(ins, sarResult, emaResult)

        #plot
        plot
            "MFI" : mfiResult
            "RSI" : rsiResult
            "SAR" : sarResult
            "EMA" : emaResult
            
    storage.TICK++
onStop: ->
    info "_____  BOT STOPED  ____"
    for ind, i in storage.indObjS
        debug "Indicator: #{storage.indObjS[i].name} P/L: #{storage.indObjS[i].pl.toFixed(2)}"
