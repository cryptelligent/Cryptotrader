###
    --- Simple RSI HELPER bot based on Heikin-Ashi Bars ---
    this bot send you email and SMS if RSI reach certain conditions
    and on certain price change
		Credits: aspiramedia, Chris Moody, Thanasis
    development by cryptelligent
###

trading = require 'trading' # import core trading module
talib = require 'talib' # import technical indicators library (https://cryptotrader.org/talib)
_maximumExchangeFee =  0.25
_fees = 0.9975 #calculated as 1-_maximumExchangeFee in number
MINIMUM_AMOUNT = 0.05
_stoploss = 0.95 #price drop 5%
_upper_treshold = 60
_lower_treshold = 40
SAFETY_FACTOR = 0.9
SEND_SMS = 0

class HEIKIN
    constructor: () ->

        @haclose = []

        # INITIALIZE ARRAYS
        for [0..500]
            @haclose.push 0

    calculate: (instrument) ->

        open = instrument.open[instrument.open.length-1]
        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # REMOVE OLD DATA
        @haclose.shift()

        # CALCULATE
        @haclose.push  ((open + high + low + close) / 4)

        # RETURN DATA
        return @haclose


init: (context)->

setPlotOptions
        "down":
            color: 'red'
            secondary: true
        "up":
            color: 'cyan'
            secondary: true
        "RSI":
            color: 'blue'
            secondary: true
        "send":
            color: 'yellow'
            secondary: true

    context.heikin = new HEIKIN()

    @context.period = 7        # EMA period
    @context.periodSLOW = 7    # EMA period

handle: (context, data)->
    storage.TICK ?= 0
    ins = data.instruments[0]
    if not storage.TICK
        storage.up = 0
        storage.down = 0
        storage.send = 0

    # CALLING INDICATORS
    heikin  =  context.heikin.calculate(ins)

    rsi = (data, period, last = true) ->
        period = data.length unless data.length >= period
        results = talib.RSI
          inReal: data
          startIdx: 0
          endIdx: data.length - 1
          optInTimePeriod: period
        if last then _.last(results) else results

    rsiResults = rsi(heikin, @context.periodSLOW)
    #newRSI = _.last(rsiResults)

    if (rsiResults > _upper_treshold)
        storage.up++
        storage.down = 0
    else if (rsiResults < _lower_treshold)
        storage.down++
        storage.up = 0
    else
        storage.down = 0
        storage.up = 0
#    debug "up:#{storage.up} down:#{storage.down}"

    # TRADING
    if ((rsiResults > _upper_treshold)  and (storage.up > 4))
        if (((ins.price * _fees) > (storage.last_sale_price + storage.last_sale_price*0.01)) and storage.last_sale_price) #increase 1%
            sendEmail "Hill. Time to sell? Price:#{ins.price}"
            if SEND_SMS
                sendSMS "Hill. Price:#{ins.price}"
            storage.send++
        else if ((ins.price < (storage.last_sale_price * _stoploss)) and (storage.up > 5))
            warn "stop_loss should be executed at price:#{ins.price} of previous #{storage.last_sale_price}"
            sendEmail "stop_loss should be executed at price:#{ins.price} of previous #{storage.last_sale_price}"
            storage.send++
            trading.sell ins, 'market', @portfolios[ins.market].positions[ins.asset()].amount
    else if ((rsiResults < _lower_treshold) and (storage.down > 4))
        sendEmail "Dip. Time to buy? Price:#{ins.price}"
        if SEND_SMS
            sendSMS "Dip. Price:#{ins.price}"
        storage.send++
        storage.last_sale_price = ins.price
    else
        storage.send = 0


    if storage.send
        plotsend = rsiResults
    # PLOTTING / DEBUG
    if storage.TICK > 1
        plot
            "RSI" : rsiResults
            if rsiResults > _upper_treshold
                plotMark
                    "up": 100

            else if rsiResults < _lower_treshold
                plotMark
                    "down": 0
            plotMark
                "send": plotsend

    if (storage.TICK % 4) == 0
        if storage.send
            debug "Notification sent #{storage.send} times"
        else
            debug "No notifications"
    storage.TICK++
