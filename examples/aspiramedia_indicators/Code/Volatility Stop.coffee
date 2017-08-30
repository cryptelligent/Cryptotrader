###
Volatility Stop
by aspiramedia (Originally by admin on Tradingview: https://www.tradingview.com/v/oRK5JwIm/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class VOLSTOP
    constructor: (@length) ->

        @count = 0
        @max_ = []
        @min_ = []
        @is_uptrend = []
        @vstop = []

        # INITIALIZE ARRAYS
        for [@max_.length..5]
            @max_.push 0
        for [@min_.length..5]
            @min_.push 0
        for [@is_uptrend.length..5]
            @is_uptrend.push 0
        for [@vstop.length..100]
            @vstop.push 0

    calculate: (instrument) ->        

        length = @length
        mult = 2
        close = instrument.close[instrument.close.length-1]

        # REMOVE OLD DATA
        @max_.pop()
        @min_.pop()
        @is_uptrend.pop()
        @vstop.pop()

        # ADD NEW DATA
        @max_.unshift(0)
        @min_.unshift(0)
        @is_uptrend.unshift(0)
        @vstop.unshift(0)

        # CALCULATE
        atr_ = talib.ATR
            high: instrument.high
            low: instrument.low
            close: instrument.close
            startIdx: 0
            endIdx: instrument.high.length-1
            optInTimePeriod: length
        atr_ = atr_[atr_.length-1]

        if @max_[1] > close
            max1 = @max_[1]
        else
            max1 = close

        if @min_[1] < close
            min1 = @min_[1]
        else
            min1 = close

        is_uptrend_prev = @is_uptrend[1]

        if is_uptrend_prev == true
            stop = max1 - mult * atr_
        else
            stop = min1 + mult * atr_

        vstop_prev = @vstop[1]

        if is_uptrend_prev == true
            if vstop_prev > stop
                vstop1 = vstop_prev
            else
                vstop1 = stop
        
        if is_uptrend_prev != true
            if vstop_prev < stop
                vstop1 = vstop_prev
            else
                vstop1 = stop

        if close - vstop1 >= 0
            @is_uptrend[0] = true
        else
            @is_uptrend[0] = false

        if @is_uptrend[0] != is_uptrend_prev
            is_trend_changed = true


        if is_trend_changed == true
            @max_[0] = close
            @min_[0] = close
        else
            @max_[0] = max1  
            @min_[0] = min1

        if is_trend_changed == true
            if @is_uptrend[0] == true
                @vstop[0] = @max_[0] - mult * atr_
            else 
                @vstop[0] = @min_[0] + mult * atr_
        else
            @vstop[0] = vstop1


        if @is_uptrend[0] == true
            plotMark
                "vstop_up": @vstop[0]
            buy instrument
        else
            plotMark
                "vstop_down": @vstop[0]
            sell instrument
        


        
        # TEMP DEBUG

        

        # RETURN DATA
        result =
            vstop: @vstop
            uptrend: @is_uptrend

        return result 
      

init: (context)->
    
    context.volstop = new VOLSTOP(20)

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
    volstop = context.volstop.calculate(instrument)
    vstop = volstop.vstop
    uptrend = volstop.uptrend


    
    # TRADING

    
    # PLOTTING / DEBUG
    plot
        vstop: vstop[0]
    setPlotOptions
        vstop_up:
            color: 'green'
        vstop_down:
            color: 'red'



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc