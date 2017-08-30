###
CCT Bollinger Band Oscillator (CCTBO) with Inverse Fisher
aspiramedia (https://cryptotrader.org/aspiramedia)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74

Originally by lazybear: https://www.tradingview.com/v/iA4XGCJW/

https://cryptotrader.org/backtests/NrXhjLDHje8jTh3jd
###

class CCTBO
    constructor: (@period) ->

        @count = 0
        @IFish = []

        # INITIALIZE ARRAYS
        for [@IFish.length..25]
            @IFish.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # REMOVE OLD DATA
        @IFish.pop()

        # ADD NEW DATA
        @IFish.unshift(0)

        # CALCULATE
        close = instrument.close[instrument.close.length - 1]

        SMA = talib.SMA
          inReal: instrument.close
          startIdx: 0
          endIdx: instrument.close.length - 1
          optInTimePeriod: @period
        sma = _.last(SMA)

        STDDEV = talib.STDDEV
          inReal: instrument.close
          startIdx: 0
          endIdx: instrument.close.length - 1
          optInTimePeriod: @period
          optInNbDev: 1
        stddev = _.last(STDDEV)

        cctbbo = 100 * (close + 2 * stddev - sma) / (4 * stddev)

        @IFish[0] = (Math.exp(2*cctbbo) - 1) / (Math.exp(2*cctbbo) + 1)

        # TEMP DEBUG


        # RETURN DATA
        result =
            IFish: @IFish

        return result 
      

init: (context)->
    
    context.cctbo = new CCTBO(21)

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
    cctbo = context.cctbo.calculate(instrument)
    IFish = cctbo.IFish


    
    # TRADING
    if IFish[0] > -0.9 && IFish[1] > -0.9 && IFish[2] < -0.9 && IFish[3] < -0.9
      plotMark
        "buy": price


    
    # PLOTTING / DEBUG
    plot
      ifish: IFish[0]
    setPlotOptions
      ifish:
        secondary: true
      buy:
        color: 'green'



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc
