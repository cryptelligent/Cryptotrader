###
Ehlers Instantaneous Trendline
by aspiramedia (Original by Ehler: http://www.mesasoftware.com/seminars/AfTAMay2003.pdf)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class INSTANT
    constructor: () ->

        @count = 0
        @src = []
        @it = []

        # INITIALIZE ARRAYS
        for [@src.length..5]
            @src.push 0
        for [@it.length..5]
            @it.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        a = 0.07


        # REMOVE OLD DATA
        @src.pop()
        @it.pop()

        # ADD NEW DATA
        @src.unshift(0)
        @it.unshift(0)

        # CALCULATE

        @src[0] = (high + low) / 2

        if @count <= 7
            @it[0] = close
        else
            @it[0] = (a - a*a/4)*@src[0] + 0.5*a*a*@src[1] - (a - 0.75*a*a)*@src[2] + 2*(1 - a)*@it[1] - (1 - a)*(1 - a)*@it[2]

        if @count <= 7
            trigger = close
        else
            trigger = (2.0 * @it[0]) - @it[2]

        @count++
        
        
        # TEMP DEBUG
        plot
            it: @it[0]
            trigger: trigger

        

        # RETURN DATA
        result =
            it: @it
            trigger: trigger

        return result 
      

init: (context)->
    
    context.instant = new INSTANT()

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
    instant = context.instant.calculate(instrument)
    it = instant.it
    trigger = instant.trigger
    
    # TRADING
    if it[0] < trigger * 0.998
        buy instrument
    if it[0] > trigger / 0.998
        sell instrument

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc