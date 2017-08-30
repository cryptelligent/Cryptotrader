###
Extracting the Trend
by aspiramedia (converted from HPotter at https://www.tradingview.com/v/kplf2fRD/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class TREND
    constructor: (@period) ->
        @count = 0
        @xBandpassFilter = []
        @pos = []

        # INITIALIZE ARRAYS
        for [@xBandpassFilter.length..40]
            @xBandpassFilter.push 0
        for [@pos.length..5]
            @pos.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        Delta = 0.5

        # INCREASE DATA COUNT
        @count++

        # REMOVE OLD DATA
        @xBandpassFilter.pop()
        @pos.pop()

        # ADD NEW DATA
        @xBandpassFilter.unshift(0)
        @pos.unshift(0)

        # CALCULATE
        beta = Math.cos(3.1415 * (360 / @period) / 180)
        gamma = 1 / Math.cos(3.1415 * (720 * Delta / @period) / 180)
        alpha = gamma - Math.sqrt(gamma * gamma - 1)

        @xBandpassFilter[0] = 0.5 * (1 - alpha) * (close - instrument.close[instrument.close.length-2]) + beta * (1 + alpha) * @xBandpassFilter[1] - alpha * @xBandpassFilter[2]
        
        xmean = talib.SMA
            inReal: @xBandpassFilter
            startIdx: 0
            endIdx: @xBandpassFilter.length-1
            optInTimePeriod: (@period*2)
        xmean = xmean[xmean.length-1]
        
        # TEMP DEBUG
       



        # RETURN DATA
        result =
            trend: xmean

        return result 
      

init: (context)->
    
    context.trend = new TREND(20) # Period

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
    trend = context.trend.calculate(instrument)
    trend = trend.trend

    # TRADING

    
    # PLOTTING / DEBUG
    plot
        trend: trend
        zero: 0
    setPlotOptions
        trend:
            secondary: true
        zero:
            secondary: true

    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc