###
    This bot allow you to compare several indicators at once
    by Cryptelligent
  see also: https://cryptotrader.org/topics/951912/which-indicator-is-best-part2
###

trading = require 'trading' # import core trading module
talib = require 'talib' # import technical indicators library (https://cryptotrader.org/talib)
params = require 'params'
######################### Settings
_bb_period = 20

_RSI_upper_treshold = 70
_RSI_lower_treshold = 30
_RSIperiod = 9

_Stoch_upper_treshold = 80
_Stoch_lower_treshold = 20
_StochPeriod = 14

_MFI_upper_treshold = 80
_MFI_lower_treshold = 20
_MFIperiod = 14

_lag = 1
######################## Functions
###
    function Bollinger Bands
    @params - data, lag, period, NbDevUp, NbDevDn,MAType
    @return: UpperBand, MiddleBand, LowerBand
###
bbands = (data, lag, period, NbDevUp, NbDevDn,MAType) ->
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
###
    function calculate RSI using standard module
    @params - data, lag (usually 1) and period
    @return: RSI array
###
rsi = (data, lag, period) ->
    period = data.length unless data.length >= period
    results = talib.RSI
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    results
###
    function calculate MFI using standard module
    @params - data, lag  and period
    @return: MFI array
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
    results
###
    function calculate Simple Moving Average using standard module
    @params - data, lag  and period
    @return: SMA array
###
sma = (data, lag, period) ->
    results = talib.SMA
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    results
###
    function calculate StochRSI simplified
    after Thanasis https://github.com/cryptelligent/Cryptotrader/blob/master/examples/stochRSI
    @params - instrument, RSIperiod, StochPeriod
    @return: StochRSI k only
###
stochRSI = (ins, RSIperiod, lengthStoch) ->
    stochResults = []
    for n in [lengthStoch .. 1]
        rsiResults =   rsi(ins.close, n, _RSIperiod)
        rsi_last   = _.last(rsiResults)
        highest    = _.max(_.takeRight(rsiResults, lengthStoch))
        lowest     = _.min(_.takeRight(rsiResults, lengthStoch))
        stoch_rsi  =   100 * (rsi_last - lowest) / (highest - lowest)
        stochResults.push  stoch_rsi
    kResults = _.last(sma(stochResults, 1, 3))
    if kResults > 100 then kResults = 100
    if kResults < 0 then kResults = 0
    return kResults
######################### initialisation
init: ->
    storage.TICK ?= 0
    storage.lowsTotal ?= 0
    storage.RSI_match ?= 0
    storage.MFI_match ?= 0
    storage.Stoch_match ?= 0
    setPlotOptions
        "RSI":
            color: 'blue'
            secondary: true
        "stochRSIk":
            color: 'grey'
            secondary: true
        "MFI":
            color: 'red'
            secondary: true
        low:
            color: 'cyan'
            secondary: true
        up:
            color: 'cyan'
            secondary: true
################################# main
handle: ->
    ins = data.instruments[0]
    price = ins.price
    BB = bbands(ins.close, _lag, _bb_period, 2, 2, 0)
    UpperBand = BB.UpperBand
    LowerBand = BB.LowerBand
    rsiResult  = _.last(rsi(ins.close, _lag, _RSIperiod))
    mfiResult   = _.last(mfi(ins.high, ins.low, ins.close, ins.volumes, _lag, _MFIperiod))
    k  = stochRSI(ins, _RSIperiod, _StochPeriod)

    if price < LowerBand
        low = 10
        storage.lowsTotal++
    else
        low = 0
    if price > UpperBand
        up = 10
    else
        up = 0
    if (rsiResult < _RSI_lower_treshold) and (low > 0)
        storage.RSI_match++
    if (mfiResult < _MFI_lower_treshold) and (low > 0)
        storage.MFI_match++
    if (k < _Stoch_lower_treshold) and (low > 0)
        storage.Stoch_match++

    plot
        "RSI": rsiResult
        "MFI": mfiResult
        "stochRSIk": k
    if low > 0
        plotMark
            "low": 0
    if up > 0
        plotMark
            "up": 100

    storage.TICK++
###########################
onStop: ->
    RSI_match_perc = (100*(storage.lowsTotal - storage.RSI_match)/storage.lowsTotal).toFixed(2)
    MFI_match_perc = (100*(storage.lowsTotal - storage.MFI_match)/storage.lowsTotal).toFixed(2)
    Stoch_match_perc = (100*(storage.lowsTotal - storage.Stoch_match)/storage.lowsTotal).toFixed(2)
    info "Bot stoped. Here are results:"
    info "total lows:#{storage.lowsTotal}"
    info "RSI matched lows: #{RSI_match_perc}%"
    info "MFI matched lows: #{MFI_match_perc}%"
    info "StochRSI matched lows: #{Stoch_match_perc}%"
