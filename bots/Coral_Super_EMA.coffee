###
Coral Super EMA
 tiktak
https://cryptotrader.org/strategies/icy6C9BG7b8Fnyo77
Supertrend and Coral indicators written by Aspiramedia, Trailing stop feature by Thanasis.
I have added EMA startup and combined all in a simple bot. Try it, if you want.

###

a    =    askParam 'Stop loss %', 5
b    =    askParam 'Take profit %', 0.25
x    =    2     # Price correction band
y    =    25    # Price increase percentage reduction
z    =    0.25   # Price increase rate


ema = (data, lag, period) ->
        results = talib.EMA
            inReal   : data
            startIdx : 0
            endIdx   : data.length - lag
            optInTimePeriod : period
class Init

  @init_context: (context) ->

    context.k   =   1
    context.m   =   0
    context.have_fiat  = false
    context.have_coins = true

class functions

  @percent: (x,y) ->

    ((x-y)/y) * 100

class SUPERTREND

    constructor: (@Length,@mult) ->

        @count = 0
        @longband = []
        @shortband = []
        @trend = []

        # INITIALIZE ARRAYS
        for [@longband.length..5]
            @longband.push 0
        for [@shortband.length..5]
            @shortband.push 0
        for [@trend.length..5]
            @trend.push 0

    calculate: (instrument) ->

        close = instrument.close[instrument.close.length-1]
        closeprev = instrument.close[instrument.close.length-2]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # REMOVE OLD DATA
        @longband.pop()
        @shortband.pop()
        @trend.pop()

        # ADD NEW DATA
        @longband.unshift(0)
        @shortband.unshift(0)
        @trend.unshift(0)

        # CALCULATE
        hl2 = (high + low) / 2

        avgTR = talib.ATR
            high: instrument.high
            low: instrument.low
            close: instrument.close
            startIdx: 0
            endIdx: instrument.high.length-1
            optInTimePeriod: @Length
        avgTR = avgTR[avgTR.length-1]

        newshortband = hl2 + avgTR * @mult
        newlongband = hl2 - avgTR * @mult

        if closeprev > @longband[1]
            if newlongband > @longband[1]
                @longband[0] = newlongband
            else
                @longband[0] = @longband[1]
        else
            @longband[0] = newlongband

        if closeprev < @shortband[1]
            if newshortband < @shortband[1]
                @shortband[0] = newshortband
            else
                @shortband[0] = @shortband[1]
        else
            @shortband[0] = newshortband


        if close > @shortband[1]
            @trend[0] = 1
        else if close < @longband[1]
            @trend[0] = -1
        else
            @trend[0] = @trend[1]


        if @trend[0] == 1    # buy trend
            supt = @longband[0]


        else                # sell trend
            supt = @shortband[0]






        # TEMP DEBUG




        # RETURN DATA
        result =
            trend: @trend[0]

        return result

class CORAL
    constructor: () ->

        @count = 0
        @i1 = []
        @i2 = []
        @i3 = []
        @i4 = []
        @i5 = []
        @i6 = []
        @bfr = []


        # INITIALIZE ARRAYS
        for [@i1.length..5]
            @i1.push 0
        for [@i2.length..5]
            @i2.push 0
        for [@i3.length..5]
            @i3.push 0
        for [@i4.length..5]
            @i4.push 0
        for [@i5.length..5]
            @i5.push 0
        for [@i6.length..5]
            @i6.push 0
        for [@bfr.length..5]
            @bfr.push 0

    calculate: (instrument) ->

        @count++

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        sm = 21
        cd = 0.4

        # REMOVE OLD DATA
        @i1.pop()
        @i2.pop()
        @i3.pop()
        @i4.pop()
        @i5.pop()
        @i6.pop()
        @bfr.pop()

        # ADD NEW DATA
        @i1.unshift(0)
        @i2.unshift(0)
        @i3.unshift(0)
        @i4.unshift(0)
        @i5.unshift(0)
        @i6.unshift(0)
        @bfr.unshift(0)

        # CALCULATE

        di = (sm - 1.0) / 2.0 + 1.0
        c1 = 2 / (di + 1.0)
        c2 = 1 - c1
        c3 = 3.0 * (cd * cd + cd * cd * cd)
        c4 = -3.0 * (2.0 * cd * cd + cd + cd * cd * cd)
        c5 = 3.0 * cd + 1.0 + cd * cd * cd + 3.0 * cd * cd

        if @count == 1
            @i1[0] = @i2[0] = @i3[0] = @i4[0] = @i5[0] = @i6[0] = close
        else
            @i1[0] = c1*close + c2*(@i1[1])
            @i2[0] = c1*@i1[0] + c2*(@i2[1])
            @i3[0] = c1*@i2[0] + c2*(@i3[1])
            @i4[0] = c1*@i3[0] + c2*(@i4[1])
            @i5[0] = c1*@i4[0] + c2*(@i5[1])
            @i6[0] = c1*@i5[0] + c2*(@i6[1])

        @bfr[0] = -cd*cd*cd*@i6[0] + c3*(@i5[0]) + c4*(@i4[0]) + c5*(@i3[0])



        if @bfr[0] > @bfr[1]
            plotMark
                "trendup": 0

        else
            plotMark
                "trenddown": 0





        # TEMP DEBUG
        plot

        setPlotOptions
            trendup:
                color: 'green'
                secondary: true
            trenddown:
                color: 'red'
                secondary: true



        # RETURN DATA
        result =
            close: close
            trend: @bfr[0] - @bfr[1]
            cena: @bfr[0]
        return result

class FUNCTIONS

    @ROUND_DOWN: (value, places) ->
        offset = Math.pow(10, places)
        return Math.floor(value*offset)/offset

init: (context)->

    context.supertrend = new SUPERTREND(15,3)
    context.coral = new CORAL()
    Init.init_context(context)

    # FOR FINALISE STATS
    context.balance_curr = 0
    context.balance_btc = 0
    context.price = 0



serialize: (context)->


handle: (context, data, storage)->

    instrument      =   data.instruments[0]
    high            =   instrument.high[instrument.high.length - 1]
    low             =   instrument.low[instrument.low.length - 1]


    storage.max_high ?=  high
    storage.min_low  ?=  low
    storage.trendbuy  ?= false
    storage.trendsell ?= false
    storage.lastBuyPrice ?= 0
    storage.Crazlika ?= 0
    storage.TICK ?= 0

    # FOR FINALISE STATS
    context.price = instrument.close[instrument.close.length - 1]
    context.priceprev = instrument.close[instrument.close.length - 2]
    context.balance_curr = portfolio.positions[instrument.curr()].amount
    context.balance_btc = portfolio.positions[instrument.asset()].amount

    if storage.TICK == 0
        storage.balance_curr_start = portfolio.positions[instrument.curr()].amount
        storage.balance_btc_start = portfolio.positions[instrument.asset()].amount
        storage.price_start = context.price

    # CALLING INDICATORS
    supertrend = context.supertrend.calculate(instrument)
    Strend = supertrend.trend


    coral = context.coral.calculate(instrument)
    Ctrend = FUNCTIONS.ROUND_DOWN(coral.trend,2)
    cena = coral.cena

    EMA    = _.last(ema(instrument.close, 1, 10))

    if Ctrend > 0   # CORAL BUY and SELL signal
        Ctrend = 1
    else
        Ctrend = -1


    # TRADING

    # ENTRY TRADE
    if storage.trendsell == false and storage.trendbuy == false
        if Strend == 1 and Ctrend == 1 and (storage.Crazlika + Ctrend) == 0 and (EMA-cena) > 0
            buy instrument
            storage.fix_stop_loss  = (1-(a/100))*context.price
            storage.trailing_stop = (1+(b/100))*context.price
            storage.lastBuyPrice = context.price
            storage.trendbuy = true
            storage.trendsell = false
            debug " Entry Buy Trade"



    # EXIT TRADE
    if storage.trendbuy == true and storage.trendsell == false
        if high > (storage.trailing_stop + z)
            x =  x * (1 - (y / 100))
            storage.trailing_stop =  Math.max((low-x), storage.trailing_stop)


        if context.price < storage.trailing_stop and context.price < context.priceprev and context.price > storage.lastBuyPrice
            sell instrument
            storage.trendbuy = false
            storage.trendsell= false
            debug " Exit Sell "

        if context.price < storage.fix_stop_loss
            sell instrument
            storage.trendbuy = false
            storage.trendsell= false
            debug " Stop Loss Sell "



    storage.Crazlika = Ctrend
# PLOTTING / DEBUG
    plot
     SL_Price: storage.fix_stop_loss
     TS_Price : storage.trailing_stop
     EMA: EMA
     CORAL: cena


# STATS CODE


    #starting_btc_equiv  = storage.balance_btc_start + storage.balance_curr_start / storage.price_start
    #current_btc_equiv   = context.balance_btc + context.balance_curr / context.price
    #starting_fiat_equiv = storage.balance_curr_start + storage.balance_btc_start * storage.price_start
    #current_fiat_equiv  = context.balance_curr + context.balance_btc * context.price
    #efficiency          = Math.round((current_btc_equiv / starting_btc_equiv) * 1000) / 1000
    #efficiency_percent  = Math.round((((current_btc_equiv / starting_btc_equiv) - 1) * 100) * 10) / 10
    #market_efficiency   = Math.round((((context.price / storage.price_start) - 1) * 100) * 10) / 10
    #bot_efficiency      = Math.round((((current_fiat_equiv / starting_fiat_equiv) - 1) * 100) * 10) / 10

    #storage.TICK++

    #warn "### Day " + storage.TICK + " Log"
    #debug "Current Fiat: " + Math.round(context.balance_curr*100)/100 + " | Current BTC: " +  Math.round(context.balance_btc*100)/100
    #debug "Starting Fiat: " + Math.round(storage.balance_curr_start*100)/100 + " | Starting BTC: " +  Math.round(storage.balance_btc_start*100)/100
    #debug "Current Portfolio Worth: " + Math.round(((context.balance_btc * context.price) + context.balance_curr)*100)/100
    #debug "Starting Portfolio Worth: " + Math.round(((storage.balance_btc_start * storage.price_start) + storage.balance_curr_start)*100)/100
    #debug "Efficiency of Buy and Hold: " + market_efficiency + "%"
    #debug "Efficiency of Bot: " + bot_efficiency + "%"
    #debug "Efficiency Vs Buy and Hold: " + efficiency + " which equals " + efficiency_percent + "%"
    #warn "###"







