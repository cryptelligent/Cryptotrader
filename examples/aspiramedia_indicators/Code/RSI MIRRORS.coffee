###
RSI MIRRORS
by aspiramedia (Originally by RicardoSantos at: https://www.tradingview.com/v/yrYCHjPA/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

###
https://www.tradingview.com/e/HpDAIwZU/
###

class RSIMIRRORS
    constructor: () ->

        @count = 0
        @output = []
        @rsi1raw = []
        @rsi2raw = []

        # INITIALIZE ARRAYS
        for [@output.length..5]
            @output.push 0
        for [@rsi1raw.length..50]
            @rsi1raw.push 0
        for [@rsi2raw.length..50]
            @rsi2raw.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # REMOVE OLD DATA
        @output.pop()
        @rsi1raw.pop()
        @rsi2raw.pop()

        # ADD NEW DATA
        @output.unshift(0)
        @rsi1raw.unshift(0)
        @rsi2raw.unshift(0)

        # CALCULATE
        buylimit    = 40
        selllimit   = 60
        fastrsi     = 14
        slowrsi     = 50
        rsismooth   = 4

        rsi1raw = talib.RSI
            inReal: instrument.close
            startIdx: 0
            endIdx: instrument.close.length-1
            optInTimePeriod: fastrsi
        @rsi1raw[0] = rsi1raw[rsi1raw.length-1] 

        rsi2raw = talib.RSI
            inReal: instrument.close
            startIdx: 0
            endIdx: instrument.close.length-1
            optInTimePeriod: slowrsi
        @rsi2raw[0] = rsi2raw[rsi2raw.length-1]   

        rsi1 = talib.MA
            inReal: @rsi1raw
            startIdx: 0
            endIdx: @rsi1raw.length-1
            optInTimePeriod: rsismooth
            optInMAType: 0
        rsi1 = rsi1[rsi1.length-1]

        rsi2 = talib.MA
            inReal: @rsi2raw
            startIdx: 0
            endIdx: @rsi2raw.length-1
            optInTimePeriod: rsismooth
            optInMAType: 0
        rsi2 = rsi2[rsi2.length-1]
        
        # TEMP DEBUG
        plot
            rsi1raw: @rsi1raw[0]
            rsi2raw: @rsi2raw[0]
            rsi1: rsi1
            rsi2: rsi2
        setPlotOptions
            rsi1raw:
                secondary: true
            rsi2raw:
                secondary: true
            rsi1:
                secondary: true
            rsi2:
                secondary: true

        

        # RETURN DATA
        result =
            output: close
        return result 
      

init: (context)->
    
    context.rsimirros = new RSIMIRRORS()

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
    rsimirros = context.rsimirros.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc