###
Channel Bot
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class CHANNEL
    constructor: () ->
        @high = []
        @low = []
        @highmax = []
        @lowmin = []
        @highavg = []
        @lowavg = []
        @count = 0
        
        # INITIALIZE ARRAYS
        for [@high.length..40]
            @high.push 0
        for [@low.length..40]
            @low.push 0
        for [@highmax.length..3]
            @highmax.push 0
        for [@lowmin.length..3]
            @lowmin.push 0
        for [@highavg.length..3]
            @highavg.push 0
        for [@lowavg.length..3]
            @lowavg.push 0
        
    calculate: (instrument) ->

        # INCREASE DATA COUNT
        @count++
        
        # REMOVE OLD DATA
        @high.pop()
        @low.pop()
        @highmax.pop()
        @lowmin.pop()
        @highavg.pop()
        @lowavg.pop()

        # ADD NEW DATA
        @high.unshift(0)
        @low.unshift(0)
        @highmax.unshift(0)
        @lowmin.unshift(0)
        @highavg.unshift(0)
        @lowavg.unshift(0)

        # CALCULATE        
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        avg = (high + low) / 2

                    
        @high[0] = high
        @low[0] = low

        if @count > 80
            @highmax[0] = (@high.reduce (a,b) -> Math.max a, b)
            @lowmin[0] = (@low.reduce (a,b) -> Math.min a, b)
            @highavg[0] = (@high.reduce (x, y) -> x + y) / @high.length
            @lowavg[0] = (@low.reduce (x, y) -> x + y) / @low.length
        else
            @highmax[0] = @lowmin[0] = @highavg[0] = @lowavg[0] = avg


        # RETURN DATA
        result =
            max: @highmax
            min: @lowmin
            maxavg: @highavg
            minavg: @lowavg

        return result 
      
init: (context)->
    
    context.channel = new CHANNEL()

    # For finalise stats
    context.balance_curr = 0
    context.balance_btc = 0
    context.price = 0

handle: (context, data, storage)->

    instrument = data.instruments[0]
    price = instrument.close[instrument.close.length - 1]
    high = instrument.high[instrument.high.length-1]
    low = instrument.low[instrument.low.length-1]

    # For finalise stats
    context.price = instrument.close[instrument.close.length - 1]
    context.balance_curr = portfolio.positions[instrument.curr()].amount
    context.balance_btc = portfolio.positions[instrument.asset()].amount

    # Indicators
    channel = context.channel.calculate(instrument)
    max = channel.max[0]
    min = channel.min[0]
    maxavg = channel.maxavg[0]
    maxavgprev = channel.maxavg[1]
    minavg = channel.minavg[0]
    minavgprev = channel.minavg[1]
    
    diff = maxavg/minavg - 1

    if diff > 0.03
        buy instrument
    if diff < 0.01
        sell instrument

    plot
        max: max
        min: min
        maxavg: maxavg
        minavg: minavg
        diff: diff
    setPlotOptions
        diff:
          secondary: true

    
        

    
finalize: (contex, data)-> 

    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc