###
Fractal Adaptive MA
by aspiramedia (converted from http://www.mesasoftware.com/Papers/FRAMA.pdf)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class FRAMA
    constructor: (@period) ->
        @count = 0
        @frama = []

        # INITIALIZE ARRAYS
        for [@frama.length..5]
            @frama.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # INCREASE DATA COUNT
        @count++

        # REMOVE OLD DATA
        @frama.pop()

        # ADD NEW DATA
        @frama.unshift(0)

        # CALCULATE
        h1 = (instrument.high[-@period..].reduce (a,b) -> Math.max a, b)
        l1 = (instrument.low[-@period..].reduce (a,b) -> Math.min a, b)
        h2 = (instrument.high[-(@period * 2)..-@period].reduce (a,b) -> Math.max a, b)
        l2 = (instrument.low[-(@period * 2)..-@period].reduce (a,b) -> Math.min a, b)
        h3 = (instrument.high[-(@period * 2)..].reduce (a,b) -> Math.max a, b)
        l3 = (instrument.low[-(@period * 2)..].reduce (a,b) -> Math.min a, b)

        ###
        N1=(HighestPrice – LowestPrice) over the interval from 0 to T, divided by T.
        N2=(HighestPrice – LowestPrice) over the interval from T to 2T, divided by T
        N3= (HighestPrice – LowestPrice) over the entire interval from 0 to 2T, divided by 2T. 
        ###

        N1 = (h1 - l1) / @period
        N2 = (h2 - l2) / @period
        N3 = (h3 - l3) / (@period * 2)

        if N1>0 and N2>0 and N3>0
            D = (Math.log(N1 + N2) - Math.log(N3)) / Math.log(2)
        else
            D = 0

        a = Math.exp(-4.6 * (D - 1))

        if a < 0.01 then a = 0.01 
        if a > 1 then a = 1

        if @count < @period
            @frama[0] = close
        else
            @frama[0] = a * close + (1 - a) * @frama[1]       
        


        # RETURN DATA
        result =
            frama: @frama[0]

        return result 
      

init: (context)->
    
    context.frama = new FRAMA(16) # Period

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
    frama = context.frama.calculate(instrument)
    frama = frama.frama

    # TRADING

    
    # PLOTTING / DEBUG
    plot
        frama: frama
        ema: instrument.ema(16)

    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc