###
COWABUNGA STRATEGY
by aspiramedia (based on http://www.babypips.com/blogs/pip-my-system/so_youve_finished_the_school_o.html)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class COWABUNGA
    constructor: () ->

        @count = 0
        @entry = []
        @close = []
        @K = []
        @D = []
        @MACDH = []

        # INITIALIZE ARRAYS
        for [@entry.length..5]
            @entry.push 0
        for [@close.length..100]
            @close.push 0
        for [@K.length..5]
            @K.push 0
        for [@D.length..5]
            @D.push 0
        for [@MACDH.length..5]
            @MACDH.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # REMOVE OLD DATA
        @entry.pop()
        @close.pop()
        @K.pop()
        @D.pop()
        @MACDH.pop()

        # ADD NEW DATA
        @entry.unshift(0)
        @close.unshift(0)
        @K.unshift(0)
        @D.unshift(0)
        @MACDH.unshift(0)


        # CALCULATE
        @close[0] = close
        lowest = (@close.reduce (a,b) -> Math.min a, b)

        trendshort = instrument.ema(80)
        trendlong = instrument.ema(160)

        if trendshort > trendlong
            trendup = true
            plotMark
                "trendup": 0
        else
            trendup = false
            plotMark
                "trenddown": 0

        emashort = instrument.ema(5)
        emalong = instrument.ema(10)

        rsi = talib.RSI
          inReal: instrument.close
          startIdx: 0
          endIdx: instrument.close.length-1
          optInTimePeriod: 9
        rsi = _.last(rsi) 

        macdcalc = talib.MACD
          inReal: instrument.close
          startIdx: 0
          endIdx: instrument.close.length - 1
          optInFastPeriod: 12
          optInSlowPeriod: 26
          optInSignalPeriod: 9
        macd = _.last(macdcalc.outMACD)
        signal = _.last(macdcalc.outMACDSignal)
        @MACDH[0] = _.last(macdcalc.outMACDHist)

        stochastic = talib.STOCH
          high: instrument.high
          low: instrument.low
          close: instrument.close
          startIdx: 0
          endIdx: instrument.high.length - 1
          optInFastK_Period: 10
          optInSlowK_Period: 3
          optInSlowK_MAType: 1 
          optInSlowD_Period: 3
          optInSlowD_MAType: 1
        @K[0] = _.last(stochastic.outSlowK)
        @D[0] = _.last(stochastic.outSlowD)
        
        
        if trendshort > trendlong
            if emashort > emalong
                if rsi > 50
                    if @K[0] > @K[1] and @D[0] > @D[1] and @K[0] < 80 and @D[0] < 80
                        if (@MACDH[0] > 0 and @MACDH[1] < 0) or (@MACDH[0] < 0 and @MACDH[0] > @MACDH[1])
                            @entry[0] = true
        else 
            @entry[0] = false


        
        
        # TEMP DEBUG
        plot
        setPlotOptions
            trendup: 
                secondary: true
                color: 'green'
            trenddown:
                secondary: true
                color: 'red'
            entry:
                color: 'black'
        

        # RETURN DATA
        result =
            entry: @entry[0]
            lowest: lowest

        return result 
      

init: (context)->
    
    context.cowabunga = new COWABUNGA()

    # FOR FINALISE STATS
    context.balance_curr = 0
    context.balance_btc = 0
    context.price = 0


handle: (context, data, storage)->

    instrument = data.instruments[0]
    price = instrument.close[instrument.close.length - 1]
    storage.stop ?= 0
    storage.exit ?= 0
    storage.TICK ?= 0

    # FOR FINALISE STATS
    context.price = instrument.close[instrument.close.length - 1]
    context.balance_curr = portfolio.positions[instrument.curr()].amount
    context.balance_btc = portfolio.positions[instrument.asset()].amount

    # CALLING INDICATORS
    cowabunga = context.cowabunga.calculate(instrument)
    
    entry = cowabunga.entry
    lowest = cowabunga.lowest

    # TRADING
    if entry == true
        if buy instrument
            storage.stop = lowest
            storage.exit = price + (price - lowest)

    if price < storage.stop
        sell instrument

    if price > storage.exit
        sell instrument


    
    # PLOTTING / DEBUG
    plot

    # STATS CODE
    context.price = instrument.close[instrument.close.length - 1]
    context.balance_curr = portfolio.positions[instrument.curr()].amount
    context.balance_btc = portfolio.positions[instrument.asset()].amount

    if storage.TICK == 0 
        storage.balance_curr_start = portfolio.positions[instrument.curr()].amount
        storage.balance_btc_start = portfolio.positions[instrument.asset()].amount
        storage.price_start = price

    starting_btc_equiv  = storage.balance_btc_start + storage.balance_curr_start / storage.price_start
    current_btc_equiv   = context.balance_btc + context.balance_curr / price
    starting_fiat_equiv = storage.balance_curr_start + storage.balance_btc_start * storage.price_start
    current_fiat_equiv  = context.balance_curr + context.balance_btc * price
    efficiency          = Math.round((current_btc_equiv / starting_btc_equiv) * 1000) / 1000
    efficiency_percent  = Math.round((((current_btc_equiv / starting_btc_equiv) - 1) * 100) * 10) / 10
    market_efficiency   = Math.round((((context.price / storage.price_start) - 1) * 100) * 10) / 10
    bot_efficiency      = Math.round((((current_fiat_equiv / starting_fiat_equiv) - 1) * 100) * 10) / 10

    storage.TICK++

    warn "### Day " + storage.TICK + " Log"
    debug "Current Fiat: " + Math.round(context.balance_curr*100)/100 + " | Current BTC: " +  Math.round(context.balance_btc*100)/100
    debug "Starting Fiat: " + Math.round(storage.balance_curr_start*100)/100 + " | Starting BTC: " +  Math.round(storage.balance_btc_start*100)/100
    debug "Current Portfolio Worth: " + Math.round(((context.balance_btc * price) + context.balance_curr)*100)/100
    debug "Starting Portfolio Worth: " + Math.round(((storage.balance_btc_start * storage.price_start) + storage.balance_curr_start)*100)/100
    debug "Efficiency of Buy and Hold: " + market_efficiency + "%"
    debug "Efficiency of Bot: " + bot_efficiency + "%"
    debug "Efficiency Vs Buy and Hold: " + efficiency + " which equals " + efficiency_percent + "%"
    warn "###"



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc