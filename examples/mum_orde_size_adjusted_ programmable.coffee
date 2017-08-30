###
  The script engine is based on CoffeeScript (http://coffeescript.org)
  The Cryptotrader API documentation is available at https://cryptotrader.org/api

###

trading = require 'trading' # import core trading module
talib = require 'talib' # import technical indicators library (https://cryptotrader.org/talib)


# This method is called for each tick
handle: ->
    # data object provides access to market data
    instrument = @data.instruments[0]
    debug "price: #{instrument.price} #{instrument.base().toUpperCase()} at #{new Date(data.at)}"
    if not context.minOrder
        context.minOrder = 0.000000001
    while true
        try
            trading.buy instrument, 'limit',  context.minOrder, instrument.price
        catch e
            m = /minimum order amount is (.*?) (\w+)/.exec e
            if m
                context.minOrder = m[1]
                asset = m[2]
                debug "Adjusting min order size to #{context.minOrder} #{asset}"
            else
                throw e

