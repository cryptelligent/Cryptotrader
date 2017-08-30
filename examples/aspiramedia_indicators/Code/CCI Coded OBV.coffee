###
CCI Coded OBV
by aspiramedia (converted from this by LazyBear: https://www.tradingview.com/v/D8ld7sgR/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74

https://cryptotrader.org/backtests/MBYwE9ArBrBSnZs78
###

class CCIOBV
    constructor: () ->

        @count  = 0
        @o      = []

        # INITIALIZE ARRAYS
        for [@o.length..50]
            @o.push 0
        
    calculate: (instrument) ->        

        close       = instrument.close[instrument.close.length-1]
        closeprev   = instrument.close[instrument.close.length-2]
        high        = instrument.high[instrument.high.length-1]
        low         = instrument.low[instrument.low.length-1]
        volume      = instrument.volumes[instrument.volumes.length-1]
        length      = 20
        threshold   = 0
        lengthema   = 13

         # REMOVE OLD DATA
        @o.pop()

        # ADD NEW DATA
        @o.unshift(0)

        # CALCULATE
        if (close - closeprev > 0)
            o = volume
        else if (close - closeprev < 0)
            o = -volume
        else
            o = 0   

        @o[0] = @o[1] + o

        c = talib.CCI
            high: instrument.high
            low: instrument.low
            close: instrument.close
            startIdx: 0
            endIdx: instrument.high.length-1
            optInTimePeriod: length
        c = c[c.length-1]

        if c > threshold
            buy instrument
            plotMark
                "buy": @o[0]
        else
            sell instrument
            plotMark
                "sell": @o[0]

        ema = talib.EMA
            inReal: @o
            startIdx: 0
            endIdx: @o.length-1
            optInTimePeriod: lengthema
        ema = ema[ema.length-1]


        plot
            ema: ema
        setPlotOptions
            buy: 
                color: 'green'
                secondary: true
            sell:
                color: 'red'
                secondary: true



        # TEMP DEBUG
        

        

        # RETURN DATA
        result =
            close: close

        return result 
      

init: (context)->
    
    context.cciobv = new CCIOBV()

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
    cciobv = context.cciobv.calculate(instrument)

    # TRADING
    
    
    # PLOTTING / DEBUG
    

    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc