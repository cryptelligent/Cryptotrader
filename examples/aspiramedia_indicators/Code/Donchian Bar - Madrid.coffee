###
Donchian Bar
by aspiramedia (Originally by Madrid at https://www.tradingview.com/script/TdlGUxob-Madrid-Donchian-Bar/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class DONCHIAN
    constructor: () ->

        @count = 0
        @ceilFloor = []

        # INITIALIZE ARRAYS
        for [@ceilFloor.length..5]
            @ceilFloor.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        len = 13
        src = close

        # REMOVE OLD DATA
        @ceilFloor.pop()

        # ADD NEW DATA
        @ceilFloor.unshift(0)

        # CALCULATE
        highestBar = (instrument.high[-13..].reduce (a,b) -> Math.max a, b)
        lowestBar = (instrument.low[-13..].reduce (a,b) -> Math.min a, b)
        midBar = (highestBar + lowestBar) / 2

        mdcb = (src - midBar) / (highestBar - lowestBar)

        if mdcb < -0.25
            @ceilFloor[0] = -0.5
        else if mdcb < 0
            @ceilFloor[0] = -0.25
        else if mdcb < 0.25
            @ceilFloor[0] = 0.25
        else
            @ceilFloor[0] = 0.5


        if @ceilFloor[0] == -0.5
            plotMark
                "extremebearish": 0
        if @ceilFloor[0] == -0.25
            plotMark
                "bearish": 0
        if @ceilFloor[0] == 0.25
            plotMark
                "bullish": 0
        if @ceilFloor[0] == 0.5
            plotMark
                "extremebullish": 0


        if @ceilFloor[0] >= 0.25
            buy instrument
        if @ceilFloor[0] <= -0.25
            sell instrument




        
        
        
        # TEMP DEBUG
        setPlotOptions
            extremebearish:
                secondary: true
                color: 'red'
            bearish:
                secondary: true
                color: 'maroon'
            bullish:
                secondary: true
                color: 'green'
            extremebullish:
                secondary: true
                color: 'lime'

        

        # RETURN DATA
        result =
            ceilFloor: @ceilFloor[0]

        return result 
      

init: (context)->
    
    context.donchian = new DONCHIAN()

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
    donchian = context.donchian.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc