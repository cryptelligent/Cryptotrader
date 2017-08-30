###
Roofing Filter
by aspiramedia (converted from this: http://www.mesasoftware.com/Papers/SpectralDilation.pdf)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class ROOFING
    constructor: () ->

        @count = 0
        @HP = []
        @Filt = []

        # INITIALIZE ARRAYS
        for [@HP.length..5]
            @HP.push 0
        for [@Filt.length..5]
            @Filt.push 0

    calculate: (instrument) ->        

        close       = instrument.close[instrument.close.length-1]
        close1      = instrument.close[instrument.close.length-2]
        close2      = instrument.close[instrument.close.length-3]
        HPPeriod    = 10

        # REMOVE OLD DATA
        @HP.pop()
        @Filt.pop()

        # ADD NEW DATA
        @HP.unshift(0)
        @Filt.unshift(0)

        # CALCULATE
        alpha1 = (Math.cos(0.707 * 3.14159 / HPPeriod) + Math.sin(0.707 * 3.14159 / 48) - 1) / Math.cos(0.707 * 3.14159 / 48)

        @HP[0] = ((1 - alpha1 / 2)*(1 - alpha1 / 2)*(close - 2*close1 + close2)) + (2*(1 - alpha1)*@HP[1]) - ((1 - alpha1)*(1 - alpha1)*@HP[2])

        a1 = Math.exp(-1.414*3.14159 / 10)
        b1 = 2*a1*Math.cos(1.414*3.14159 / 10)
        c2 = b1
        c3 = -a1*a1
        c1 = 1 - c2 - c3
        @Filt[0] = c1*(@HP[0] + @HP[1]) / 2 + c2*@Filt[1] + c3*@Filt[2]

        
        
        # TEMP DEBUG
        plot
            Filt: @Filt[0]
        setPlotOptions
            Filt:
                secondary: true

        # TRADE

        if @Filt[0] > @Filt[1]
            buy instrument
        if @Filt[0] < @Filt[1]
            sell instrument

        # RETURN DATA
        result =
            close: close

        return result 
      

init: (context)->
    
    context.roofing = new ROOFING()

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
    roofing = context.roofing.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc