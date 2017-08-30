###
CCT Bollinger Band Oscillator (CCTBO)
aspiramedia (https://cryptotrader.org/aspiramedia)
BTC: 1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74

Originally by lazybear: https://www.tradingview.com/v/iA4XGCJW/
###

class CCTBO
    constructor: (@period,@NbDev,@g) ->

        @count = 0
        @output = []
        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []
        @laguerre = []

        # INITIALIZE ARRAYS
        for [@output.length..5]
            @output.push 0
        for [@L0.length..5]
            @L0.push 0
        for [@L1.length..5]
            @L1.push 0
        for [@L2.length..5]
            @L2.push 0
        for [@L3.length..5]
            @L3.push 0
        for [@laguerre.length..5]
            @laguerre.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        g = @g

        # REMOVE OLD DATA
        @output.pop()

        # ADD NEW DATA
        @output.unshift(0)

        # CALCULATE
        SMA = talib.SMA
          inReal: instrument.close
          startIdx: 0
          endIdx: instrument.close.length - 1
          optInTimePeriod: @period
        sma = _.last(SMA)

        STDDEV = talib.STDDEV
          inReal: instrument.close
          startIdx: 0
          endIdx: instrument.close.length - 1
          optInTimePeriod: @period
          optInNbDev: @NbDev
        stddev = _.last(STDDEV)

        cctbbo = 100 * (close + 2 * stddev - sma) / (4 * stddev)

        # CALCULATE
        @L0[0] = ((1 - g) * cctbbo) + (g * @L0[1])
        @L1[0] = (-g * @L0[0]) + @L0[1] + (g * @L1[1])
        @L2[0] = (-g * @L1[0]) + @L1[1] + (g * @L2[1])
        @L3[0] = (-g * @L2[0]) + @L2[1] + (g * @L3[1])

        @laguerre[0] = (@L0[0] + (2 * @L1[0]) + (2 * @L2[0]) + @L3[0]) / 6
        
        
        
        # TEMP DEBUG
        plot
          cctbbo: cctbbo
          smooth: @laguerre[0]
          100: 100
          0: 0
        setPlotOptions
          100:
            secondary: true
          0:
            secondary: true
          cctbbo:
            secondary: true
          smooth:
            secondary: true

        

        # RETURN DATA
        result =
            output: @output[0]

        return result 
      

init: (context)->
    
    context.cctbo = new CCTBO(21,1,0.5)

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
    cctbo = context.cctbo.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc