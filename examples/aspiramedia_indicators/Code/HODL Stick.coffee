###
HODL Stick
by aspiramedia (Based on https://www.tradingview.com/script/upRcagU6-Hodl-Stick-v-4/ by hodl)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class HODLSTICK
    constructor: (@g) ->

        @count = 0
        @output = []
        @candleHeight = []
        @cum = []

        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []
        @laguerre = []

        # INITIALIZE ARRAYS
        for [@output.length..5]
            @output.push 0
        for [@candleHeight.length..5]
            @candleHeight.push 0
        for [@cum.length..5]
            @cum.push 0
        
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

        o = instrument.open[instrument.open.length-1]
        c = instrument.close[instrument.close.length-1]
        h = instrument.high[instrument.high.length-1]
        l = instrument.low[instrument.low.length-1]
        v = instrument.close[instrument.volumes.length-1]
        g = @g


        # REMOVE OLD DATA
        @output.pop()
        @candleHeight.pop()
        @cum.pop()

        @L0.pop()
        @L1.pop()
        @L2.pop()
        @L3.pop()
        @laguerre.pop()

        # ADD NEW DATA
        @output.unshift(0)
        @candleHeight.unshift(0)
        @cum.unshift(0)

        @L0.unshift(0)
        @L1.unshift(0)
        @L2.unshift(0)
        @L3.unshift(0)
        @laguerre.unshift(0)

        # CALCULATE
        @candleHeight[0] = h - l
        if @candleHeight[0] == 0
            @candleHeight[0] = 0.001
        bodyHeight = Math.abs(o - c)
        if o < c
            topBody = c
        else
            topBody = o

        if o < c
            bottomBody = o
        else
            bottomBody = c

        topWick = h - topBody
        bottomWick = bottomBody - l

        previousStrenght = @candleHeight[0] / @candleHeight[1]
        wickStrenght = ((topWick - bottomWick) / @candleHeight[0])
        bodyStrenght = ((o-c) / @candleHeight[0])

        @output[0] = ((wickStrenght + bodyStrenght) / 2) * -1 

        @cum[0] =  @cum[1] + @output[0]   

        @L0[0] = ((1 - g) * @cum[0]) + (g * @L0[1])
        @L1[0] = (-g * @L0[0]) + @L0[1] + (g * @L1[1])
        @L2[0] = (-g * @L1[0]) + @L1[1] + (g * @L2[1])
        @L3[0] = (-g * @L2[0]) + @L2[1] + (g * @L3[1])

        @laguerre[0] = (@L0[0] + (2 * @L1[0]) + (2 * @L2[0]) + @L3[0]) / 6          
        
        
        # TEMP DEBUG
        plot
            cum: @cum[0]
            smooth: @laguerre[0]
        setPlotOptions
            cum:
                secondary: true
            smooth:
                secondary: true

        

        # RETURN DATA
        result =
            cum: @cum[0]

        return result 
      

init: (context)->
    
    context.hodlstick = new HODLSTICK(0.1)

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
    hodlstick = context.hodlstick.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc