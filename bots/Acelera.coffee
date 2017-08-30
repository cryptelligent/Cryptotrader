#Acelera
#EuroTurtle
#https://cryptotrader.org/strategies/44k9TRewLmdMNb3SD
talib = require "talib"
trading = require "trading"
params = require "params"

_maximumExchangeFee = params.add "Maximum exchange fee %", .2
_maximumOrderAmount = params.add "Maximum order amount", 0.1
_iceberg = params.add "Iceberb size", 10
_stopLoss = params.add "StopLoss treshold", 0.8
_orderTimeout = params.add "Order timeout", 30
_plotGraphs = params.add "Plot lines and indicators", true


MINIMUM_AMOUNT = .01


init: ->
    #This runs once when the bot is started
    #necessary for ACC bands, I have no Idea of what it does:
    context.period = 20
    context.lag  = 1

    setPlotOptions # Sets the collors for the plots:
        UpperBand:
            color: 'blue'
        LowerBand:
            color: 'purple'
        sellIndicator:
            color: 'yellow'
        buyIndicator:
            color: 'orange'
        sell:
            color: 'red'
        buy:
            color: 'green'
        meanSell:
            color: 'red'
        meanBuy:
            color: 'green'
        short:
            color: 'grey'
        stopLoss:
            color: 'black'

handle: ->
    #This runs once every tick or bar on the graph
    storage.botStartedAt ?= data.at
    primaryInstrument = data.instruments[0]
    assetsAvailable = @portfolios[primaryInstrument.market].positions[primaryInstrument.asset()].amount
    currencyAvailable = @portfolios[primaryInstrument.market].positions[primaryInstrument.curr()].amount
    storage.firstBalance ?= assetsAvailable*primaryInstrument.price + currencyAvailable
    storage.startAssets ?= assetsAvailable + currencyAvailable/primaryInstrument.price



    Balance = assetsAvailable*primaryInstrument.price + currencyAvailable

    storage.AmountBought ?= 0  #amount of assets that were bougt while the bot was running.
    storage.AmountSold ?= 0 #ammount of assets sold while the bot was running
    storage.MeanSell ?= primaryInstrument.price
    storage.MeanBuy ?= primaryInstrument.price
    storage.leverageAccumulated ?= storage.MeanSell/storage.MeanBuy

    #increases or decreases the ammount to be traded according to previous performance
    r = (storage.MeanSell/storage.MeanBuy)*(storage.MeanSell/storage.MeanBuy)*(storage.MeanSell/storage.MeanBuy)*(storage.MeanSell/storage.MeanBuy)*(storage.MeanSell/storage.MeanBuy)*(storage.MeanSell/storage.MeanBuy)*(storage.MeanSell/storage.MeanBuy)*(storage.MeanSell/storage.MeanBuy)*(storage.MeanSell/storage.MeanBuy)*(storage.MeanSell/storage.MeanBuy)/_iceberg

    maximumBuyAmount = (currencyAvailable/primaryInstrument.price) * (1 - (_maximumExchangeFee/100))
    minimumBuyAmount = Math.min(Math.max(r*maximumBuyAmount,MINIMUM_AMOUNT), _maximumOrderAmount)
    maximumSellAmount = (assetsAvailable * (1 - (_maximumExchangeFee/100)))
    minimumSellAmount = Math.min(Math.max(r*maximumSellAmount,MINIMUM_AMOUNT), _maximumOrderAmount/2)

    BuyAmount = 0
    SellAmount = 0

#    @accbands: (high, low, close, lag, period) ->
    results = talib.ACCBANDS
      high: primaryInstrument.high
      low: primaryInstrument.low
      close: primaryInstrument.close
      startIdx: 0
      endIdx: primaryInstrument.high.length - context.lag
      optInTimePeriod: context.period
    result =
      UpperBand: _.last(results.outRealUpperBand)
      MiddleBand: _.last(results.outRealMiddleBand)
      LowerBand: _.last(results.outRealLowerBand)
    result

    width = 1- (result.UpperBand - result.LowerBand)/ result.LowerBand
    #info "width #{width}"

    if (_plotGraphs)
        plot
            UpperBand: result.UpperBand
        plot
            LowerBand: result.LowerBand
        plot
            meanSell: storage.MeanSell
        plot
            meanBuy: storage.MeanBuy
        plot
            short: short
        plot
            stopLoss: width*lastShort

    short = talib.MA
        startIdx: 0
        endIdx: primaryInstrument.close.length-1
        inReal: primaryInstrument.close
        optInTimePeriod: 5
        optInMAType: 3 #DEMA trades faster than EMA

    lLastShort = short[short.length - 3]
    lastShort = short[short.length - 2]
    short = short[short.length - 1]

    trade = 0

    #stop loss strategy:

    if (Balance < _stopLoss*storage.firstBalance or primaryInstrument.price < width*lastShort)
        warn "STOP LOSS"
        SellAmount = assetsAvailable
        if (SellAmount >= MINIMUM_AMOUNT)
            trading.sell primaryInstrument, 'limit', SellAmount, primaryInstrument.price, _orderTimeout
            storage.MeanSell = (storage.MeanSell*storage.AmountSold + primaryInstrument.price*SellAmount*(1 - (_maximumExchangeFee / 100))) / (storage.AmountSold+ SellAmount*(1 - (_maximumExchangeFee / 100)))
            storage.AmountSold = (storage.AmountSold+ SellAmount*(1 - (_maximumExchangeFee / 100)))
            trade = 1 # it prevents the bot from trading still in this tic
        if (_plotGraphs)
            plotMark
                sellIndicator: short

    # acc bands
    if (trade == 0) #only trades if stop loss was not activated;
        if (primaryInstrument.price <= result.UpperBand and short > result.UpperBand) # SELL
            #SellAmount = Math.max(Math.min(_maximumOrderAmount/2, maximumSellAmount/_iceberg), minimumSellAmount)
            #if (maximumSellAmount >= MINIMUM_AMOUNT)
                #trading.sell primaryInstrument, 'limit', SellAmount, primaryInstrument.price, _orderTimeout
                #storage.MeanSell = (storage.MeanSell*storage.AmountSold + primaryInstrument.price*SellAmount*(1 - (_maximumExchangeFee / 100))) / (storage.AmountSold+ SellAmount*(1 - (_maximumExchangeFee / 100)))
                #storage.AmountSold = (storage.AmountSold+ SellAmount*(1 - (_maximumExchangeFee / 100)))
                #trade = 1
            #if (_plotGraphs)
                #plotMark
                    #sellIndicator: short
        else if (short < result.LowerBand and primaryInstrument.price >= result.LowerBand) # BUY
            BuyAmount = Math.max(Math.min(_maximumOrderAmount, maximumBuyAmount/_iceberg), minimumBuyAmount)
            if (_plotGraphs)
                plotMark
                    buyIndicator: short
            if (maximumBuyAmount >= MINIMUM_AMOUNT)
                trading.buy primaryInstrument, 'limit', BuyAmount, primaryInstrument.price, _orderTimeout
                storage.MeanBuy = (storage.MeanBuy*storage.AmountBought + primaryInstrument.price*BuyAmount*(1 - (_maximumExchangeFee / 100))) / (storage.AmountBought + BuyAmount * (1 - (_maximumExchangeFee / 100)))
                storage.AmountBought = (storage.AmountBought + BuyAmount*(1 - (_maximumExchangeFee / 100)))
                trade = 1
    #end acc bands

    assetsAvailable = @portfolios[primaryInstrument.market].positions[primaryInstrument.asset()].amount
    currencyAvailable = @portfolios[primaryInstrument.market].positions[primaryInstrument.curr()].amount
    Balance = assetsAvailable*primaryInstrument.price + currencyAvailable
    BuyHold = storage.startAssets*primaryInstrument.price

    if (trade == 1)
        debug "The current price: #{primaryInstrument.price}"
        debug "Starting balance: #{storage.firstBalance}"
        debug "Balance: BTC #{assetsAvailable} (EUR #{assetsAvailable*primaryInstrument.price}) + EUR #{currencyAvailable} = EUR #{currencyAvailable + assetsAvailable*primaryInstrument.price}"

        debug "B&H: #{BuyHold}"
        debug "yeld: #{(Balance-storage.firstBalance)*100/storage.firstBalance}%"
        debug "mean leveage: #{storage.MeanSell/storage.MeanBuy}"
        storage.leverageAccumulated = storage.leverageAccumulated*storage.MeanSell/storage.MeanBuy
        debug "leveage accumulated: #{storage.leverageAccumulated}"
        debug "Bot/B&H: #{(Balance/BuyHold-1)*100}%"
        debug "_________________________________________________________________"

onRestart: ->
    debug "Bot restarted at #{new Date(data.at)}"

onStop: ->
   # info "Balance: BTC #{assetsAvailable} (EUR #{assetsAvailable*primaryInstrument.price} + EUR #{currencyAvailable} = EUR #{currencyAvailable + assetsAvailable*primaryInstrument.price}"
    debug "Bot started at #{new Date(storage.botStartedAt)}"
    debug "Bot stopped at #{new Date(data.at)}"
