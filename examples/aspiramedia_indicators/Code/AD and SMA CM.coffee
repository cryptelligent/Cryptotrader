###
Williams AD + SMA of Williams AD
by aspiramedia (Originally by Chris Moody: https://www.tradingview.com/v/budDCi5L/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class WILLIAMS
    constructor: (@g) ->

        @count = 0
        @wad = []
        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []
        @laguerre = []

        # INITIALIZE ARRAYS
        for [@wad.length..20]
            @wad.push 0
        for [@L0.length..5]
            @L0.push 0
        for [@L1.length..5]
            @L1.push 0
        for [@L2.length..5]
            @L2.push 0
        for [@L3.length..5]
            @L3.push 0
        for [@laguerre.length..5]
            @laguerre.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        closeprev = instrument.close[instrument.close.length-2]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        g = @g

        # REMOVE OLD DATA
        @wad.pop()
        @L0.pop()
        @L1.pop()
        @L2.pop()
        @L3.pop()
        @laguerre.pop()

        # ADD NEW DATA
        @wad.unshift(0)
        @L0.unshift(0)
        @L1.unshift(0)
        @L2.unshift(0)
        @L3.unshift(0)
        @laguerre.unshift(0)

        # CALCULATE
        if closeprev <= low
            trl = closeprev
        else
            trl = low

        if closeprev >= high
            trh = closeprev
        else
            trh = high


        if close > closeprev
            ad = close - trl
        else if close < closeprev
            ad = close - trh
        else
            ad = 0

        @wad[0] = @wad[1] + ad

        #### Laguerre
        @L0[0] = ((1 - g) * @wad[0]) + (g * @L0[1])
        @L1[0] = (-g * @L0[0]) + @L0[1] + (g * @L1[1])
        @L2[0] = (-g * @L1[0]) + @L1[1] + (g * @L2[1])
        @L3[0] = (-g * @L2[0]) + @L2[1] + (g * @L3[1])

        @laguerre[0] = (@L0[0] + (2 * @L1[0]) + (2 * @L2[0]) + @L3[0]) / 6
      
        
        # TEMP DEBUG
        

        

        # RETURN DATA
        result =
            wad: @wad
            laguerre: @laguerre

        return result 
      

init: (context)->
    
    context.williams = new WILLIAMS(0.5)

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
    williams = context.williams.calculate(instrument)
    laguerre = williams.laguerre
    wad = williams.wad
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot
        wad: wad[0]
        laguerre: laguerre[0]
    setPlotOptions
        wad:
            secondary: true
            color: 'rgba(0,0,0,0.2)'
        laguerre:
            secondary: true
            color: 'rgba(255,0,0,1)'



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc