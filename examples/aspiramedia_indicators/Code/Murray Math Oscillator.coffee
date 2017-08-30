###
Murray Math Oscillator
by aspiramedia (originally by ucsgears at https://www.tradingview.com/v/VQPnbiQd/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class MURRAY
    constructor: (@length, @mult, @g) ->

        @count = 0
        @output = []
        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []
        @laguerre = []

        # INITIALIZE ARRAYS
        for [@output.length..20]
            @output.push 0
        for [@L0.length..5]
            @L0.push 0
        for [@L1.length..5]
            @L1.push 0
        for [@L2.length..5]
            @L2.push 0
        for [@L3.length..5]
            @L3.push 0
        for [@laguerre.length..20]
            @laguerre.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # REMOVE OLD DATA
        @output.pop()
        @L0.pop()
        @L1.pop()
        @L2.pop()
        @L3.pop()
        @laguerre.pop()

        # ADD NEW DATA
        @output.unshift(0)
        @L0.unshift(0)
        @L1.unshift(0)
        @L2.unshift(0)
        @L3.unshift(0)
        @laguerre.unshift(0)

        # CALCULATE

        hi = (instrument.high[-@length..].reduce (a,b) -> Math.max a, b)
        lo = (instrument.low[-@length..].reduce (a,b) -> Math.min a, b)
        range = hi - lo
        multiplier = (range) * @mult
        midline = lo + (multiplier * 4)

        @output[0] = (close - midline)/(range/2)

        @L0[0] = ((1 - @g) * @output[0]) + (@g * @L0[1])
        @L1[0] = (-@g * @L0[0]) + @L0[1] + (@g * @L1[1])
        @L2[0] = (-@g * @L1[0]) + @L1[1] + (@g * @L2[1])
        @L3[0] = (-@g * @L2[0]) + @L2[1] + (@g * @L3[1])

        @laguerre[0] = (@L0[0] + (2 * @L1[0]) + (2 * @L2[0]) + @L3[0]) / 6
        
        # TEMP DEBUG
        plot
            output: @output[0]
            laguerre: @laguerre[0]
        setPlotOptions
            output:
                secondary: true
            laguerre:
                secondary: true

        

        # RETURN DATA
        result =
            output: @output
            laguerre: @laguerre

        return result 
      

init: (context)->
    
    context.murray = new MURRAY(100, 0.125, 0.25)

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
    murray = context.murray.calculate(instrument)
    laguerre = murray.laguerre
    output = murray.output

    mult = 0.08
    
    # TRADING
    if ((laguerre[1] < 0 and laguerre[1] > -mult*8) and (laguerre[0] > 0 and laguerre[0] < mult*8))
        buy instrument
    if ((laguerre[1] > 0 and laguerre[1] < mult*8) and (laguerre[0] < 0 and laguerre[0] > -mult*8))
        sell instrument

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc