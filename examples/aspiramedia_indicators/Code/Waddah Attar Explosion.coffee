###
Waddah Attar Explosion (Originally by LazyBear: https://www.tradingview.com/v/iu3kKWDI/)
by aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class EXPLOSION
    constructor: () ->

        @count = 0
        @macd = []
        @trendUp = []
        @trendDown = []
        


        # INITIALIZE ARRAYS
        for [@macd.length..5]
            @macd.push 0
        for [@trendUp.length..5]
            @trendUp.push 0
        for [@trendDown.length..5]
            @trendDown.push 0
        for [@e1.length..5]
            @e1.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        sensitivity     = 150
        fastLength      = 20
        slowLength      = 40
        channelLength   = 20
        mult            = 2
        deadZone        = 20

        # REMOVE OLD DATA
        @macd.pop()
        @trendUp.pop()
        @trendDown.pop()
        @e1.pop()

        # ADD NEW DATA
        @macd.unshift(0)
        @trendUp.unshift(0)
        @trendDown.unshift(0)
        @e1.unshift(0)

        @count++

        # CALCULATE

        macd = talib.MACD
            inReal: instrument.close
            startIdx: 0
            endIdx: instrument.close.length - 1
            optInFastPeriod: fastLength
            optInSlowPeriod: slowLength
            optInSignalPeriod: 10   # Doesn't matter - not being used
        @macd[0] = _.last(macd.outMACD)

        t1 = (@macd[0] - @macd[1]) * sensitivity
        t2 = @macd[2] - @macd[3] * sensitivity

        bbands = talib.BBANDS
          inReal: instrument.close
          startIdx: 0
          endIdx: instrument.close.length - 1
          optInTimePeriod: channelLength
          optInNbDevUp: 2
          optInNbDevDn: 2
          optInMAType: 1
        bbandsupper = _.last(bbands.outRealUpperBand)
        bbandslower = _.last(bbands.outRealLowerBand)

        @e1[0] = bbandsupper - bbandslower

        if @count > 1
            if t1 >= 0
                @trendUp[0] = t1
                if @trendUp[0] > @trendUp[1]
                    plotMark
                        "trendUphigh": @trendUp[0]
                else
                    plotMark
                        "trendUplow": @trendUp[0]
            else
                @trendUp[0] = 0

            if t1 < 0
                @trendDown[0] = -1 * t1
                if @trendDown[0] > @trendDown[1]
                    plotMark
                        "trendDownhigh": @trendDown[0]
                else
                    plotMark
                        "trendDownlow": @trendDown[0]
            else
                @trendDown[0] = 0
        else
            @trendUp[0] = @trendDown[0] = 0

        # TRADE

        if @trendUp[0] > @trendUp[1]
            if @trendUp[0] > @e1[0]
                if @e1[0] > @e1[1]
                    if @trendUp[0] > deadZone && @e1[0] > deadZone
                        buy instrument

        if @trendUp[0] < @e1[0]
            sell instrument



       
        
        
        # TEMP DEBUG
        plot
            deadZone: deadZone
            explosion: e1
            trendUp: @trendUp[0]
            trendDown: @trendDown[0]
        setPlotOptions
            deadZone:
                secondary: true
                color: 'blue'
            explosion:
                secondary: true
                color: '#A0522D'
                lineWidth: 3
            trendUp:
                secondary: true
                color: 'green'
            trendUphigh:
                secondary: true
                color: 'green'
            trendUplow:
                secondary: true
                color: 'lime'
            trendDown:
                secondary: true
                color: 'red'
            trendDownhigh:
                secondary: true
                color: 'red'
            trendDownlow:
                secondary: true
                color: 'orange'


        

        # RETURN DATA
        result =
            close: close

        return result 
      

init: (context)->
    
    context.explosion = new EXPLOSION()

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
    explosion = context.explosion.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc