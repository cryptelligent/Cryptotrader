###
Supertrend
by aspiramedia (converted from this by BlindFreddy and originally by Olivier Seban: https://www.tradingview.com/v/IcKpRQ6s/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

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


        if @trend[0] == 1
            supt = @longband[0]
            plotMark
                "trendon": supt
        else
            supt = @shortband[0]
            plotMark
                "trendoff": supt

       
        
        
        # TEMP DEBUG

        
        

        # RETURN DATA
        result =
            trend: @trend[0]

        return result 
      

init: (context)->
    
    context.supertrend = new SUPERTREND(10,3)

    # FOR FINALISE STATS
    context.balance_curr = 0
    context.balance_btc = 0
    context.price = 0


handle: (context, data)->

    instrument = data.instruments[0]
    price = instrument.close[instrument.close.length - 1]

    # FOR FINALISE STATS
    context.price = instrument.close[instrument.close.length - 1]
    context.balance_curr = portfolio.positions[instrument.curr()].amount
    context.balance_btc = portfolio.positions[instrument.asset()].amount

    # CALLING INDICATORS
    supertrend = context.supertrend.calculate(instrument)
    trend = supertrend.trend
    
    # TRADING
    if trend == 1
        buy instrument
    else
        sell instrument

    
    # PLOTTING / DEBUG
    plot
        trend: trend
    setPlotOptions
        trend:
            secondary: true
            lineWidth: 3
            color: 'blue'
        trendon: 
            color: 'green'
        trendoff:
            color: 'red'



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc