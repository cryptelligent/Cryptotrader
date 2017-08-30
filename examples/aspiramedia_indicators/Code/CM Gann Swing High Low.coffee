###
CM GANN SWING HIGH LOW V2
by aspiramedia (converted from this by Chris Moody: https://www.tradingview.com/v/ngO3BO37/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class GANNSWING
    constructor: () ->
        @count = 0
        @buycount = 0
        @sellcount = 0
        @lowma = []
        @highma = []

        # INITIALIZE ARRAYS
        for [@lowma.length..5]
            @lowma.push 0
        for [@highma.length..5]
            @highma.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # REMOVE OLD DATA
        @lowma.pop()
        @highma.pop()

        # ADD NEW DATA
        @lowma.unshift(0)
        @highma.unshift(0)

        # CALCULATE
        highma = talib.SMA
            inReal: instrument.high
            startIdx: 0
            endIdx: instrument.high.length-1
            optInTimePeriod: 50
        @highma[0] = highma[highma.length-1]

        lowma = talib.SMA
            inReal: instrument.low
            startIdx: 0
            endIdx: instrument.low.length-1
            optInTimePeriod: 50
        @lowma[0] = lowma[lowma.length-1]

        if close > @highma[1]
            hld = 1
        else if close < @lowma[1]
            hld = -1
        else
            hld = 0

        if hld != 0
            @count++

        if hld != 0 && @count == 1
            hlv = hld
            @count = 0
        else
            hlv = 0

        if hlv == -1
            hi = @highma[0]
            plotMark
                "hi": hi
            @sellcount++
            @buycount = 0

        if hlv == 1
            lo = @lowma[0]
            plotMark
                "lo": lo
            @buycount++
            @sellcount = 0

        if @buycount == 3
            buy instrument
            @buycount = 0

        if @sellcount == 3
            sell instrument
            @sellcount = 0

        # TEMP DEBUG
       

        # RETURN DATA
        result =
            close: close

        return result 
      

init: (context)->
    
    context.swing = new GANNSWING()

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
    swing = context.swing.calculate(instrument)
    

    # TRADING

    
    # PLOTTING / DEBUG
    plot
    setPlotOptions

    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc