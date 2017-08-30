###
EMA Diff Smoothed
by aspiramedia (Based on this by salojc2006: https://www.tradingview.com/v/xHAh5gpt/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class EMADIFF
    constructor: (@g, @period) ->

        @count = 0
        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []
        @diff = []
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
        for [@diff.length..5]
            @diff.push 0
        for [@laguerre.length..5]
            @laguerre.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        g = @g



        # REMOVE OLD DATA
        @L0.pop()
        @L1.pop()
        @L2.pop()
        @L3.pop()
        @diff.pop()
        @laguerre.pop()

        # ADD NEW DATA
        @L0.unshift(0)
        @L1.unshift(0)
        @L2.unshift(0)
        @L3.unshift(0)
        @diff.unshift(0)
        @laguerre.unshift(0)

        # CALCULATE
        @diff[0] = (close / instrument.ema(@period)) - 1

        
        @L0[0] = ((1 - g) * @diff[0]) + (g * @L0[1])
        @L1[0] = (-g * @L0[0]) + @L0[1] + (g * @L1[1])
        @L2[0] = (-g * @L1[0]) + @L1[1] + (g * @L2[1])
        @L3[0] = (-g * @L2[0]) + @L2[1] + (g * @L3[1])

        @laguerre[0] = (@L0[0] + (2 * @L1[0]) + (2 * @L2[0]) + @L3[0]) / 6          # Laguerre filter
        
        # TEMP DEBUG
        

        # RETURN DATA
        result =
            diff: @diff
            laguerre: @laguerre

        return result
      

init: (context)->

    context.emadiff = new EMADIFF(0.5, 20)      # Smoothing , EMA Period

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
    emadiff = context.emadiff.calculate(instrument)
    diff = emadiff.diff
    laguerre = emadiff.laguerre

    
    # TRADING
    if laguerre[0] > laguerre[1]
        buy instrument
    if laguerre[0] < laguerre[1]
        sell instrument

    
    # PLOTTING / DEBUG
    plot
        diff: diff[0]
        laguerre: laguerre[0]
    setPlotOptions
        diff:
            secondary: true
            color: 'rgba(0,0,0,0.1)'
        laguerre:
            secondary: true
            color: 'rgba(255,0,0,1)'


    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc