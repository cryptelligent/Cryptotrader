###
CM WILLIAMS VIX FIX
by aspiramedia (converted from this by Chris Moody: https://www.tradingview.com/v/og7JPrRA/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class VIX
    constructor: () ->
        @close = []
        @wvf = []
        @trade = []
        @count = 0

        # INITIALIZE ARRAYS
        for [@close.length..22]
            @close.push 0
        for [@wvf.length..20]
            @wvf.push 0
        for [@trade.length..5]
            @trade.push 0
        
    calculate: (instrument) ->

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        

        # INCREASE DATA COUNT
        @count++
        
        # REMOVE OLD DATA
        @close.pop()
        @wvf.pop()
        @trade.pop()

        # ADD NEW DATA
        @close.unshift(0)
        @wvf.unshift(0)
        @trade.unshift(0)

        # CALCULATE 
        @close[0] = close
        
        highest = (@close.reduce (a,b) -> Math.max a, b)

        @wvf[0] = ((highest - low) / (highest)) * 100

        sdev = talib.STDDEV
            inReal: @wvf
            startIdx: 0
            endIdx: @wvf.length-1
            optInTimePeriod: 20
            optInNbDev: 1
        sdev = sdev[sdev.length-1]

        midline = talib.SMA
            inReal: @wvf
            startIdx: 0
            endIdx: @wvf.length-1
            optInTimePeriod: 20
        midline = midline[midline.length-1]

        lowerband = midline - sdev
        upperband = midline + sdev

        rangehigh = (@wvf.reduce (a,b) -> Math.max a, b) * 0.85
        rangelow = (@wvf.reduce (a,b) -> Math.min a, b) * 1.01

        if @wvf[0] >= upperband or @wvf[0] >= rangehigh
            @trade[0] = 0
            plotMark
                "wvf1": @wvf[0]
        else
            @trade[0] = 1
            plotMark
                "wvf2": @wvf[0]
            

        # RETURN DATA
        result =
            wvf: @wvf[0]
            rangehigh: rangehigh
            rangelow: rangelow
            trade: @trade

        return result 
      

init: (context)->
    
    context.vix = new VIX()

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
    vix = context.vix.calculate(instrument)
    wvf = vix.wvf
    rangehigh = vix.rangehigh
    rangelow = vix.rangelow
    trade = vix.trade

    # TRADING

    if trade[0] == 1 && trade[1] == 0 && trade[2] == 0 && wvf > 10
        plotMark
            "bottom": price

    # PLOTTING / DEBUG
    setPlotOptions
        bottom:
            color: 'green'
        wvf1: 
            secondary: true
            color: 'blue'
        wvf2: 
            secondary: true
            color: 'black'

    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc