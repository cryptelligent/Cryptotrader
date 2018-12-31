#by stealthy7 
#see  also https://cryptotrader.org/topics/140209/percentile-nearest-rank
###
  The script engine is based on CoffeeScript (http://coffeescript.org)
  The Cryptotrader API documentation is available at https://cryptotrader.org/api
  
###

#Percentile Nearest Rank

trading = require 'trading' # import core trading module
talib = require 'talib' # import technical indicators library (https://cryptotrader.org/talib)

class Functions
    @percentile_nearest_rank: (data, pnr_look, lag, percent) ->
        pnr_array = []
        if data.length < pnr_look
            pnr_look = data.length
        for x in [pnr_look+lag..1+lag]
            pnr_array.push data[data.length-x]
        pnr_array.sort (a, b) ->
            a - b
        index_pnr = Math.round(percent * pnr_look)
        result = pnr_array[index_pnr - 1]
handle: ->
    # data object provides access to market data
    instrument = @data.instruments[0]
    #percentile nearest rank
    pnr = @Functions.percentile_nearest_rank(instrument.close,20,0,0.5)
    #A percent value of 0.5 is 50% or the median.

    plot
        pnr:pnr
    debug pnr
