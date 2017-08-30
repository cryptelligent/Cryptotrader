###
Random
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class RANDOM
    constructor: (@g) ->

        @count = 0
        @close = []
        @open = []
        @high = []
        @low = []
        @L0 = []
        @L1 = []
        @L2 = []
        @L3 = []
        @laguerre = []

        # INITIALIZE ARRAYS
        for [@close.length..250]
            @close.push 0
        for [@open.length..250]
            @open.push 0
        for [@high.length..250]
            @high.push 0
        for [@low.length..250]
            @low.push 0
        for [@L0.length..5]
            @L0.push 0
        for [@L1.length..5]
            @L1.push 0
        for [@L2.length..5]
            @L2.push 0
        for [@L3.length..5]
            @L3.push 0
        for [@laguerre.length..250]
            @laguerre.push 0
        
    calculate: (instrument) ->        

        g = @g

        # REMOVE OLD DATA
        @close.pop()
        @open.pop()
        @high.pop()
        @low.pop()
        @L0.pop()
        @L1.pop()
        @L2.pop()
        @L3.pop()
        @laguerre.pop()

        # ADD NEW DATA
        @close.unshift(0)
        @open.unshift(0)
        @high.unshift(0)
        @low.unshift(0)
        @L0.unshift(0)
        @L1.unshift(0)
        @L2.unshift(0)
        @L3.unshift(0)
        @laguerre.unshift(0)

        # CALCULATE
        max = 10
        min = 1
        variance = Math.floor(Math.random() * (max - min)) + min
        variancehigh = (Math.random() * Math.random() / 50) + 1
        variancelow = (Math.random() * Math.random() / 50) + 1
        

        if Math.random() < 0.5
            variance = -variance 

        
        if @count == 0
            @close[0] = 1000
            @open[0] = 1000
            @high[0] = 1000
            @low[0] = 1000

        else
            @close[0] = @close[1] + variance
            @open[0] = @close[1]
            
            if @open[0] > @close[0]
                @high[0] = @open[0] * variancehigh
                @low[0] = @close[0] / variancelow
            else
                @high[0] = @close[0] * variancehigh
                @low[0] = @open[0] / variancelow

        # Laguerre - Of Close

        @L0[0] = ((1 - g) * @close[0]) + (g * @L0[1])
        @L1[0] = (-g * @L0[0]) + @L0[1] + (g * @L1[1])
        @L2[0] = (-g * @L1[0]) + @L1[1] + (g * @L2[1])
        @L3[0] = (-g * @L2[0]) + @L2[1] + (g * @L3[1])

        if @count < 15
            @laguerre[0] = 1000
        else
            @laguerre[0] = (@L0[0] + (2 * @L1[0]) + (2 * @L2[0]) + @L3[0]) / 6 


        @count++
        
        # TEMP DEBUG    

        # RETURN DATA
        result =
            close: @close
            open: @open
            high: @high
            low: @low
            laguerre: @laguerre

        return result 
      

init: (context)->
    
    context.random = new RANDOM(0.25)

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
    random = context.random.calculate(instrument)
    close = random.close
    open = random.open
    high = random.high
    low = random.low
    laguerre = random.laguerre
    
    # EXAMPLE
    EMA = talib.EMA
      inReal: close
      startIdx: 0
      endIdx: close.length - 1
      optInTimePeriod: 10
    ema = _.last(EMA)


    if price > ema * 1.012
        buy instrument
    if price < ema * 0.988
        sell instrument

    
    # PLOTTING / DEBUG
    plot
       price: price
       close: close[0]
       open: open[0]
       high: high[0]
       low: low[0]
       laguerre: laguerre[0]
       ema: ema
    setPlotOptions
        price:
            color: '#fffdf6'
            lineWidth: 500
        close:
            secondary: true
            color: 'rgba(255,0,0,0.25)'
        open:
            secondary: true
            color: 'rgba(0,0,0,0.1)'
        high:
            secondary: true
            color: 'rgba(0,255,0,0.1)'
        low:
            secondary: true
            color: 'rgba(0,0,255,0.1)'
        laguerre:
            secondary: true
            color: 'rgba(255,0,0,1)'
        ema:
            secondary: true



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc 

            
            
            
          