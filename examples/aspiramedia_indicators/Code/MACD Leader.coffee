###
MACD LEADER
by aspiramedia (converted from this by LazyBear: https://www.tradingview.com/v/y9HCZoQi/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class MACDLEADER
    constructor: () ->
        @count = 0
        @semadiff = []
        @lemadiff = []

        # INITIALIZE ARRAYS
        for [@semadiff.length..12]
            @semadiff.push 0
        for [@lemadiff.length..26]
            @lemadiff.push 0
        
    calculate: (instrument) ->        

        # INCREASE DATA COUNT
        @count++

        # REMOVE OLD DATA
        @semadiff.pop()
        @lemadiff.pop()

        # ADD NEW DATA
        @semadiff.unshift(0)
        @lemadiff.unshift(0)

        # CALCULATE 
        close = instrument.close[instrument.close.length-1]

        sema = instrument.ema(12)
        lema = instrument.ema(26)

        @semadiff[0] = close - sema
        @lemadiff[0] = close - lema

        semadiffma = talib.EMA
            inReal: @semadiff
            startIdx: 0
            endIdx: @semadiff.length-1
            optInTimePeriod: 12
        semadiffma = semadiffma[semadiffma.length-1]

        lemadiffma = talib.EMA
            inReal: @lemadiff
            startIdx: 0
            endIdx: @lemadiff.length-1
            optInTimePeriod: 26
        lemadiffma = lemadiffma[lemadiffma.length-1]

        i1 = sema + semadiffma
        i2 = lema + lemadiffma

        macdl = i1 - i2
        macd = sema - lema

        # RETURN DATA
        result =
            macd: macd
            macdl: macdl

        return result 
      

init: (context)->
    
    context.leader = new MACDLEADER()

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
    leader = context.leader.calculate(instrument)
    macd = leader.macd
    macdl = leader.macdl

    # TRADING
    if macdl > macd
        buy instrument

    if macdl < macd
        sell instrument

    if macdl > 0
        buy instrument
    if macdl < 0
        sell instrument

    
    # PLOTTING / DEBUG
    plot
        macd: macd
        macdl: macdl
    setPlotOptions
        macd: 
            secondary: true
            color: 'blue'
        macdl: 
            secondary: true
            color: 'green'


    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc