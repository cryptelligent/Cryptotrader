###
Pivot Bands
by aspiramedia (converted from Chris Moody: https://www.tradingview.com/v/vtvWAOI6/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74

https://cryptotrader.org/backtests/2xzsYNGfHH9yahokN
https://cryptotrader.org/backtests/oqf6jSmeyWyJmjiZh
###

class PIVOT
    constructor: (@period) ->

        @count = 0
        @sband = 0
        @rband = 0
        @PP = []
        @close = []
        @high  = []
        @low   = []
        @HP1 = []
        @LP1 = []
        @HP2 = []
        @LP2 = []
        @sband = []
        @rband = []

        for [@HP1.length..10]
            @HP1.push 0
        for [@LP1.length..10]
            @LP1.push 0
        for [@HP2.length..10]
            @HP2.push 0
        for [@LP2.length..10]
            @LP2.push 0
        for [@sband.length..10]
            @sband.push 0
        for [@rband.length..10]
            @rband.push 0

        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        lengthMA = @period

        for [@close.length..@period]
            @close.push close
        for [@high.length..@period]
            @high.push high
        for [@low.length..@period]
            @low.push low
 
        if @close.length > @period
            @close.shift()
        if @high.length > @period
            @high.shift()
        if @low.length > @period
            @low.shift()

        for [@PP.length..@period]
            @PP.push ((high + low  + close) / 3)
        if @PP.length > @period
            @PP.shift() 

        @HP1.pop()
        @HP1.unshift(0)
        @LP1.pop()
        @LP1.unshift(0)
        @HP2.pop()
        @HP2.unshift(0)
        @LP2.pop()
        @LP2.unshift(0)
        @sband.pop()
        @sband.unshift(0)
        @rband.pop()
        @rband.unshift(0)

        # CALCULATE
        
        PP = ((high + low  + close) / 3)

        PPEMA = talib.EMA
            inReal: @PP
            startIdx: 0
            endIdx: @PP.length-1
            optInTimePeriod: lengthMA
        PPEMA = PPEMA[PPEMA.length-1]

        @HP1[0] = (PP + (PP - low))
        @LP1[0] = (PP - (high - PP))
        @HP2[0] = (PP + 2 * (PP - low))
        @LP2[0] = (PP - 2 * (high - PP))

        PPD71 = (((@HP1[0] - @LP1[0])+(@HP1[1] - @LP1[1])+(@HP1[2] - @LP1[2])+(@HP1[3] - @LP1[3])+(@HP1[4] - @LP1[4])+(@HP1[5] - @LP1[5])+(@HP1[6] - @LP1[6]))/7)
        PPD72 = (((@HP2[0] - @LP2[0])+(@HP2[1] - @LP2[1])+(@HP2[2] - @LP2[2])+(@HP2[3] - @LP2[3])+(@HP2[4] - @LP2[4])+(@HP2[5] - @LP2[5])+(@HP2[6] - @LP2[6]))/7)
        
        r1 = PPEMA + PPD71
        s1 = PPEMA - PPD71
        r2 = PPEMA + PPD72
        s2 = PPEMA - PPD72

        
        # TRADING
        if s2 < close < s1 
            @sband[0] = 1
        else
            @sband[0] = 0
        if r1 < close < r2
            @rband[0] = 1
        else
            @rband[0] = 0

        if @sband[0] == 0 and @sband[1] == 1 and close > s1
            buy instrument
        if @rband[0] == 0 and @rband[1] == 1 and close < r1
            sell instrument

        # TEMP DEBUG
        plot
            PPEMA: PPEMA
            r1: r1
            s1: s1
            r2: r2
            s2: s2
            sband: @sband[0]
            rband: @rband[0]
        setPlotOptions
            PPEMA:
                color: 'fuchsia'
            r1:
                color: '#DC143C'
            s1:
                color: 'lime'
            r2:
                color: 'maroon'
            s2:
                color: '#228B22'
            sband:
                secondary: true
            rband:
                secondary: true
        

        # RETURN DATA
        result =
            close: close

        return result 
      

init: (context)->
    
    context.pivot = new PIVOT(7)

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
    pivot = context.pivot.calculate(instrument)

    # TRADING

    
    # PLOTTING / DEBUG
    plot


    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc