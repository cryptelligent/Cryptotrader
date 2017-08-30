###
Fractals
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

###
study("My fractals",overlay=true)

th = high[2]>high[1] and high[2]>high and high[2]>high[3] and high[2]>high[4] ? -1 : 0

bl = low[2]<low[1] and low[2]<low and low[2]<low[3] and low[2]<low[4] ? 1 : 0

tot = th + bl
pl = abs(tot)>=1 ? 1 : 0
plotarrow(pl==1 ? tot : na,colorup=green,colordown=red,offset=-2,maxheight=10)
###

class FRACTALS
    constructor: () ->

        @count = 0
        @output = []

        # INITIALIZE ARRAYS
        for [@output.length..5]
            @output.push 0
        
    calculate: (instrument) ->        

        high = instrument.high
        low = instrument.low

        # REMOVE OLD DATA
        @output.pop()

        # ADD NEW DATA
        @output.unshift(0)

        # CALCULATE
        if instrument.high[instrument.high.length-3] > instrument.high[instrument.high.length-2] and instrument.high[instrument.high.length-3] > instrument.high[instrument.high.length-1] and instrument.high[instrument.high.length-3] > instrument.high[instrument.high.length-4] and instrument.high[instrument.high.length-3] > instrument.high[instrument.high.length-5]
            th = -1
        else
            th = 0

        if instrument.low[instrument.low.length-3] < instrument.low[instrument.low.length-4] and instrument.low[instrument.low.length-3] < instrument.low[instrument.low.length-1] and instrument.low[instrument.low.length-3] < instrument.low[instrument.low.length-4] and instrument.low[instrument.low.length-3] < instrument.low[instrument.low.length-5]
            bl = 1
        else
            bl = 0

        tot = th + bl

        if Math.abs(tot) >= 1
            pl = 1
        else
            pl = 0

        if pl == 1
            plotMark
                "asd": instrument.close[instrument.close.length-1]
        
        
        # TEMP DEBUG
        setPlotOptions
            asd: 
                color: 'red'

        

        # RETURN DATA
        result =
            output: @output[0]

        return result 
      

init: (context)->
    
    context.fractals = new FRACTALS()

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
    fractals = context.fractals.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc