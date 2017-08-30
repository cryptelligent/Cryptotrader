###
Log Bot with Avg
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class LOG
    constructor: () ->
        @logprice = []
        @logpriceavg = []
        @count = 0
        
        # INITIALIZE ARRAYS
        for [@logprice.length..20]
            @logprice.push 1.75
        for [@logpriceavg.length..3]
            @logpriceavg.push 0
        
    calculate: (instrument) ->

        # INCREASE DATA COUNT
        @count++
        
        # REMOVE OLD DATA
        @logprice.pop()
        @logpriceavg.pop()

        # ADD NEW DATA
        @logprice.unshift(0)
        @logpriceavg.unshift(0)

        # CALCULATE        
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

                    
        @logprice[0] = Math.log((high + low)/2)

        @logpriceavg[0] = (@logprice.reduce (x, y) -> x + y) / @logprice.length       

        # RETURN DATA
        result =
            logprice: @logprice
            logpriceavg: @logpriceavg

        return result 
      
init: (context)->
    
    context.log = new LOG()

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

    # Indicators
    log = context.log.calculate(instrument)
    logprice = log.logprice[0]
    logpriceavg = log.logpriceavg[0]
    
    plot
        slope: slope
    setPlotOptions
        slope:
          secondary: true

    
finalize: (contex, data)-> 

    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc