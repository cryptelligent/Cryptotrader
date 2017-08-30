###
Heikin-Ashi Bars
by aspiramedia (converted from Chris Moody)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class HEIKIN
    constructor: () ->

        @count = 0
        @haclose = []
        @haopen = []
        @ha = []

        # INITIALIZE ARRAYS
        for [@haclose.length..5]
            @haclose.push 0
        for [@haopen.length..5]
            @haopen.push 0
        for [@ha.length..20]
            @ha.push 0
        
    calculate: (instrument) ->        

        open = instrument.open[instrument.open.length-1]
        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # REMOVE OLD DATA
        @haclose.pop()
        @haopen.pop()
        @ha.pop()

        # ADD NEW DATA
        @haclose.unshift(0)
        @haopen.unshift(0)
        @ha.unshift(0)

        # CALCULATE
        @haclose[0] = ((open + high + low + close) / 4)
        @haopen[0] = (@haopen[1] + @haclose[1]) / 2

        if @haclose[0] > @haopen[0]
            @ha[0] = 1
            plotMark
                "up": close
        if @haclose[0] <= @haopen[0]
            @ha[0] = 0
            plotMark
                "down": close
        
        # TEMP DEBUG
        plot
            close: close
        setPlotOptions
            down:
                color: 'red'
            up:
                color: 'cyan'

        # RETURN DATA
        result =
            ha: @ha

        return result 
      

init: (context)->
    
    context.heikin = new HEIKIN()

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
    heikin = context.heikin.calculate(instrument)
    ha = heikin.ha

    # TRADING
    avg = (ha.reduce (x, y) -> x + y) / ha.length

    if avg > 0.5
        buy instrument
    if avg < 0.5
        sell instrument

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc