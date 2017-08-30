###
Ehlers Simple Cycle
by aspiramedia (Oringinally sourced from Lazybear https://www.tradingview.com/script/xQ4mP4kc-Ehlers-Simple-Cycle-Indicator-LazyBear/ via Ehlers: http://www.mesasoftware.com/seminars/AfTAMay2003.pdf
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class CYCLE
    constructor: () ->

        @count = 0
        @src = []
        @Smooth = []
        @cycle = []

        # INITIALIZE ARRAYS
        for [@src.length..5]
            @src.push 0
        for [@Smooth.length..5]
            @Smooth.push 0
        for [@cycle.length..5]
            @cycle.push 0
        
    calculate: (instrument) ->        

        close   = instrument.close[instrument.close.length-1]
        high    = instrument.high[instrument.high.length-1]
        low     = instrument.low[instrument.low.length-1]
        alpha   = 0.07

        @count++

        # REMOVE OLD DATA
        @src.pop()
        @Smooth.pop()
        @cycle.pop()

        # ADD NEW DATA
        @src.unshift(0)
        @Smooth.unshift(0)
        @cycle.unshift(0)

        # CALCULATE
        if @count == 1
            @src[0] = @src[1] = @src[2] = @src[3] = @src[4] = close
        else
            @src[0] = (high + low) / 2

        @Smooth[0] = (@src[0] + 2 * @src[1] + 2 * @src[2] + @src[3]) / 6
        
        if @count < 7
            @cycle[0] = (@src[0] - 2 * @src[1] + @src[2]) / 4.0
        else
            @cycle[0] = (1 - 0.5 * alpha) * (1 - 0.5 * alpha) * (@Smooth[0] - 2 * @Smooth[1] + @Smooth[2])+ 2 * (1 - alpha) * @cycle[1] - (1 - alpha) * (1 - alpha) * @cycle[2]
        
        # TEMP DEBUG


        

        

        # RETURN DATA
        result =
            cycle: @cycle

        return result 
      

init: (context)->
    
    context.cycle = new CYCLE()

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
    cycle = context.cycle.calculate(instrument)
    osc = cycle.cycle
    
    # TRADING
    

    
    # PLOTTING / DEBUG
    plot
        cycleosc: osc[0]
    setPlotOptions
            cycleosc:
              secondary: true



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc