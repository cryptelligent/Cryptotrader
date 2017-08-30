trading = require 'trading'
talib = require 'talib'
params = require 'params'

RESOLUTION = params.add "Tick resolution in seconds", 5

handle: ->
    instrument = @data.instruments[0]
    high = _.last instrument.high
    low = _.last instrument.low
    close = _.last instrument.close
    startTime = data.at
    resolutionMs = RESOLUTION * 1000

    iterations = (instrument.interval * 60 * 1000 - 5000)/resolutionMs  #subtract 5 seconds to allow for the rest of the script to run

    for i in [0 .. parseInt(iterations) - 1]
        ticker = trading.getTicker(instrument)

        if (ticker.buy > high)
            debug "Last high has been broken"
        else if (ticker.sell < low)
            debug "Last low has been broken"

        debug "Internal tick @ #{new Date()}"
        debug "Current Buy: #{ticker.buy} Current Sell: #{ticker.sell}"
        debug ""

        sleep(resolutionMs)
