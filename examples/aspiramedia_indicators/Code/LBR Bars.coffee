###
LBR Bars
by aspiramedia (Originally by LazyBear at TradingView: https://www.tradingview.com/v/PWOIfQ04/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class LBR
    constructor: () ->

        @count = 0
        @atr = []

        # INITIALIZE ARRAYS

        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        
        lbperiod = 16
        atrperiod = 9
        mult = 2.5

        # REMOVE OLD DATA


        # ADD NEW DATA


        # CALCULATE
        atr = talib.ATR
            high: instrument.high
            low: instrument.low
            close: instrument.close
            startIdx: 0
            endIdx: instrument.high.length-1
            optInTimePeriod: atrperiod
        atr = atr[atr.length-1]

        for [@atr.length..atrperiod]
            @atr.push atr
        if @atr.length > atrperiod
            @atr.shift() 

        atrsma = talib.SMA
          inReal: @atr
          startIdx: 0
          endIdx: @atr.length - 1
          optInTimePeriod: atrperiod
        atrsma = atrsma[atrsma.length-1]

        aatr = mult * atrsma

        b1 = (instrument.low[-lbperiod..].reduce (a,b) -> Math.min a, b) + aatr
        b2 = (instrument.high[-lbperiod..].reduce (a,b) -> Math.max a, b) - aatr

        uvf = (close > b1 and close > b2)
        lvf = (close < b1 and close < b2)

        if uvf
            plotMark
                "LBR": close
        if lvf
            plotMark
                "LBRDOWN": close
        

        
        
        
        # TEMP DEBUG

        

        # RETURN DATA
        result =
            uvf: uvf
            lvf: lvf

        return result 
      

init: (context)->
    
    context.lbr = new LBR()

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
    lbr = context.lbr.calculate(instrument)
    uvf = lbr.uvf
    lvf = lbr.lvf

    if uvf == true
        buy instrument
    if uvf == false
        sell instrument
    
    # TRADING

    
    # PLOTTING / DEBUG
    setPlotOptions
        LBR:
            color: 'green'
        LBRDOWN:
            color: 'red'



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc