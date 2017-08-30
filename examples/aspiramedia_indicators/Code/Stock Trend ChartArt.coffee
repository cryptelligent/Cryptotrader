###
STOCK TREND 
by aspiramedia (Based on this script by Chart Art: https://www.tradingview.com/script/rZASyOJS-Stock-Market-Trend-Analysis-Trading-System-101-by-ChartArt/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class STOCKTREND
    constructor: () ->

        @count = 0
        
    calculate: (instrument) ->        

        close       = instrument.close[instrument.close.length-1]
        closeprev   = instrument.close[instrument.close.length-2]
        high        = instrument.high[instrument.high.length-1]
        highprev    = instrument.high[instrument.high.length-2]
        low         = instrument.low[instrument.low.length-1]
        lowprev     = instrument.low[instrument.low.length-2]

        hl2         = (high + low) / 2
        hl2prev     = (highprev + lowprev) / 2

        pivot       = (high + low + close) / 3.0 
        pivotprev   = (highprev + lowprev + closeprev) / 3.0 

        # REMOVE OLD DATA


        # ADD NEW DATA
        @output.unshift(0)

        # CALCULATE
        @output[0] = close

        

        if close > closeprev and hl2 > hl2prev and close > pivot
            TrendingUp = true
        else
            TrendingUp = false

        if close < closeprev and hl2 < hl2prev and close < pivot 
            TrendingDown = true
        else
            TrendingDown = false


        if closeprev < pivotprev && close > pivot && TrendingUp == true
            buy instrument
        if closeprev > pivotprev && close < pivot && TrendingDown == true
            sell instrument


        

        

        # RETURN DATA
        result =
            close: close

        return result 
      

init: (context)->
    
    context.stocktrend = new STOCKTREND()

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
    stocktrend = context.stocktrend.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc