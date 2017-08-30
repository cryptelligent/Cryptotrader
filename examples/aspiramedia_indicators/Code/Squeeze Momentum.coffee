###
Squeeze Momentum
by aspiramedia (converted from this by LazyBear: https://www.tradingview.com/v/nqQ1DT5a/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class SQUEEZE
    constructor: (@period) ->
        @close = []
        @high  = []
        @low   = []
        @diff  = []
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
        if @diff.length > @period
            @diff.shift()
        if @range.length > @period
            @range.shift()

        @val.pop()
        @val.unshift(0)

        @squeeze.pop()
        @squeeze.unshift(0)

        # CALCULATE VAL

        ma = talib.MA
            inReal: @close
            startIdx: 0
            endIdx: @close.length-1
            optInTimePeriod: @period
            optInMAType : 0
        ma = ma[ma.length-1]

        highest = (instrument.high[-@period..].reduce (a,b) -> Math.max a, b)
        lowest  = (instrument.low[-@period..].reduce (a,b) -> Math.min a, b)
        hlavg   = (highest + lowest) / 2
        avg     = (hlavg + ma) / 2

        for [@diff.length..@period]
            @diff.push close - avg
        if @diff.length > @period
            @diff.shift()    
     
        val = talib.LINEARREG
            inReal: @diff
            startIdx: 0
            endIdx: @diff.length-1
            optInTimePeriod: @period
        @val[0] = val[val.length-1]
        
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

    squeeze = context.squeeze.calculate(instrument)
    val = squeeze.val
    squeeze = squeeze.squeeze

    unless storage.directionup == 1
        storage.directionup = 0
    unless storage.directiondown == 1
        storage.directiondown = 0

    if squeeze[0] == 0
        if val[0] > 0 && storage.directionup == 0
            buy instrument
            storage.directionup = 1
        if val[0] < 0 && storage.directiondown == 0
            sell instrument
            storage.directiondown = 1

    if storage.directionup == 1 && val[0] < val[1]
        sell instrument
        storage.directionup = 0
    

    if storage.directiondown == 1 && val[0] > val[1]
        buy instrument
        storage.directiondown = 0

    if squeeze[0] == 1
        storage.directionup = 0
        storage.directiondown = 0

   
    plot
        val: val[0]
        zero: 0
    setPlotOptions
        val:
            secondary: true
        zero:
            secondary: true
        squeezeon: 
            color: 'red'
            secondary: true
        squeezeoff:
            color: 'green'
            secondary: true