###
Cyber Cycle with Inverse Fisher Transform (By John Ehlers: http://www.mesasoftware.com/Papers/THE%20INVERSE%20FISHER%20TRANSFORM.pdf)
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class CYBER
    constructor: () ->

        @count = 0
        @Price  = []
        @Smooth = []
        @Cycle = []
        @ICycle = []

        for [@Price.length..5]
            @Price.push 0
        for [@Smooth.length..5]
            @Smooth.push 0
        for [@Cycle.length..5]
            @Cycle.push 0
        for [@ICycle.length..5]
            @ICycle.push 0

        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        @Price[0] = (high+low) / 2
        alpha = 0.07

        # INCREASE DATA COUNT
        @count++
        
        # REMOVE OLD DATA
        @Price.pop()
        @Price.unshift(0)
        @Smooth.pop()
        @Smooth.unshift(0)
        @Cycle.pop()
        @Cycle.unshift(0)
        @ICycle.pop()
        @ICycle.unshift(0)

        # CALCULATE
        @Smooth[0] = (@Price[0] + 2*@Price[1] + 2*@Price[2] + @Price[3])/6

        if @count < 7 
            @Cycle[0] = (@Price[0] - 2*@Price[1]+ @Price[2]) / 4
        else
            @Cycle[0] = (1 - 0.5*alpha)*(1 - 0.5*alpha)*(@Smooth[0] - 2*@Smooth[1] + @Smooth[2]) + 2*(1 - alpha)*@Cycle[1] - (1 - alpha)*(1 - alpha)*@Cycle[2]

        @ICycle[0] = (Math.exp(2*@Cycle[0]) - 1) / (Math.exp(2*@Cycle[0]) + 1)

        # TEMP DEBUG
        
        
        

        # RETURN DATA
        result =
            ICycle: @ICycle

        return result 
      

init: (context)->
    
    context.cyber = new CYBER()

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
    cyber = context.cyber.calculate(instrument)
    ICycle = cyber.ICycle
    
    # TRADING
    if ICycle[0] > -0.5 && ICycle[1] < -0.5
        buy instrument
    if ICycle[0] < 0.5 && ICycle[1] > 0.5
        sell instrument

    if ICycle[0] > 0.5 && ICycle[1] < 0.5
        buy instrument
    if ICycle[0] < -0.5 && ICycle[1] > -0.5
        sell instrument


    
    # PLOTTING / DEBUG
    plot
        ICycle: ICycle[0]
    setPlotOptions
        ICycle:
            secondary: true



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc