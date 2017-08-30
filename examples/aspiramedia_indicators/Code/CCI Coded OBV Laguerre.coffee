###
CCI Coded OBV with a Laguerre
by aspiramedia (converted from this by LazyBear and "Laguerred" by aspiramedia: https://www.tradingview.com/v/D8ld7sgR/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74

https://cryptotrader.org/backtests/MBYwE9ArBrBSnZs78
###

class CCIOBV
    constructor: (@g) ->

        @count  = 0
        @o      = []
        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []
        @laguerre = []

        # INITIALIZE ARRAYS
        for [@o.length..50]
            @o.push 0
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
        closeprev   = instrument.close[instrument.close.length-2]
        high        = instrument.high[instrument.high.length-1]
        low         = instrument.low[instrument.low.length-1]
        volume      = instrument.volumes[instrument.volumes.length-1]
        length      = 20
        threshold   = 0
        g = @g
        CU = 0
        CD = 0

        # REMOVE OLD DATA
        @L0.pop()
        @L1.pop()
        @L2.pop()
        @L3.pop()
        @laguerre.pop()

        # ADD NEW DATA
        @L0.unshift(0)
        @L1.unshift(0)
        @L2.unshift(0)
        @L3.unshift(0)
        @laguerre.unshift(0)

         # REMOVE OLD DATA
        @o.pop()

        # ADD NEW DATA
        @o.unshift(0)

        # CALCULATE
        if (close - closeprev > 0)
            o = volume
        else if (close - closeprev < 0)
            o = -volume
        else
            o = 0  

        @o[0] = @o[1] + o

        c = talib.CCI
            high: instrument.high
            low: instrument.low
            close: instrument.close
            startIdx: 0
            endIdx: instrument.high.length-1
            optInTimePeriod: length
        c = c[c.length-1]

        if c > threshold
            #buy instrument
            plotMark
                "buy": @o[0]
            up = 1
        else
            #sell instrument
            plotMark
                "sell": @o[0]
            up = 0

        @L0[0] = ((1 - g) * @o[0]) + (g * @L0[1])
        @L1[0] = (-g * @L0[0]) + @L0[1] + (g * @L1[1])
        @L2[0] = (-g * @L1[0]) + @L1[1] + (g * @L2[1])
        @L3[0] = (-g * @L2[0]) + @L2[1] + (g * @L3[1])

        @laguerre[0] = (@L0[0] + (2 * @L1[0]) + (2 * @L2[0]) + @L3[0]) / 6  # Laguerre filter
        
        if @laguerre[0] > @laguerre[1] and up is 1
            buy instrument
        if @laguerre[0] < @laguerre[1] and up is 0
            sell instrument


        plot
            laguerre: @laguerre[0] 
        setPlotOptions
            buy: 
                color: 'green'
                secondary: true
            sell:
                color: 'red'
                secondary: true
            laguerre: 
                color: 'blue'
                secondary: true

        # TEMP DEBUG
        

        

        # RETURN DATA
        result =
            close: close

        return result 
      

init: (context)->
    
    context.cciobv = new CCIOBV(0.5)

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
    cciobv = context.cciobv.calculate(instrument)

    # TRADING
    
    
    # PLOTTING / DEBUG
    

    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc