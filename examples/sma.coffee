#SMA
#SMA(4) to SMA(7)
#https://cryptotrader.org/strategies/XihPHsAeki5496QRv
###
#  The script engine is based on CoffeeScript (http://coffeescript.org)
#  The Cryptotrader API documentation is available at https://cryptotrader.org/api

###

trading = require 'trading' # import core trading module
talib = require 'talib' # import technical indicators library (https://cryptotrader.org/talib)
storage.lastAction = "sell"

# This method is called for each tick
handle: ->
    # data object provides access to market data
    instrument = @data.instruments[0]
    #debug "price: #{instrument.price} #{instrument.curr().toUpperCase()} at #{new Date(data.at)}"

    # Put your logic here

    storage.short = (instrument.price + storage.P1 + storage.P2 + storage.P3) / 4
    storage.long = (instrument.price + storage.P1 + storage.P2 + storage.P3 + storage.P4 + storage.P5 + storage.P6) / 7

    if storage.short > storage.long and storage.lastAction == "sell"
        storage.lastAction = "buy"
        storage.buyPrice = instrument.price
        trading.buy instrument, 'market', 5
    else if storage.short < storage.long and storage.lastAction == "buy"
        storage.lastAction = "sell"
        trading.sell instrument

    plot
        current: instrument.price
        short: storage.short
        long: storage.long

    storage.P6 = storage.P5
    storage.P5 = storage.P4
    storage.P4 = storage.P3
    storage.P3 = storage.P2
    storage.P2 = storage.P1
    storage.P1 = instrument.price
