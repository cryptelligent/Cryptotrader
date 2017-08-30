###
HiLo Activator
Originally by augustoximenes at TradingView: https://www.tradingview.com/script/BHdCRnhk-HiLo-Activator/
Converted by aspiramedia
BTC Tips to: 1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class HILO
    constructor: (@period) ->

        @count = 0
        @high = []
        @low = []
        @reversal = []

        # INITIALIZE ARRAYS
        for [@high.length..@period]
            @high.push 0
        for [@low.length..@period]
            @low.push 0
        for [@reversal.length..5]
            @reversal.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # REMOVE OLD DATA
        @high.pop()
        @low.pop()
        @reversal.pop()

        # ADD NEW DATA
        @high.unshift(0)
        @low.unshift(0)
        @reversal.unshift(0)


        # CALCULATE
        smahigh = talib.SMA
            inReal: instrument.high
            startIdx: 0
            endIdx: instrument.high.length-1
            optInTimePeriod: @period
        smahigh = smahigh[smahigh.length-1]

        smalow = talib.SMA
            inReal: instrument.low
            startIdx: 0
            endIdx: instrument.low.length-1
            optInTimePeriod: @period
        smalow = smalow[smalow.length-1]

        @high[0] = high
        @low[0] = low

        highest = (@high.reduce (a,b) -> Math.max a, b)
        lowest = (@low.reduce (a,b) -> Math.min a, b)

        ###
        MY EDIT: I used a short ema instead of close to detect the reversal.
        ###
        if instrument.ema(2) > smahigh
            @reversal[0] = 1
        else if instrument.ema(2) < smalow
            @reversal[0] = -1
        else
            @reversal[0] = 0      
        
        
        # TEMP DEBUG
        plot
            smahigh: smahigh
            smalow: smalow
            reversal: @reversal[0]
        setPlotOptions
            reversal:
                secondary: true

        

        # RETURN DATA
        result =
            reversal: @reversal

        return result 
      

init: (context)->
    
    context.hilo = new HILO(4)

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
    hilo = context.hilo.calculate(instrument)
    reversal = hilo.reversal
    
    # TRADING

    ###
    Some possible trading logic.
    ###
    if reversal[0] == 1 && reversal[1] == 1
        buy instrument
    if reversal[0] == -1 && reversal[1] == -1
        sell instrument


    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc