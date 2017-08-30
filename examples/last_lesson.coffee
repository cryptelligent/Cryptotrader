
# from last lesson of university
#https://cryptotrader.org/topics/417406/developer-university-lesson-4-ta-lib-making-your-bot-smarter-part-1

talib = require "talib"
trading = require "trading"
params = require "params"

_maximumExchangeFee = params.add "Maximum exchange fee %", .25
_maximumOrderAmount = params.add "Maximum order amount", 1
_orderTimeout = params.add "Order timeout", 30
_plotShort = params.add "Plot short trend line", true
_plotLong = params.add "Plot long trend line", true
_plotBuy = params.add "Plot buy indicator", true
_plotSell = params.add "Plot sell indicator", true

MINIMUM_AMOUNT = .01

init: ->
    #This runs once when the bot is started
    setPlotOptions
        short:
            color: 'blue'
        long:
            color: 'gray'
        sellIndicator:
            color: 'red'
        buyIndicator:
            color: 'green'
        sell:
            color: 'orange'
        buy:
            color: 'purple'

handle: ->
    #This runs once every tick or bar on the graph
    storage.botStartedAt ?= data.at
    storage.lastShort ?= 0
    storage.lastLong ?= 0
    ins = data.instruments[0]
    assetsAvailable = @portfolios[ins.market].positions[ins.asset()].amount
    currencyAvailable = @portfolios[ins.market].positions[ins.curr()].amount
#    debug "The current price: #{ins.price}"

    maximumBuyAmount = (currencyAvailable/ins.price) * (1 - (_maximumExchangeFee/100))
    maximumSellAmount = (assetsAvailable * (1 - (_maximumExchangeFee/100)))

    short = talib.MA
        startIdx: 0
        endIdx: ins.close.length-1
        inReal: ins.close
        optInTimePeriod: 10
        optInMAType: 3

    lastShort = short[short.length - 2]
    short = short[short.length - 1]


    long = talib.MA
        startIdx: 0
        endIdx: ins.close.length-1
        inReal: ins.close
        optInTimePeriod: 21
        optInMAType: 3

    lastLong = long[long.length - 2]
    long = long[long.length - 1]

    if (_plotShort)
        plot
            short: short
    if (_plotLong)
        plot
            long: long

    if (lastShort != 0 and lastLong != 0)
        if (lastShort >= lastLong and short < long)
            if (maximumSellAmount >= MINIMUM_AMOUNT)
                trading.sell ins, 'limit', Math.min(_maximumOrderAmount, maximumSellAmount), ins.price, _orderTimeout
        else if (lastShort <= lastLong and short > long)
            if (maximumBuyAmount >= MINIMUM_AMOUNT)
                trading.buy ins, 'limit', Math.min(_maximumOrderAmount, maximumBuyAmount), ins.price, _orderTimeout

onRestart: ->
    debug "Bot restarted at #{new Date(data.at)}"

onStop: ->
    debug "Bot started at #{new Date(storage.botStartedAt)}"
    debug "Bot stopped at #{new Date(data.at)}"
