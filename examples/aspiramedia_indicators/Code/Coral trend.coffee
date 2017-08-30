###
CORAL TREND INDICATOR
by aspiramedia (Originally by LazyBear: https://www.tradingview.com/v/qyUwc2Al/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class CORAL
    constructor: (@cd) ->

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
        cd = @cd

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
        

        

        # RETURN DATA
        result =
            bfr: @bfr

        return result 
      

init: (context)->
    
    context.coral = new CORAL(0.4)
    context.coral2 = new CORAL(0.5)

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
    coral = context.coral.calculate(instrument)
    bfr = coral.bfr

    coral2 = context.coral2.calculate(instrument)
    bfr2 = coral2.bfr
    
    # TRADING
    if bfr2[0] > bfr[0]
        buy instrument
    if bfr2[0] < bfr[0]
        sell instrument
    
    
    # PLOTTING / DEBUG
    plot
        bfr: bfr[0]
    setPlotOptions
        trendup: 
            color: 'green'
            secondary: true
        trenddown:
            color: 'red'
            secondary: true



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc