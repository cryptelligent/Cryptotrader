###
High Low Difference and averaging
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class HIGHLOW
    constructor: () ->
        @highlowdiff_array = []
        @highlowdiffavg_array = []
        @count = 0
        
        # INITIALIZE ARRAYS
        for [@highlowdiff_array.length..3]
            @highlowdiff_array.push 0
        for [@highlowdiffavg_array.length..100]
            @highlowdiffavg_array.push 0
        
    calculate: (instrument) ->

        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # INCREASE DATA COUNT
        @count++
        
        # REMOVE OLD DATA
        @highlowdiff_array.pop()
        @highlowdiffavg_array.pop()

        # ADD NEW DATA
        @highlowdiff_array.unshift(0)
        @highlowdiffavg_array.unshift(0)

        # CALCULATE        
        @highlowdiff_array[0] = high - low
        @highlowdiffavg_array[0] = (@highlowdiff_array.reduce (x, y) -> x + y) / @highlowdiff_array.length

        # RETURN DATA
        result =
            highlowdiff: @highlowdiff_array
            highlowdiffavg: @highlowdiffavg_array

        return result 
      
init: (context)->
    
    context.highlow = new HIGHLOW()

    # For finalise stats
    context.balance_curr = 0
    context.balance_btc = 0
    context.price = 0

handle: (context, data)->

    instrument = data.instruments[0]
    price = instrument.close[instrument.close.length - 1]

    # For finalise stats
    context.price = instrument.close[instrument.close.length - 1]
    context.balance_curr = portfolio.positions[instrument.curr()].amount
    context.balance_btc = portfolio.positions[instrument.asset()].amount

    highlow = context.highlow.calculate(instrument)
    diff = highlow.highlowdiff[0]
    diffavg = highlow.highlowdiffavg[0]

    plot
        diff: diff
        diffavg: diffavg
    setPlotOptions
        diff:
          secondary: true
        diffavg:
          secondary: true
    
finalize: (contex, data)-> 

    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc