###
High Low compared to close
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74

e.g. https://cryptotrader.org/backtests/FKiKdza2PZW5SSHym
###


class HIGHLOW
    constructor: () ->
        @high = []
        @low = []
        @highdiff = []
        @lowdiff = []
        @count = 0

        # INITIALIZE ARRAYS
        for [@high.length..3]
            @high.push 0
        for [@low.length..3]
            @low.push 0
        for [@highdiff.length..50]
            @highdiff.push 0
        for [@lowdiff.length..50]
            @lowdiff.push 0
        
    calculate: (instrument) ->

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # INCREASE DATA COUNT
        @count++
        
        # REMOVE OLD DATA
        @high.pop()
        @low.pop()
        @highdiff.pop()
        @lowdiff.pop()

        # ADD NEW DATA
        @high.unshift(0)
        @low.unshift(0)
        @highdiff.unshift(0)
        @lowdiff.unshift(0)

        # CALCULATE 
        @high[0] = high
        @low[0] = low
        @highdiff[0] = high / close - 1
        @lowdiff[0] = close / low - 1

        highdiffavg = talib.EMA
            inReal: @highdiff
            startIdx: 0
            endIdx: @highdiff.length-1
            optInTimePeriod: 50

        lowdiffavg = talib.EMA
            inReal: @lowdiff
            startIdx: 0
            endIdx: @lowdiff.length-1
            optInTimePeriod: 50

        # RETURN DATA
        result =
            highdiff: @highdiff[0]
            lowdiff: @lowdiff[0]
            highdiffavg: highdiffavg[highdiffavg.length-1]
            lowdiffavg: lowdiffavg[lowdiffavg.length-1]

        return result 
      
init: (context)->
    
    context.highlow = new HIGHLOW()

    # For finalise stats
    context.balance_curr = 0
    context.balance_btc = 0
    context.price = 0

handle: (context, data)->

    instrument = data.instruments[0]
    price = instrument.close[instrument.close.length - 1]

    # For finalise stats
    context.price = instrument.close[instrument.close.length - 1]
    context.balance_curr = portfolio.positions[instrument.curr()].amount
    context.balance_btc = portfolio.positions[instrument.asset()].amount

    # Getting Indicators
    highlow = context.highlow.calculate(instrument)
    highdiff = highlow.highdiff
    lowdiff = highlow.lowdiff
    highdiffavg = highlow.highdiffavg
    lowdiffavg = highlow.lowdiffavg

    # Trading
    if highdiffavg < lowdiffavg / 1.1
        buy instrument
    if highdiffavg > lowdiffavg * 1.1
        sell instrument

    # Plotting
    plot
        highdiffavg: highdiffavg
        lowdiffavg: lowdiffavg
    setPlotOptions
        highdiffavg:
          secondary: true
        lowdiffavg:
          secondary: true

    
finalize: (contex, data)-> 

    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc