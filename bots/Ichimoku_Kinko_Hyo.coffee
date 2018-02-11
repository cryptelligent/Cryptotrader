###
    Ichimoku Kinko Hyo
    version 0.1
    by cryptelligent
###
trading = require 'trading'
talib = require 'talib'
params = require 'params'
######################### Settings

tenkan_sen_period   = params.add '☛ Tenkan Sen period', 9
kijun_sen_period    = params.add '☞ Kijun Sen period', 26
senkou_span_A_plot_ahead_period = params.add '★ Senkou Span A plot ahead period', 26
senkou_span_B_plot_ahead_period = params.add '☆ Senkou Span B plot ahead period', 26
senkou_span_B_period = params.add '☆ Senkou Span B period', 52
#_MFI_upper_treshold = params.add '• MFI upper treshold', 70
#_MFI_lower_treshold = params.add '• MFI lower treshold', 30
#_MFIperiod = params.add '• MFI period', 9
_useTenkan_Kijun_Cross = params.add 'Use Tenkan Sen / Kijun Sen Cross', false
_useKijun_Cross = params.add 'Use Kijun Sen Cross', false
_useSenkou_Cross = params.add 'Use Senkou Span Cross', false
_minAmount = 0.0001
_equability_treshold  = 0.001
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
    _.last(results)
###
    fuction to calculate kijun_sen line
    The Kijun Sen, also known as the Standard or Base line, is a moving average of the highest high and lowest low over the last 26 trading intervals.
    As with the Tenkan Sen, the Kijun Sen is primarily used to measure momentum, however because of its longer time period it is a more reliable indicator of trend.
    A flatter Kijun Sen indicates a range bound price, while an inclined line indicates a trend, with the angle of the line showing the momentum of the trend.
    @params - instrument, period
    @return: kijun_sen value
###
kijun_sen = (ins, period) ->
    period = period + 1
    high_arr = ins.high.slice(ins.high.length - period)
    low_arr  = ins.low.slice(ins.low.length - period)
    maxHigh = _.max(high_arr)
    minLow  = _.min(low_arr)
    ks = (maxHigh + minLow) / 2
###
    fuction to calculate tenkan_sen line
    The Tenkan Sen, also known as the Turning or Conversion line, is a moving average of the highest high and lowest low over the last 9 intervals.
    It is primarily used to measure short-term momentum and is interpreted in the same manner as a short-term moving average.
    A steeply angled Tenkan Sen indicates a sharp recent price change or strong momentum, while a flatter Tenkan Sen indicates low or no momentum.
    The price breaching the Tenkan Sen may give an early indication of a trend change.
    @params - instrument, period
    @return: Tenkan Sen value
###
tenkan_sen = (ins, period) ->
    period = period + 1
    high_arr = ins.high.slice(ins.high.length - period)
    low_arr  = ins.low.slice(ins.low.length - period)
    maxHigh = _.max(high_arr)
    minLow  = _.min(low_arr)
    ts = (maxHigh + minLow) / 2
###
    fuction to calculate Senkou Span A line
    The Senkou Span A, also known as the 1st leading line, is a moving average of the Tenkan Sen and Kijun Sen and is plotted 26 trading intrevals ahead, i.e. into the future.
    It is primarily used in combination with the Senkou Span B to form the Kumo (cloud), to indicate probable future support and resistance levels.
    @params - instrument
    @return:  Senkou Span A value
###
senkou_span_A = (ins, period) ->
    period = period + 1
    start_t = ins.ticks.length - (tenkan_sen_period + period)
    start_k = ins.ticks.length - (kijun_sen_period + period)
    end = ins.ticks.length - period
    high_arr = ins.high.slice(start_t, end)
    low_arr  = ins.low.slice(start_t, end)
    maxHigh = _.max(high_arr)
    minLow  = _.min(low_arr)
    ts = (maxHigh + minLow) / 2
    high_arr = ins.high.slice(start_k, end)
    low_arr  = ins.low.slice(start_k, end)
    maxHigh = _.max(high_arr)
    minLow  = _.min(low_arr)
    ks = (maxHigh + minLow) / 2
    s_A = (ts + ks)/2
###
    fuction to calculate Senkou Span B line
    The Senkou Span B, also known as the 2nd leading line, is a moving average of the highest high and lowest low
    over the last 52 trading intervals is plotted 26 trading intervals ahead, i.e. into the future.
    As such it is the longest term representation of equilibrium in the Ichimoku system.
    It is primarily used in combination with the Senkou Span A to form the Kumo (cloud), to indicate probable future support and resistance levels.
    @params - instrument, senkou_span_B_period, senkou_span_B_plot_ahead_period
    @return:  Senkou Span B value
###
senkou_span_B = (ins, B_period, plot_ahead) ->
    plot_ahead = plot_ahead + 1
    start_t = ins.ticks.length - (B_period + plot_ahead)
    end = ins.ticks.length - plot_ahead
    high_arr = ins.high.slice(start_t, end)
    low_arr  = ins.low.slice(start_t, end)
    maxHigh = _.max(high_arr)
    minLow  = _.min(low_arr)
    s_B = (maxHigh + minLow)/2
###
    fuction to calculate relative difference of 2 values
    @params - values
    @return:  absolute rel difference
###
reldiff = (a, b) ->
    return Math.abs((a-b)/(a+b))
######################## Init Initialization method called before trading logic starts
init: ->
    info "==== Ichimoku Kinko Hyo  一目均衡表 ===="
    setPlotOptions
        "Tenkan Sen":
            color: 'red'
            lineWidth: 1
        "Kijun Sen":
            color: 'brown'
            lineWidth: 1
        "Senkou Span A" :
            color: 'black'
            lineWidth: 1
        "Senkou Span B" :
            color: 'gray'
            lineWidth: 1
        "MFI" :
            color: 'blue'
            lineWidth: 1
            secondary: true


    storage.prev_Tenkan_Sen ?= 0
    storage.prev_Kijun_Sen  ?= 0
    storage.prev_Senkou_A   ?= 0
    storage.prev_Senkou_B   ?= 0

############## Main Called on each tick according to the tick interval that was set (e.g 1 hour)
handle: ->
    ins = @data.instruments[0]

    #initialize
    storage.TICK ?= 0

    price = ins.price
    currency = @portfolios[ins.market].positions[ins.curr()].amount
    assets = @portfolios[ins.market].positions[ins.asset()].amount
    maximumSellAmount = assets
    maximumBuyAmount = currency/ price
    minimumBuySellAmount = _minAmount
    #calculate indicators

#    mfiResult  = mfi(ins.high, ins.low, ins.close, ins.volumes, 1,_MFIperiod)
#    rsiResult  = rsi(ins.close,1,_RSIperiod)
    Tenkan_Sen  = tenkan_sen(ins, tenkan_sen_period)
    Kijun_Sen   = kijun_sen(ins, kijun_sen_period)
    Senkou_Span_A = senkou_span_A(ins, senkou_span_A_plot_ahead_period)
    Senkou_Span_B = senkou_span_B(ins, senkou_span_B_period, senkou_span_B_plot_ahead_period)

    #trading
    diff_above = (Math.min(Tenkan_Sen, Kijun_Sen) - Math.max(Senkou_Span_A, Senkou_Span_B))  / Math.max(Senkou_Span_A, Senkou_Span_B)
    diff_below = (Math.min(Senkou_Span_A, Senkou_Span_B) - Math.max(Tenkan_Sen, Kijun_Sen)) / Math.max(Tenkan_Sen, Kijun_Sen)
    TKcross_above_KUMO = if diff_above > 0.03 then true else false
    TKcross_below_KUMO = if diff_below > 0.05 then true else false
    equal  = Math.abs((Tenkan_Sen - Kijun_Sen) / (Tenkan_Sen + Kijun_Sen))

    #str1 Tenkan Sen / Kijun Sen Cross
    if _useTenkan_Kijun_Cross
        if ( TKcross_below_KUMO and (reldiff(Tenkan_Sen, Kijun_Sen) < _equability_treshold) and (storage.prev_Tenkan_Sen < storage.prev_Kijun_Sen))
            if  (maximumBuyAmount > minimumBuySellAmount)
                if trading.buy ins, 'market', maximumBuyAmount
                    storage.last_sale_price = price

        else if ( TKcross_above_KUMO and (reldiff(Tenkan_Sen, Kijun_Sen) < _equability_treshold) and (storage.prev_Tenkan_Sen > storage.prev_Kijun_Sen))
            if (maximumSellAmount > minimumBuySellAmount)
                if trading.sell ins, 'market', maximumSellAmount
                    storage.last_sale_price = price

    #str2 Kijun Sen Cross
    else if _useKijun_Cross #Kijun Sen Cross
        if  ((price > Math.max(Senkou_Span_A, Senkou_Span_B)) and (Kijun_Sen < _.last(ins.high)) and (Kijun_Sen >= _.last(ins.low)) and (storage.prev_price < storage.prev_Kijun_Sen))
            if  (maximumBuyAmount > minimumBuySellAmount)
                if trading.buy ins, 'market', maximumBuyAmount
                    storage.last_sale_price = price
        else if ((Kijun_Sen > Math.max(Senkou_Span_A, Senkou_Span_B)) and (Kijun_Sen <= _.last(ins.high)) and (Kijun_Sen >= _.last(ins.low)) and (storage.prev_price < storage.prev_Kijun_Sen))
            if (maximumSellAmount > minimumBuySellAmount)
                if trading.sell ins, 'market', maximumSellAmount
                    storage.last_sale_price = price
    #str3 Kijun Sen Cross
    else if _useSenkou_Cross
        if ((Kijun_Sen < Math.min(Senkou_Span_A, Senkou_Span_B)) and (reldiff(Senkou_Span_A, Senkou_Span_B) < _equability_treshold))
            if  (maximumBuyAmount > minimumBuySellAmount)
                if trading.buy ins, 'market', maximumBuyAmount
                    storage.last_sale_price = price
        else if ((price < Math.min(Senkou_Span_A, Senkou_Span_B)) and(reldiff(Senkou_Span_A, Senkou_Span_B) < _equability_treshold))
            if (maximumSellAmount > minimumBuySellAmount)
                if trading.sell ins, 'market', maximumSellAmount
                    storage.last_sale_price = price

    storage.prev_price = price
    storage.prev_Tenkan_Sen = tenkan_sen(ins, tenkan_sen_period+1)
    storage.prev_Kijun_Sen  = Kijun_Sen
    storage.prev_Senkou_A   = Senkou_Span_A
    storage.prev_Senkou_B   = Senkou_Span_A

    #plot
    plot
        "Tenkan Sen":   Tenkan_Sen
        "Kijun Sen" :   Kijun_Sen
        "Senkou Span A" : Senkou_Span_A
        "Senkou Span B" : Senkou_Span_B

    storage.TICK++







