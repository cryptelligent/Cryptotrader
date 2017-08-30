###
Guppy EMA
by aspiramedia - Originally by Chris Moody (https://www.tradingview.com/v/3rxOtFe0/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class GUPPY
    constructor: () ->

        @count = 0
        @colFinalL = []
        @colFinalS = []



        ## INITIALIZE ARRAYS
        for [@colFinalL.length..5]
            @colFinalL.push 0
        for [@colFinalS.length..5]
            @colFinalS.push 0

        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # REMOVE OLD DATA
        @colFinalL.pop()
        @colFinalS.pop()

        # ADD NEW DATA
        @colFinalL.unshift(0)
        @colFinalS.unshift(0)

        # CALCULATE
        
        #### Fast EMAs
        ema1    = instrument.ema(3)
        ema2    = instrument.ema(5)
        ema3    = instrument.ema(8)
        ema4    = instrument.ema(10)
        ema5    = instrument.ema(12)
        ema6    = instrument.ema(15)

        #### Slow EMAs
        ema7    = instrument.ema(30)
        ema8    = instrument.ema(35)
        ema9    = instrument.ema(40)
        ema10   = instrument.ema(45)
        ema11   = instrument.ema(50)
        ema12   = instrument.ema(60)

        #### Logic
        colfastL = (ema1 > ema2 and ema2 > ema3 and ema3 > ema4 and ema4 > ema5 and ema5 > ema6)
        colfastS = (ema1 < ema2 and ema2 < ema3 and ema3 < ema4 and ema4 < ema5 and ema5 < ema6)

        colslowL = (ema7 > ema8 and ema8 > ema9 and ema9 > ema10 and ema10 > ema11 and ema11 > ema12)
        colslowS = (ema7 < ema8 and ema8 < ema9 and ema9 < ema10 and ema10 < ema11 and ema11 < ema12)

        #### Fast EMA Final
        if colfastL is true and colslowL is true
            @colFinalL[0] = 1
        else if colfastS is true and colslowS is true
            @colFinalL[0] = -1
        else
            @colFinalL[0] = 0


        #### Slow EMA Final
        if colslowL is true
            @colFinalS[0] = 1
        else if colslowS is true
            @colFinalS[0] = -1
        else
            @colFinalS[0] = 0

        #### Extras
        fastavg = (ema1 + ema2 + ema3 + ema4 + ema5 + ema6) / 6
        slowavg = (ema7 + ema8 + ema9 + ema10 + ema11 + ema12) / 6


        
        
        # PLOT
        plot
            colFinalL: @colFinalL[0]
            ema1: ema1
            ema2: ema2
            ema3: ema3
            ema4: ema4
            ema5: ema5
            ema6: ema6
            colFinalS: @colFinalS[0]
            ema7: ema7
            ema8: ema8
            ema9: ema9
            ema10: ema10
            ema11: ema11
            ema12: ema12

        # RETURN DATA
        result =
            colFinalS: @colFinalS
            colFinalL: @colFinalL

        return result 
      

init: (context)->
    
    context.guppy = new GUPPY()

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
    guppy = context.guppy.calculate(instrument)
    colFinalS = guppy.colFinalS
    colFinalL = guppy.colFinalL

    # TRADING
    ###
    if colFinalS[0] == -1
        if colFinalL[0] == 0 and colFinalL[1] == -1
            buy instrument
        if colFinalL[0] == -1 and colFinalL[1] == 0
            sell instrument
    if colFinalS[0] == 1
        if colFinalL[0] == 1 and colFinalL[1] == 0
            buy instrument
        if colFinalL[0] == 0 and colFinalL[1] == 1
            sell instrument
    ###

        

    
    # PLOTTING / DEBUG
    setPlotOptions
        ema1:
            color: 'rgba(0,0,255,0.5)'
        ema2:
            color: 'rgba(0,0,255,0.6)'
        ema3:
            color: 'rgba(0,0,255,0.7)'
        ema4:
            color: 'rgba(0,0,255,0.8)'
        ema5:
            color: 'rgba(0,0,255,0.9)'
        ema6:
            color: 'rgba(0,0,255,1)'
        colFinalL:
            secondary: true
            color: 'rgba(0,0,255,1)'
        ema7:
            color: 'rgba(255,0,0,0.5)'
        ema8:
            color: 'rgba(255,0,0,0.6)'
        ema9:
            color: 'rgba(255,0,0,0.7)'
        ema10:
            color: 'rgba(255,0,0,0.8)'
        ema11:
            color: 'rgba(255,0,0,0.9)'
        ema12:
            color: 'rgba(255,0,0,1)'
        colFinalS:
            secondary: true
            color: 'rgba(255,0,0,1)'



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc