###
Laguerre
by aspiramedia (converted from this: http://www.mesasoftware.com/Papers/TIME%20WARP.pdf - Fig 7)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74

https://cryptotrader.org/backtests/mzZ3Jy8QaraTWjiB4
###

class LAGUERRE
    constructor: (@g) ->

        @count = 0
        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []
        @Price = []
        @laguerre = []

        # INITIALIZE ARRAYS
        for [@L0.length..5]
            @L0.push 0
        for [@L1.length..5]
            @L1.push 0
        for [@L2.length..5]
            @L2.push 0
        for [@L3.length..5]
            @L3.push 0
        for [@Price.length..5]
            @Price.push 0
        for [@laguerre.length..5]
            @laguerre.push 0
        
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
        @Price.pop()
        @laguerre.pop()

        # ADD NEW DATA
        @L0.unshift(0)
        @L1.unshift(0)
        @L2.unshift(0)
        @L3.unshift(0)
        @Price.unshift(0)
        @laguerre.unshift(0)

        @Price[0] = (high+low)/2

        # CALCULATE
        @L0[0] = ((1 - g) * @Price[0]) + (g * @L0[1])
        @L1[0] = (-g * @L0[0]) + @L0[1] + (g * @L1[1])
        @L2[0] = (-g * @L1[0]) + @L1[1] + (g * @L2[1])
        @L3[0] = (-g * @L2[0]) + @L2[1] + (g * @L3[1])

        @laguerre[0] = (@L0[0] + (2 * @L1[0]) + (2 * @L2[0]) + @L3[0]) / 6          # Laguerre filter
        
        # TEMP DEBUG
        

        # RETURN DATA
        return @laguerre[0]
      

init: (context)->
    
    context.laguerre1 = new LAGUERRE(0.3)
    context.laguerre2 = new LAGUERRE(0.4)
    context.laguerre3 = new LAGUERRE(0.5)
    context.laguerre4 = new LAGUERRE(0.6)
    context.laguerre5 = new LAGUERRE(0.7)

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
    laguerre1 = context.laguerre1.calculate(instrument)
    laguerre2 = context.laguerre2.calculate(instrument)
    laguerre3 = context.laguerre3.calculate(instrument)
    laguerre4 = context.laguerre4.calculate(instrument)
    laguerre5 = context.laguerre5.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot
        laguerre1: laguerre1
        laguerre2: laguerre2
        laguerre3: laguerre3
        laguerre4: laguerre4
        laguerre5: laguerre5


    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc