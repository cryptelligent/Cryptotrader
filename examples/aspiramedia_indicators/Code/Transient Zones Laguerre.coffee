###
Transient Zones with Probability
by aspiramedia (converted from this by Jurij: https://www.tradingview.com/v/NBcEvyej/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class TRANSIENT
    constructor: () ->

        @count = 0
        @high_bar_tz_count = 0
        @low_bar_tz_count = 0
        @high_bar_ptz_count = 0
        @low_bar_ptz_count = 0
        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []
        @laguerre = []
        @L0b = []
        @L1b = []
        @L2b = []
        @L3b = []
        @laguerreb = []

        # INITIALIZE ARRAYS
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
        for [@L0b.length..5]
            @L0b.push 0
        for [@L1b.length..5]
            @L1b.push 0
        for [@L2b.length..5]
            @L2b.push 0
        for [@L3b.length..5]
            @L3b.push 0
        for [@laguerreb.length..5]
            @laguerreb.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        h_left = 10
        h_right = 10
        sample_period = 5000
        g = 0.5

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

        # REMOVE OLD DATA
        @L0b.pop()
        @L1b.pop()
        @L2b.pop()
        @L3b.pop()
        @laguerreb.pop()

        # ADD NEW DATA
        @L0b.unshift(0)
        @L1b.unshift(0)
        @L2b.unshift(0)
        @L3b.unshift(0)
        @laguerreb.unshift(0)

        # CALCULATE ZONES

        h_left_low  = (instrument.low[-h_left..].reduce (a,b) -> Math.min a, b)
        h_left_high = (instrument.high[-h_left..].reduce (a,b) -> Math.max a, b)        

        if low <= h_left_low
            newlow = 1
        else
            newlow = 0
        if high >= h_left_high
            newhigh = 1
        else
            newhigh = 0


        central_bar_low = instrument.low[instrument.low.length-(h_right + 1)]
        central_bar_high = instrument.high[instrument.high.length-(h_right + 1)]

        full_zone_low  = (instrument.low[-(h_left + h_right + 1)..].reduce (a,b) -> Math.min a, b)
        full_zone_high = (instrument.high[-(h_left + h_right + 1)..].reduce (a,b) -> Math.max a, b) 

        central_bar_is_highest = central_bar_high >= full_zone_high
        central_bar_is_lowest = central_bar_low <= full_zone_low

        if central_bar_high >= full_zone_high
            central_bar_is_highest = 1
        else
            central_bar_is_highest = 0
        if central_bar_low <= full_zone_low
            central_bar_is_lowest = 1
        else
            central_bar_is_lowest = 0

        # CALCULATE PROBABILITIES

        if central_bar_is_highest == 1
            @high_bar_tz_count++
        
        if central_bar_is_lowest == 1
            @low_bar_tz_count++

        total_tz = @high_bar_tz_count + @low_bar_tz_count

        percent_tz_high = (@high_bar_tz_count / sample_period) * 100
        percent_tz_low = (@low_bar_tz_count / sample_period) * 100

        percent_total_tz = (percent_tz_high + percent_tz_low)


        if newhigh == 1
            @high_bar_ptz_count++
        
        if newlow == 1
            @low_bar_ptz_count++

        total_ptz = @high_bar_ptz_count + @low_bar_ptz_count

        percent_ptz_high = (@high_bar_ptz_count / sample_period) * 100
        percent_ptz_low = (@low_bar_ptz_count / sample_period) * 100

        percent_total_ptz = (percent_ptz_high + percent_ptz_low)     
        
        if total_ptz != 0
            percent_ptz_resolved = (1 - (total_tz / total_ptz)) * 100
        else
            percent_ptz_resolved = 0


        # LAGUERRE

        @L0[0] = ((1 - g) * h_left_high) + (g * @L0[1])
        @L1[0] = (-g * @L0[0]) + @L0[1] + (g * @L1[1])
        @L2[0] = (-g * @L1[0]) + @L1[1] + (g * @L2[1])
        @L3[0] = (-g * @L2[0]) + @L2[1] + (g * @L3[1])

        @laguerre[0] = (@L0[0] + (2 * @L1[0]) + (2 * @L2[0]) + @L3[0]) / 6

        @L0b[0] = ((1 - g) * h_left_low) + (g * @L0b[1])
        @L1b[0] = (-g * @L0b[0]) + @L0b[1] + (g * @L1b[1])
        @L2b[0] = (-g * @L1b[0]) + @L1b[1] + (g * @L2b[1])
        @L3b[0] = (-g * @L2b[0]) + @L2b[1] + (g * @L3b[1])

        @laguerreb[0] = (@L0b[0] + (2 * @L1b[0]) + (2 * @L2b[0]) + @L3b[0]) / 6

        if (@laguerre[0]/@laguerre[1]) - 1 > 0
            buy instrument
        if (@laguerreb[0]/@laguerreb[1]) - 1 < 0
            sell instrument





        # TEMP DEBUG
        plot
            channellow: h_left_low
            channelhigh: h_left_high
            laguerrehigh: @laguerre[0]
            laguerrelow: @laguerreb[0]

        if newlow == 1
            plotMark
                "newlow": h_left_low

        if newhigh == 1
            plotMark
                "newhigh": h_left_high


        setPlotOptions
            newlow:
                color: 'rgba(255,0,0,0.1)'
            newhigh:
                color: 'rgba(0,255,0,0.1)'
            channellow:
                color: 'rgba(0,0,0,0.2)'
            channelhigh:
                color: 'rgba(0,0,0,0.2)'
            laguerrehigh:
                secondary: true
            laguerrelow:
                secondary: true


        # RETURN DATA
        result =
            close: close

        return result 
      

init: (context)->
    
    context.transient = new TRANSIENT()

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
    transient = context.transient.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc