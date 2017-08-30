###
Template
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class CLASSNAME
    constructor: () ->

        @count = 0
        @output = []

        # INITIALIZE ARRAYS
        for [@output.length..5]
            @output.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # REMOVE OLD DATA
        @output.pop()

        # ADD NEW DATA
        @output.unshift(0)

        # CALCULATE
        @output[0] = close
        
        
        
        # TEMP DEBUG
        plot
            output: @output[0]

        

        # RETURN DATA
        result =
            output: @output[0]

        return result 
      

init: (context)->
    
    context.classname = new CLASSNAME()

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
    classname = context.classname.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc