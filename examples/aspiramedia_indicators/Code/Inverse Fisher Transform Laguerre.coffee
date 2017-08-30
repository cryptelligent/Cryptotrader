###
Inverse Fisher Transform (By John Ehlers: http://www.mesasoftware.com/Papers/THE%20INVERSE%20FISHER%20TRANSFORM.pdf)
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class IFISHER
    constructor: (@rsiperiod,@g) ->

        @count = 0
        @Value1  = []
        @IFish = []
        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []
        @Price = []
        @laguerre = []

        for [@Value1.length..5]
            @Value1.push 0
        for [@IFish.length..5]
            @IFish.push 0
        for [@L0.length..5]
            @L0.push 0
        for [@L1.length..5]
            @L1.push 0
        for [@L2.length..5]
            @L2.push 0
        for [@L3.length..5]
            @L3.push 0
        for [@Price.length..5]
            @Price.push 0
        for [@laguerre.length..5]
            @laguerre.push 0

        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        g = @g

        # REMOVE OLD DATA
        @IFish.pop()
        @L0.pop()
        @L1.pop()
        @L2.pop()
        @L3.pop()
        @Price.pop()
        @laguerre.pop()

        # ADD NEW DATA
        @IFish.unshift(0)
        @L0.unshift(0)
        @L1.unshift(0)
        @L2.unshift(0)
        @L3.unshift(0)
        @Price.unshift(0)
        @laguerre.unshift(0)

        # CALCULATE
        rsi = talib.RSI
            inReal: instrument.close
            startIdx: 0
            endIdx: instrument.close.length-1
            optInTimePeriod: @rsiperiod
        rsi = rsi[rsi.length-1]

        
        @Value1[0] = (0.1 * (rsi - 50))


        ###
        wma = talib.WMA
            inReal: @Value1
            startIdx: 0
            endIdx: @Value1.length - 1
            optInTimePeriod: @maperiod
        Value2 = wma[wma.length-1]
        ###

        # CALCULATE
        @L0[0] = ((1 - g) * @Value1[0]) + (g * @L0[1])
        @L1[0] = (-g * @L0[0]) + @L0[1] + (g * @L1[1])
        @L2[0] = (-g * @L1[0]) + @L1[1] + (g * @L2[1])
        @L3[0] = (-g * @L2[0]) + @L2[1] + (g * @L3[1])

        Value2 = (@L0[0] + (2 * @L1[0]) + (2 * @L2[0]) + @L3[0]) / 6          # Laguerre filter

        @IFish[0] = (Math.exp(2*Value2) - 1) / (Math.exp(2*Value2) + 1)

        if @IFish[0] > -0.5 && @IFish[1] < -0.5
            buy instrument
        if @IFish[0] < 0.5 && @IFish[1] > 0.5
            sell instrument

        if @IFish[0] > 0.5 && @IFish[1] < 0.5
            buy instrument
        if @IFish[0] < -0.5 && @IFish[1] > -0.5
            sell instrument




        
        # TEMP DEBUG
        
        plot
            IFish: @IFish[0]
            low: -0.5
            high: 0.5
        setPlotOptions
            IFish:
                secondary: true
            low:
                secondary: true
            high:
                secondary: true

        # RETURN DATA
        result =
            IFish: @IFish[0]

        return result 
      

init: (context)->
    
    context.ifisher = new IFISHER(5,0.5)

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
    ifisher = context.ifisher.calculate(instrument)
    IFish = ifisher.IFish
    
    # TRADING


    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc