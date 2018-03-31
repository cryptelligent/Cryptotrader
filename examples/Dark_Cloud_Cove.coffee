#see also https://cryptotrader.org/topics/689769/example-for-indicatior-like-dark-cloud-cover-or-evening-star
#by Thanasis
talib   = require 'talib' 

init: ->

handle: ->

    CDLDARKCLOUDCOVER = (open, high,low,close,lag,penetration) ->
      results = talib.CDLDARKCLOUDCOVER
        open: open
        high: high
        low: low
        close: close
        startIdx: 0
        endIdx: high.length - lag
        optInPenetration: penetration


    CDLEVENINGSTAR = (open, high,low,close,lag,penetration) ->
      results = talib.CDLEVENINGSTAR
        open: open
        high: high
        low: low
        close: close
        startIdx: 0
        endIdx: high.length - lag
        optInPenetration: penetration

    instrument =   @data.instruments[0]

    CDLDARKCLOUDCOVER_RESULTS = CDLDARKCLOUDCOVER(instrument.high,instrument.low,instrument.close,instrument.volumes,1,0.3)

    CDLEVENINGSTAR_RESULTS = CDLEVENINGSTAR(instrument.high,instrument.low,instrument.close,instrument.volumes,1,0.3)

    debug "CDLDARKCLOUDCOVER: #{_.last(CDLDARKCLOUDCOVER_RESULTS)}"

    debug "CDLEVENINGSTAR: #{_.last(CDLEVENINGSTAR_RESULTS)}"
