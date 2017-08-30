#Pivot Points
#v1.5   DiSTANT 21 days ago
#THIS BOT DOES NOT TRADE. IT IS ONLY FOR INFORMATIONAL PURPOSES TO ASSIST YOU WITH MAKING DECISIONS
#https://cryptotrader.org/strategies/5NDCqvnJGwLm2AP57
# see also http://www.investopedia.com/articles/technical/04/041404.asp
#Then what the hell is it you're probably asking? TA-lib doesn't provide a way to calculate pivot points, so I thought it would be helpful to provide the community with a way to do it. This particular bot calculates not only the standard pivot points, but it also calculate the Fibonacci and Demark pivot points. Hope this helps!

trading = require 'trading'
talib = require 'talib'

class Utilities
    @SetPivotPoints: (high, low, close, storage) ->
        storage.pp = (high + low + close) / 3
        storage.s1 = (2 * storage.pp) - high
        storage.s2 = storage.pp - (high - low)
        storage.s3 = low - (2 * (high - storage.pp))
        storage.r1 = (2 * storage.pp) - low
        storage.r2 = storage.pp + (high - low)
        storage.r3 = high + (2 * (storage.pp - low))
        warn "Resistance 3 - #{storage.r3.toFixed(8)}"
        warn "Resistance 2 - #{storage.r2.toFixed(8)}"
        warn "Resistance 1 - #{storage.r1.toFixed(8)}"
        debug " Pivot Point - #{storage.pp.toFixed(8)}"
        info "   Support 1 - #{storage.s1.toFixed(8)}"
        info "   Support 2 - #{storage.s2.toFixed(8)}"
        info "   Support 3 - #{storage.s3.toFixed(8)}"

init: ->
    storage.initialized = false

    setPlotOptions
        r3:
            color: '#621216'
            lineWidth: 1
        r2:
            color: '#d93436'
            lineWidth: 1
        r1:
            color: '#f06d6e'
            lineWidth: 1
        pp:
            color: '#75615a'
            lineWidth: 1
        s1:
            color: '#b2d649'
            lineWidth: 1
        s2:
            color: '#83bd1a'
            lineWidth: 1
        s3:
            color: '#446a12'
            lineWidth: 1

handle: ->
    instrument = @data.instruments[0]
    high = _.last instrument.high
    low = _.last instrument.low
    close = _.last instrument.close
    day = new Date(instrument.at).getDay()

    if (!storage.initialized)
        ticks = instrument.ticks
        if ((ticks.length - 1) < 288)
            debug "Not enough data to begin plotting (#{ticks.length - 1})"
            return
        storage.current_day = day
        tempDay = storage.current_day
        for tick in ticks.slice(0).reverse()
            current_high = tick.high
            current_low = tick.low
            current_close = tick.close

            current_day = new Date(tick.at).getDay()
            if (current_day != tempDay)
                if (!storage.initialized)
                    storage.initialized = true
                else
                    @Utilities.SetPivotPoints(storage.prevHigh, storage.prevLow, storage.prevClose, storage)
                    break
                storage.prevHigh = current_high
                storage.prevLow = current_low
                storage.prevClose = current_close
                tempDay = current_day

            storage.prevHigh = Math.max(current_high, storage.prevHigh)
            storage.prevLow = Math.min(current_low, storage.prevLow)
            storage.prevClose = storage.prevClose


    storage.prevHigh = Math.max(storage.prevHigh, high)
    storage.prevLow = Math.min(storage.prevLow, low)
    storage.prevClose = close

    if (storage.current_day != day)
        @Utilities.SetPivotPoints(storage.prevHigh, storage.prevLow, storage.prevClose, storage)
        storage.prevHigh = high
        storage.prevLow = low
        storage.prevClose = close
        storage.current_day = day

    plot
        r3: storage.r3
        r2: storage.r2
        r1: storage.r1
        pp: storage.pp
        s1: storage.s1
        s2: storage.s2
        s3: storage.s3
