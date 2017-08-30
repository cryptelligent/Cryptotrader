###
Transient Zones
by aspiramedia (converted from this by Jurij: https://www.tradingview.com/v/NBcEvyej/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

###
h_left = input(title="H left", type=integer, defval=10)
h_right = input(title="H right", type=integer, defval=10)
sample_period = input(title="Sample bars for % TZ", type=integer, defval=5000)
show_ptz = input(title="Show PTZ", type=bool, defval=true)
show_channel = input(title="Show channel", type=bool, defval=true)

//barCount = nz(barCount[1]) + 1
//check history and realtime PTZ
h_left_low = lowest(h_left)
h_left_high = highest(h_left)
newlow = low <= h_left_low
newhigh = high >= h_left_high
plotshape(newlow and show_ptz, style=shape.triangledown, location=location.belowbar, color=red)
plotshape(newhigh and show_ptz, style=shape.triangleup, location=location.abovebar, color=green)
channel_high = plot(show_channel ? h_left_low : 0, color=silver)
channel_low = plot (show_channel ? h_left_high : 0, color=silver)

//check true TZ back in history
central_bar_low = low[h_right + 1]
central_bar_high = high[h_right + 1]
full_zone_low = lowest(h_left + h_right + 1)
full_zone_high = highest(h_left + h_right + 1)
central_bar_is_highest = central_bar_high >= full_zone_high
central_bar_is_lowest = central_bar_low <= full_zone_low
plotarrow(central_bar_is_highest ? -1 : 0, offset=-h_right-1)
plotarrow(central_bar_is_lowest ? 1 : 0, offset=-h_right-1)
###

class TRANSIENT
    constructor: () ->

        @count = 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        h_left = 10
        h_right = 10

        # CALCULATE

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
        
        
        # TEMP DEBUG
        plot
            channellow: h_left_low
            channelhigh: h_left_high

        if newlow == 1
            plotMark
                "newlow": h_left_low

        if newhigh == 1
            plotMark
                "newhigh": h_left_high

        if central_bar_is_highest == 1
            plotMark
                "centralbarhighest": close # SUPPOSED TO HAVE AN OFFSET OF H_RIGHT-1

        if central_bar_is_lowest == 1
            plotMark
                "centralbarlowest": close # SUPPOSED TO HAVE AN OFFSET OF H_RIGHT-1

        setPlotOptions
            newlow:
                color: 'rgba(255,0,0,0.2)'
            newhigh:
                color: 'rgba(0,255,0,0.2)'
            channellow:
                color: 'rgba(0,0,0,0.2)'
            channelhigh:
                color: 'rgba(0,0,0,0.2)'
            centralbarhighest:
                color: 'rgba(255,0,0,1)'
            centralbarlowest:
                color: 'rgba(0,255,0,1)'

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