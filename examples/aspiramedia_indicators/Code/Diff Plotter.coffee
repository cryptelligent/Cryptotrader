###
Slope Bot
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class DIFF
    constructor: (@lag,@g) ->

        @count = 0
        @cansell = 0
        @canbuy = 0
        @diff = []
        @diffavg = []
        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []
        @laguerre = []

        # INITIALIZE ARRAYS
        for [@diff.length..@period]
            @diff.push 0
        for [@diffavg.length..5]
            @diffavg.push 0
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

        price = (instrument.close[instrument.close.length-1] + instrument.high[instrument.high.length-1] + instrument.low[instrument.low.length-1]) /3
        priceprev = (instrument.close[instrument.close.length-@lag] + instrument.high[instrument.high.length-@lag] + instrument.low[instrument.low.length-@lag]) /3


        # REMOVE OLD DATA
        @diff.pop()
        @diffavg.pop()
        @L0.pop()
        @L1.pop()
        @L2.pop()
        @L3.pop()
        @laguerre.pop()

        # ADD NEW DATA
        @diff.unshift(0)
        @diffavg.unshift(0)
        @L0.unshift(0)
        @L1.unshift(0)
        @L2.unshift(0)
        @L3.unshift(0)
        @laguerre.unshift(0)

        # CALCULATE
        @diff[0] = (price / priceprev) - 1
        
        @L0[0] = ((1 - @g) * @diff[0]) + (@g * @L0[1])
        @L1[0] = (-@g * @L0[0]) + @L0[1] + (@g * @L1[1])
        @L2[0] = (-@g * @L1[0]) + @L1[1] + (@g * @L2[1])
        @L3[0] = (-@g * @L2[0]) + @L2[1] + (@g * @L3[1])

        @diffavg[0] = (@L0[0] + (2 * @L1[0]) + (2 * @L2[0]) + @L3[0]) / 6 


        # TEMP DEBUG
        plot
            diff: @diff[0]
            diffavg: @diffavg[0]
            buythresh: -0.05
            sellthresh: 0.05
        setPlotOptions
            diff:
                secondary: true
                color: 'rgba(0,0,0,0.2)'
            diffavg:
                secondary: true
            buythresh:
                secondary: true
            sellthresh:
                secondary: true

        # TRADING
        if @diffavg[0] < -0.05
            @canbuy = 1

        if @diffavg[0] > 0.05
            @cansell = 1

        if @diffavg[0] > 0 && @canbuy == 1
            buy instrument
            @canbuy = 0
        if @diffavg[0] < 0 && @cansell == 1
            sell instrument
            @cansell = 0

        

        # RETURN DATA
        result =
            diff: @diff

        return result 
      

init: (context)->
    
    context.diff = new DIFF(20,0.7)

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
    diff = context.diff.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc