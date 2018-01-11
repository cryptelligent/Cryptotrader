###
    JulDXB RSI trading bot
    by cryptelligent
    see original request: https://cryptotrader.org/topics/815184/rsi-trading-bot
###
######################### Settings
trading = require 'trading' # import core trading module
talib = require 'talib' # import technical indicators library (https://cryptotrader.org/talib)

_upper_treshold = 70
_lower_treshold = 30
_fees = (1 - 0.0025) #your exchange fees here as number, not percent
_stoploss = 0.9 #price drop 10%
_timeout = 60 #order timeout in sec
_minAmount = 5 #min amount allowed by exchange, in fiat
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
    function print debug statements with balance and gain info
    @params - array of instruments
    @return: print debug messages
###
iniBalance = (ins) ->
    currency = @portfolios[ins.market].positions[ins.curr()].amount
    asetts = @portfolios[ins.market].positions[ins.asset()].amount
    total = (currency + asetts * ins.price).toFixed(2)
    coinName = ins._pair[1].toUpperCase()
    storage.inibalance = total
    storage.coin_ini = asetts
    storage.coin_price_ini = ins.price
    debug "Initial Balance: #{currency.toFixed(2)}#{coinName} + #{asetts.toFixed(4)}#{ins._pair[0].toUpperCase()}(#{(asetts * ins.price).toFixed(2)}#{coinName}) = #{total}#{coinName}"
    debug "Initial prices: #{asetts.toFixed(4)}#{ins._pair[0].toUpperCase()} price: #{ins.price.toFixed(2)}"
###
    function update storage values
    @params - array of instruments
    @return: none
###
updateStorage = (ins) ->
    currency = @portfolios[ins.market].positions[ins.curr()].amount
    asetts = @portfolios[ins.market].positions[ins.asset()].amount
    storage.coin = asetts
    storage.coin_price = ins.price
    total = (currency + asetts * ins.price).toFixed(2)
#    debug "currency:#{currency} assets:#{asetts} price:#{ins.price} = #{total}"
    realtotal = (currency + asetts * storage.coin_price_ini).toFixed(2)
#    debug "currency:#{currency} assets:#{asetts} price:#{storage.coin_price_ini} asstsXPrice:#{asetts * storage.coin_price_ini}"
    storage.realtotal = realtotal
    prev_balance = storage.balance
    storage.balance = total
    total_gain = ((storage.realtotal - storage.inibalance) * 100 / storage.inibalance).toFixed(2)
    storage.total_gain = total_gain
    coinName = ins._pair[1].toUpperCase()
    BH = ((storage.coin_price - storage.coin_price_ini) * 100 / storage.coin_price_ini).toFixed(2)
    storage.BH = "B&H: #{ins._pair[0].toUpperCase()}:#{BH}% "
###
    function print debug statements with balance and gain info
    @params - array of instruments
    @return: print debug messages
###
report = (ins) ->
    updateStorage(ins)
    coinName = ins._pair[1].toUpperCase()
    debug "Tick:#{storage.TICK} Balance: #{storage.balance}#{coinName} (before price change:#{storage.realtotal}#{coinName}) Gain/Loss total: #{storage.total_gain}% #{storage.BH}"
############### Init Initialization method called before trading logic starts
init: (context) ->

    context.lag  = 1
    context.period = 14
    setPlotOptions
        "RSI":
            color: 'blue'
            secondary: true
        "down":
            color: 'yellow'
            secondary: true
        "up":
            color: 'cyan'
            secondary: true

############## Main Called on each tick according to the tick interval that was set (e.g 1 hour)
handle: (context, data)->

    storage.TICK ?= 0
    ins = data.instruments[0]
    price = ins.price
    currency = @portfolios[ins.market].positions[ins.curr()].amount
    assets = @portfolios[ins.market].positions[ins.asset()].amount
    maximumSellAmount = assets
    maximumBuyAmount = currency * _fees / price
    minimumBuySellAmount = _minAmount / price
#    debug "assets:#{assets} currency:#{currency} maximumSellAmount:#{maximumSellAmount} maximumBuyAmount:#{maximumBuyAmount} minimumBuySellAmount;#{minimumBuySellAmount}"
    if not storage.TICK
        inibalance = iniBalance(ins)
        storage.up = 0
        storage.down = 0

    rsiResults  = rsi(ins.close,context.lag,context.period)
    if (rsiResults > _upper_treshold)
        storage.up++
        storage.down = 0
    else if (rsiResults < _lower_treshold)
        storage.down++
        storage.up = 0
    else
        storage.down = 0
        storage.up = 0
    # TRADING

    if (rsiResults > _upper_treshold) #sell
        if (maximumSellAmount > minimumBuySellAmount)
            try
                if trading.sell ins, 'market', maximumSellAmount
                    debug "sell order traded"
            catch e
                if /insufficient funds/i.exec e
                    warn "Insufficient funds error"
                else if /minimum order/i.exec e
                    warn "minimum order amount error"
                else
                    throw e # rethrow unhandled exception#
        #stop_loss
    else if (price < (storage.coin_price_ini * _stoploss))
        warn "stop_loss should be executed at price:#{price} of initial #{storage.coin_price_ini}"
        trading.sell ins, 'market', maximumSellAmount
    else if (rsiResults < _lower_treshold)
        if (maximumBuyAmount > minimumBuySellAmount)
            try
                if trading.buy ins, 'market', maximumBuyAmount
                    debug "buy order traded"
            catch e
                if /insufficient funds/i.exec e
                    warn "Insufficient funds error"
                else if /minimum order/i.exec e
                    warn "minimum order amount error"
                else
                    throw e # rethrow unhandled exception#
            storage.last_sale_price = price

    plot
        "RSI" : rsiResults
        if rsiResults > _upper_treshold
            plotMark
                "up": 100
        else if rsiResults < _lower_treshold
            plotMark
                "down": 0

    updateStorage(ins)
    if (storage.TICK % 4) == 0
        report(ins)
    storage.TICK++
#    debug "#{rsi}"






