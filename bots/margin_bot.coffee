#see https://cryptotrader.org/topics/410871/margin-framework-open-positions-calculate-pl-calculate-balance
#Edited for 1d by Stealthy7. Note: No stops are placed.

mt = require 'margin_trading' # import margin trading module 
talib = require 'talib'  # import technical indicators library (https://cryptotrader.org/talib)
params      = require 'params'
LEVLONG    = params.add 'Leverage LONG',1.8
LEVSHORT   = params.add 'Leverage SHORT',1.2
MA1P    = params.add 'MA1 Period',20
ORDER = params.addOptions 'Use Market or Limit orders?',['market','limit'],'limit' # default value is 'limit'
OFFSET  = params.add 'Trade price offset (%)',.0003
class FUNCTIONS
    @EMA: (data, period) ->
        if data.length < period
            period = data.length
        results = talib.EMA
          inReal: data
          startIdx: 0
          endIdx: data.length - 1
          optInTimePeriod: period
        _.last(results)
class Margin

    @OpenShort: (pos, instrument, shortPrice, shortAmount, marginInfo) ->
        if (pos)
            mt.closePosition instrument
            debug 'Closed Position'
        info = mt.getMarginInfo instrument
        pos = mt.getPosition instrument
        longAmount1 = info.margin_balance * context.marginLong
        shortAmount1 = info.margin_balance * context.marginShort
        longAmount = Math.min info.tradable_balance, longAmount1
        shortAmount = Math.min info.tradable_balance, shortAmount1            
        if not pos
            if (mt.sell instrument, ORDER, shortAmount/shortPrice, shortPrice*(1 - OFFSET))
                return true
        return false

    @OpenLong: (pos, instrument, longPrice, longAmount, marginInfo) ->
        if (pos)
            mt.closePosition instrument
            debug 'Closed Position'
        info = mt.getMarginInfo instrument
        pos = mt.getPosition instrument
        longAmount1 = info.margin_balance * context.marginLong
        shortAmount1 = info.margin_balance * context.marginShort
        longAmount = Math.min info.tradable_balance, longAmount1
        shortAmount = Math.min info.tradable_balance, shortAmount1
        if not pos
            if (mt.buy instrument, ORDER, longAmount/longPrice, longPrice*(1 + OFFSET))
                return true
        return false

    @OpenPositionPL: (currentPrice, marginPosition) ->
        pl = ((currentPrice - marginPosition.price)/marginPosition.price) * 100
        if (marginPosition.amount < 0)
            return -pl
        else
            return pl

    @OpenPositionCurrentBalance: (currentPrice, startingBalance, marginPosition) ->
        return (startingBalance + marginPosition.amount * (currentPrice - marginPosition.price))

init: -> 
    #Initialize things
    storage.bought ?= false
    storage.sold ?= false
    context.marginLong     = Math.max(Math.min(3.35,LEVLONG),0)
    context.marginShort     = Math.max(Math.min(3.35,LEVSHORT),0) 
handle: ->
    
    instrument = @data.instruments[0]
    info = mt.getMarginInfo instrument
    pos = mt.getPosition instrument
    longAmount1 = info.margin_balance * context.marginLong
    shortAmount1 = info.margin_balance * context.marginShort
    longAmount = Math.min info.tradable_balance, longAmount1
    shortAmount = Math.min info.tradable_balance, shortAmount1
    
    storage.calctick?=0
    if storage.calctick == 0
        storage.startBalance = info.margin_balance
        storage.start_price = instrument.price
    storage.startBalance ?= info.margin_balance        
    storage.calctick++

    ma1 = FUNCTIONS.EMA(instrument.close,MA1P)
    ohlc4 = (instrument.high[instrument.high.length-1] + instrument.low[instrument.low.length-1] + instrument.close[instrument.close.length-1] + instrument.open[instrument.open.length-1]) / 4

    if ohlc4>ma1
        if storage.sold==false
            if (@Margin.OpenLong(pos, instrument, instrument.price, longAmount, info))
                storage.sold=true
                storage.bought=false    
    
    
    if ohlc4<ma1
        if storage.bought==false
            if (@Margin.OpenShort(pos, instrument, instrument.price, shortAmount, info))
                storage.bought=true
                storage.sold=false

            

    debug "Starting Position Balance: #{storage.startBalance}"
    if pos
        debug "Current Margin Balance: #{@Margin.OpenPositionCurrentBalance(instrument.price, storage.startBalance, pos)}"
        debug "Current Position:" + (pos.amount).toFixed(4) + instrument.asset().toUpperCase() + ' at ' + (pos.price).toFixed(4) + instrument.base().toUpperCase()
        debug "Current Position P/L: #{@Margin.OpenPositionPL(instrument.price, pos).toFixed(2)}%"
        debug "----------------------------------------------"
        debug " "

    plot
        ma1:ma1
        ohlc4:ohlc4

    setPlotOptions
        ma1:
        #    secondary: 'true'
            color: 'orange'
            size:5
        ma2:
            secondary: 'true'
            color: 'blue'
            size:5            
onStop: ->
    instrument = @data.instruments[0]
    # unlike orders open positions don't get cancelled when the bot is stopped
    # the below snippet can be used to programmatically close it
    pos = mt.getPosition instrument
    if pos
        debug "Closing position"
        mt.closePosition instrument
