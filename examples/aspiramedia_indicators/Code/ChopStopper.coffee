###
Chop Stopper
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class SQUEEZE
    constructor: (@period) ->
        @close = []
        @high  = []
        @low   = []
        @bbr  = []
        @range = []
        @val = []
        @squeeze = []

        for [@val.length..5]
            @val.push 0
        for [@squeeze.length..5]
            @squeeze.push 0
    
    calculate: (instrument) ->

        close = instrument.close[instrument.close.length-1]
        high  = instrument.high[instrument.high.length-1]
        low   = instrument.low[instrument.low.length-1]
        range = high - low

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
        if @bbr.length > @period
            @bbr.shift()
        if @range.length > @period
            @range.shift()

        @val.pop()
        @val.unshift(0)

        @squeeze.pop()
        @squeeze.unshift(0)

        # SQUEEZE TEST

        length = @period
        mult = 2
        lengthkc = @period
        multkc = 1.5

        # Calculate BB
        basis = talib.SMA
            inReal: instrument.close
            startIdx: 0
            endIdx: instrument.close.length-1
            optInTimePeriod: @period
        basis = basis[basis.length-1]

        stdev = talib.STDDEV
            inReal: instrument.close
            startIdx: 0
            endIdx: instrument.close.length-1
            optInTimePeriod: @period
            optInNbDev: 1
        stdev = stdev[stdev.length-1]

        dev = stdev * multkc

        upperbb = basis + dev
        lowerbb = basis - dev

        # Calculate KC
        ma = talib.SMA
            inReal: instrument.close
            startIdx: 0
            endIdx: instrument.close.length-1
            optInTimePeriod: @period
        ma = ma[ma.length-1]

        for [@range.length..@period]
            @range.push range
        if @range.length > @period
            @range.shift()  

        rangema = talib.SMA
            inReal: @range
            startIdx: 0
            endIdx: @range.length-1
            optInTimePeriod: @period
        rangema = rangema[rangema.length-1]

        upperkc = ma + rangema * multkc
        lowerkc = ma - rangema * multkc

        # CALCULATE VAL

        for [@bbr.length..@period]
            @bbr.push ((close - lowerbb)/(upperbb - lowerbb)) - 0.5 
        if @bbr.length > @period
            @bbr.shift()   

        # bbr = ((source - lowerBB)/(upperBB - lowerBB))-0.5 
     
        val = talib.SMA
            inReal: @bbr
            startIdx: 0
            endIdx: @bbr.length-1
            optInTimePeriod: @period
        @val[0] = val[val.length-1]

        # Calculate Squeeze
        if (lowerbb > lowerkc) and (upperbb < upperkc)
            @squeeze[0] = 1
            plotMark
                "squeezeon": 0
        else
            @squeeze[0] = 0
            plotMark
                "squeezeoff": 0

        # RESULTS
        result =
            val: @val
            squeeze: @squeeze
        return result

        
     
init: (context)->

    context.squeeze = new SQUEEZE(20)

handle: (context, data, storage)->

    instrument = data.instruments[0]
    price = instrument.close[instrument.close.length - 1]

    squeeze = context.squeeze.calculate(instrument)
    val = squeeze.val
    squeeze = squeeze.squeeze

    coin = portfolio.positions[instrument.asset()].amount
    fiat = portfolio.positions[instrument.curr()].amount
    coinequivalent = coin * price
    diff = fiat - coinequivalent

    tobuy = Math.abs((diff / price) / 2)
    tosell = Math.abs((diff / price) / 2)

    if squeeze[0] == 1 && squeeze[1] == 0
        if diff > 0
            buy instrument, tobuy, price, 3000
            
        else if diff < 0
            sell instrument, tosell, price, 3000

    else
        # Usual trading here



    plot
        diff: diff
    setPlotOptions
        squeezeon: 
            color: 'red'
            secondary: true
        squeezeoff:
            color: 'green'
            secondary: true
        diff:
            secondary: true

finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc            