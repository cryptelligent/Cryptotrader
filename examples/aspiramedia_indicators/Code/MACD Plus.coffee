###
MACD Plus
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

###
MACD Line: (12-day EMA - 26-day EMA)  
Signal Line: 9-day EMA of MACD Line
MACD Histogram: MACD Line - Signal Line
###

class MACDPLUS
    constructor: () ->

        @count  = 0
        @macd  = []
        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []
        @laguerre = []

        # INITIALIZE ARRAYS
        for [@L0.length..5]
            @L0.push 0
        for [@L1.length..5]
            @L1.push 0
        for [@L2.length..5]
            @L2.push 0
        for [@L3.length..5]
            @L3.push 00
        for [@laguerre.length..5]
            @laguerre.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]

        # INCREASE DATA COUNT
        @count++

        # REMOVE OLD DATA
        @L0.pop()
        @L1.pop()
        @L2.pop()
        @L3.pop()
        @laguerre.pop()

        # ADD NEW DATA
        @L0.unshift(0)
        @L1.unshift(0)
        @L2.unshift(0)
        @L3.unshift(0)
        @laguerre.unshift(0)

        # CALCULATE

        # Usual MACD
        shortema = talib.EMA
            inReal: instrument.close
            startIdx: 0
            endIdx: instrument.close.length-1
            optInTimePeriod: 12
        shortema = shortema[shortema.length-1]

        longema = talib.EMA
            inReal: instrument.close
            startIdx: 0
            endIdx: instrument.close.length-1
            optInTimePeriod: 26
        longema = longema[longema.length-1]

        macd = shortema - longema

        for [@macd.length..9]
            @macd.push macd
        if @macd.length > 9
            @macd.shift() 

        signal = talib.EMA
            inReal: @macd
            startIdx: 0
            endIdx: @macd.length-1
            optInTimePeriod: 9
        signal = signal[signal.length-1]

        histogram = macd - signal

        # Laguerre MACD
        g = 0.5

        @L0[0] = ((1 - g) * @macd[0]) + (g * @L0[1])
        @L1[0] = (-g * @L0[0]) + @L0[1] + (g * @L1[1])
        @L2[0] = (-g * @L1[0]) + @L1[1] + (g * @L2[1])
        @L3[0] = (-g * @L2[0]) + @L2[1] + (g * @L3[1])

        @laguerre[0] = (@L0[0] + (2 * @L1[0]) + (2 * @L2[0]) + @L3[0]) / 6          # Laguerre filter

        histogram2 = @laguerre[0] - signal



        # TEMP DEBUG
        plot
            histogram: histogram
            laguerre: @laguerre[0]
            histogram2: histogram2
        setPlotOptions
            histogram:
                secondary: true
            laguerre:
                secondary: true
            histogram:
                secondary: true
        

        # RETURN DATA
        result =
            close: close

        return result 
      

init: (context)->
    
    context.macdplus = new MACDPLUS()   # RSI Period, Gamma (laguerre filter strength)

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
    macdplus = context.macdplus.calculate(instrument)

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