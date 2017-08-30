###
Laguerre RSI Indicator
by aspiramedia (converted from this: http://www.mesasoftware.com/Papers/TIME%20WARP.pdf)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class RSI
    constructor: (@g) ->
        @count = 0
        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []

        # INITIALIZE ARRAYS
        for [@L0.length..5]
            @L0.push 0
        for [@L1.length..5]
            @L1.push 0
        for [@L2.length..5]
            @L2.push 0
        for [@L3.length..5]
            @L3.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        g = @g
        CU = 0
        CD = 0

        # REMOVE OLD DATA
        @L0.pop()
        @L1.pop()
        @L2.pop()
        @L3.pop()

        # ADD NEW DATA
        @L0.unshift(0)
        @L1.unshift(0)
        @L2.unshift(0)
        @L3.unshift(0)

        # CALCULATE
        @L0[0] = ((1 - g) * close) + (g * @L0[1])
        @L1[0] = (-g * @L0[0]) + @L0[1] + (g * @L1[1])
        @L2[0] = (-g * @L1[0]) + @L1[1] + (g * @L2[1])
        @L3[0] = (-g * @L2[0]) + @L2[1] + (g * @L3[1])

        if @L0[0] >= @L1[0] then CU = @L0[0] - @L1[0] else CD = @L1[0] - @L0[0]
        if @L1[0] >= @L2[0] then CU = CU + @L1[0] - @L2[0] else CD = CD + @L2[0] - @L1[0]
        if @L2[0] >= @L3[0] then CU = CU + @L2[0] - @L3[0] else CD = CD + @L3[0] - @L2[0]

        if CU + CD != 0 then rsi = CU / (CU + CD)

        
        # TEMP DEBUG
       

        # RETURN DATA
        result =
            rsi: rsi

        return result 
      

init: (context)->
    
    context.rsi = new RSI(0.5) # Value of gamma

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
    rsi = context.rsi.calculate(instrument)
    rsi = rsi.rsi
   

    # TRADING

    
    # PLOTTING / DEBUG
    plot
        rsi: rsi
    setPlotOptions
        rsi:
            secondary: true


    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc