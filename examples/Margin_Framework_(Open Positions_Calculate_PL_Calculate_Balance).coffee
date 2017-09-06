#distant
#https://cryptotrader.org/topics/410871/margin-framework-open-positions-calculate-pl-calculate-balance
#I realized while I was coding my new margin bot that my statistics differed from what CryptoTrader was reporting as my ending balance.
#It had to do with the fact that when the back test completed, I still had an open position that I needed to account for.
#So no one else has to bang their head against the wall, here is code that should calculate what your current balance is while you have an open margin position.
#If your current balance ever reaches 0 or goes negative, then you would be margin called by the exchange.

mt = require 'margin_trading' # import margin trading module 
talib = require 'talib'  # import technical indicators library (https://cryptotrader.org/talib)

class Margin

    @OpenShort: (instrument, shortPrice, shortAmount, marginInfo) ->
        if (mt.sell instrument, 'limit', shortAmount/shortPrice, shortPrice)
            return true
        return false

    @OpenLong: (instrument, longPrice, longAmount, marginInfo) ->
        if (mt.buy instrument, 'limit', longAmount/longPrice, longPrice)
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
    storage.initialized ?= false

handle: ->
    instrument = @data.instruments[0]
    info = mt.getMarginInfo instrument
    pos = mt.getPosition instrument

    if (!storage.initialized)
        if (@Margin.OpenShort(instrument, instrument.price, info.tradable_balance, info))
            storage.startBalance = info.margin_balance
            storage.initialized = true

    debug "Starting Position Balance: #{storage.startBalance}"
    debug "Current Margin Balance: #{@Margin.OpenPositionCurrentBalance(instrument.price, storage.startBalance, pos)}"
    debug "Current Position P/L: #{@Margin.OpenPositionPL(instrument.price, pos).toFixed(2)}%"
    debug "----------------------------------------------"
    debug " "

onStop: ->
    instrument = @data.instruments[0]
    # unlike orders open positions don't get cancelled when the bot is stopped
    # the below snippet can be used to programmatically close it
    pos = mt.getPosition instrument
    if pos
        debug "Closing position"
        mt.closePosition instrument
