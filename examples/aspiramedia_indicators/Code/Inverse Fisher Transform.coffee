###
Inverse Fisher Transform (By John Ehlers: http://www.mesasoftware.com/Papers/THE%20INVERSE%20FISHER%20TRANSFORM.pdf)
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class IFISHER
    constructor: (@rsiperiod,@maperiod) ->

        @count = 0
        @Value1  = []
        @IFish = []

        for [@IFish.length..5]
            @IFish.push 0

        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]

        @IFish.pop()
        @IFish.unshift(0)

        # CALCULATE
        rsi = talib.RSI
            inReal: instrument.close
            startIdx: 0
            endIdx: instrument.close.length-1
            optInTimePeriod: @rsiperiod
        rsi = rsi[rsi.length-1]

        for [@Value1.length..@maperiod]
            @Value1.push (0.1 * (rsi - 50))
        if @Value1.length > @maperiod
            @Value1.shift() 

        wma = talib.WMA
            inReal: @Value1
            startIdx: 0
            endIdx: @Value1.length - 1
            optInTimePeriod: @maperiod
        Value2 = wma[wma.length-1]

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
    
    context.ifisher = new IFISHER(5,9)

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