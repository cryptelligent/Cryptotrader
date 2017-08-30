###
Information Capacity
by aspiramedia (Based on an idea by Thanasis)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74

F = log(100/RSI)
###



class INFCAP
    constructor: (@period, @g) ->

        @count  = 0
        @F  = []
        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []
        @laguerre = []

        # INITIALIZE ARRAYS
        for [@F.length..50]
            @F.push 0
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

        close       = instrument.close[instrument.close.length-1]
        high        = instrument.high[instrument.high.length-1]
        low         = instrument.low[instrument.low.length-1]
        g = @g

        # REMOVE OLD DATA
        @F.pop()
        @L0.pop()
        @L1.pop()
        @L2.pop()
        @L3.pop()
        @laguerre.pop()

        # ADD NEW DATA
        @F.unshift(0)
        @L0.unshift(0)
        @L1.unshift(0)
        @L2.unshift(0)
        @L3.unshift(0)
        @laguerre.unshift(0)

        # CALCULATE

        rsi = talib.RSI
            inReal: instrument.close
            startIdx: 0
            endIdx: instrument.close.length-1
            optInTimePeriod: @period
        rsi = rsi[rsi.length-1]

        if rsi != 0      
            @F[0] = Math.log(100/rsi)
        else
            @F[0] = @F[1]

       
        # Laguerre Filter for averaging
        @L0[0] = ((1 - g) * @F[0]) + (g * @L0[1])
        @L1[0] = (-g * @L0[0]) + @L0[1] + (g * @L1[1])
        @L2[0] = (-g * @L1[0]) + @L1[1] + (g * @L2[1])
        @L3[0] = (-g * @L2[0]) + @L2[1] + (g * @L3[1])

        @laguerre[0] = (@L0[0] + (2 * @L1[0]) + (2 * @L2[0]) + @L3[0]) / 6      


        # TEMP DEBUG
        

        # RETURN DATA
        result =
            F: @F[0]
            laguerre: @laguerre[0]

        return result 
      

init: (context)->
    
    context.infcap = new INFCAP(20, 0.5)   # RSI Period, Gamma (laguerre filter strength)

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
    infcap = context.infcap.calculate(instrument)
    F = infcap.F
    laguerre = infcap.laguerre

    # TRADING
    
    
    # PLOTTING / DEBUG
    plot
        F: F
        laguerre: laguerre
    setPlotOptions
        F: 
            secondary: true
        laguerre: 
            secondary: true
    

    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc