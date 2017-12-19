###
  The script engine is based on CoffeeScript (http://coffeescript.org)
  The Cryptotrader API documentation is available at https://cryptotrader.org/api
  by stealthy7
  This is the previous day up to the current day in this array. What happens is it starts a new day and the VWAP starts over.
  see:https://cryptotrader.org/topics/080846/true-vwap
###

trading = require 'trading' # import core trading module
talib = require 'talib' # import technical indicators library (https://cryptotrader.org/talib)


# This method is called for each tick
handle: ->
    # data object provides access to market data
    i = @data.instruments[0]

    # Put your logic here
    c = new Date(data.at)
    hour = c.getHours()
    minutes = c.getMinutes()
    adj = ((hour / @config.interval) * 60) + Math.floor(minutes / @config.interval) + 1
    daylook = ((24 / @config.interval) * 60)

    #VWAP
    VWAParr = []
    for g in [(adj+daylook)..(adj+1)]
        sum = 0
        vsum = 0
        for n in [adj+daylook..(adj+daylook)-n]
            sum = (i.close[i.close.length-(n+g)] * i.volumes[i.volumes.length-(n+g)]) + sum
            vsum = i.volumes[i.volumes.length-(n+g)] + vsum
        VWAP = sum / vsum
        VWAParr.push VWAP
    for g in [adj..1]
        sum = 0
        vsum = 0
        for n in [adj..(adj)-n]
            sum = (i.close[i.close.length-(n+g)] * i.volumes[i.volumes.length-(n+g)]) + sum
            vsum = i.volumes[i.volumes.length-(n+g)] + vsum
        VWAP = sum / vsum
        VWAParr.push VWAP
    VWAP = VWAParr[VWAParr.length-1]
    debug VWAP
    plot
        VWAP: VWAP
