###
Zero Lag Indicator
by aspiramedia (converted from this: http://www.mesasoftware.com/Papers/ZERO%20LAG.pdf)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74

https://cryptotrader.org/backtests/MBYwE9ArBrBSnZs78
###

class ZERO
    constructor: () ->

        @count = 0
        @EMA = []
        @EC = []

        # INITIALIZE ARRAYS
        for [@EMA.length..5]
            @EMA.push 0
        for [@EC.length..5]
            @EC.push 0
        
    calculate: (instrument) ->        

        Close = instrument.close[instrument.close.length-1]
        Length = 20
        GainLimit = 50
        Thresh = 1

        # REMOVE OLD DATA
        @EMA.pop()
        @EC.pop()

        # ADD NEW DATA
        @EMA.unshift(0)
        @EC.unshift(0)
        
        # CALCULATE
        alpha = 2 / (Length + 1)
        @EMA[0] = alpha * Close + (1 - alpha) * @EMA[1]
        LeastError = 1000000

        for Value1 in [-GainLimit..GainLimit]
            Gain = Value1 / 10
            @EC[0] = alpha * (@EMA[0] + Gain * (Close - @EC[1])) + (1 - alpha) * @EC[1]
            Error = Close - @EC[0]
            if Math.abs(Error) < LeastError
                LeastError = Math.abs(Error)
                BestGain = Gain

        @EC[0] = alpha * (@EMA[0] + BestGain * (Close - @EC[1])) + (1 - alpha) * @EC[1]

        if (@EC[0] > @EMA[0]) and ((100 * LeastError) / Close) > Thresh
            buy instrument

        if (@EC[0] < @EMA[0]) and ((100 * LeastError) / Close) > Thresh
            sell instrument



        # TEMP DEBUG
        plot
            EMA: @EMA[0]
            EC: @EC[0]
            Error: ((100 * LeastError) / Close)
        setPlotOptions
            Error:
              secondary: true

        

        # RETURN DATA
        result =
            Close: Close

        return result 
      

init: (context)->
    
    context.zero = new ZERO()

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
    zero = context.zero.calculate(instrument)

    # TRADING
    
    
    # PLOTTING / DEBUG
    

    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc