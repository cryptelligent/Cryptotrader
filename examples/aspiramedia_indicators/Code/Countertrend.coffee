###
Countertrend
by aspiramedia (Via DanPochettes at: https://www.tradingview.com/v/BbDTKByL/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class COUNTERTREND
    constructor: (@period, @bars) ->

        @count = 0
        @mg = []
        @BullTDiff = []
        @BearTDiff = []
        @BullTDiffSmooth = []
        @BearTDiffSmooth = []

        # INITIALIZE ARRAYS
        for [@mg.length..5]
            @mg.push 0
        for [@BullTDiff.length..5]
            @BullTDiff.push 0
        for [@BearTDiff.length..5]
            @BearTDiff.push 0 
        for [@BullTDiffSmooth.length..5]
            @BullTDiffSmooth.push 0
        for [@BearTDiffSmooth.length..5]
            @BearTDiffSmooth.push 0            
        
    calculate: (instrument) ->        

        open = instrument.open[instrument.open.length-1]
        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        ochl4 = ((open + close + high + low) / 4)

        # REMOVE OLD DATA
        @mg.pop()
        @BullTDiff.pop()
        @BearTDiff.pop()
        @BullTDiffSmooth.pop()
        @BearTDiffSmooth.pop()

        # ADD NEW DATA
        @mg.unshift(0)
        @BullTDiff.unshift(0)
        @BearTDiff.unshift(0)
        @BullTDiffSmooth.unshift(0)
        @BearTDiffSmooth.unshift(0)

        # CALCULATE
        @count++

        if @count == 1
            @mg[0] = instrument.ema(@period)
        else
            @mg[0] = @mg[1] + (close - @mg[1]) / (@period * Math.pow((close / @mg[1]), 4))


        BullR = (instrument.high[-@bars..].reduce (a,b) -> Math.max a, b) - ochl4
        BearR = ochl4 - (instrument.low[-@bars..].reduce (a,b) -> Math.min a, b)

        BullT = if high < @mg[0] then @mg[0] else (close + BullR)
        BearT = if low > @mg[0] then @mg[0] else (close - BearR)

        @BullTDiff[0] = BullT - close
        @BearTDiff[0] = close - BearT

        BullTDiffSmooth = talib.MA
            inReal: @BullTDiff
            startIdx: 0
            endIdx: @BullTDiff.length-1
            optInTimePeriod: 5
            optInMAType : 0
        @BullTDiffSmooth[0] = BullTDiffSmooth[BullTDiffSmooth.length-1]

        BearTDiffSmooth = talib.MA
            inReal: @BearTDiff
            startIdx: 0
            endIdx: @BearTDiff.length-1
            optInTimePeriod: 5
            optInMAType : 0
        @BearTDiffSmooth[0] = BearTDiffSmooth[BearTDiffSmooth.length-1]

        if @BullTDiffSmooth[0] > @BearTDiffSmooth[0]
            buy instrument

        if @BearTDiffSmooth[0] > @BullTDiffSmooth[0]
            sell instrument

        plot
            mg: @mg[0]
            BullT: BullT
            BearT: BearT
            BullTDiff: @BullTDiff[0]
            BearTDiff: @BearTDiff[0]
            BullTDiffSmooth: @BullTDiffSmooth[0]
            BearTDiffSmooth: @BearTDiffSmooth[0]
        setPlotOptions
            BullTDiff:
                secondary: true
            BullTDiffSmooth:
                secondary: true
            BearTDiff:
                secondary: true
            BearTDiffSmooth:
                secondary: true        
        
        
        # TEMP DEBUG
        plot

        

        # RETURN DATA
        result =
            mg: @mg[0]

        return result 
      

init: (context)->
    
    context.countertrend = new COUNTERTREND(120, 30)

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
    countertrend = context.countertrend.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc