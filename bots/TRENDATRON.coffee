#######################
### TRENDATRON 5000 ###
#######################

### INTRO
https://cryptotrader.org/strategies/peKY35zY2Z2G56rLi
by aspiramedia (https://cryptotrader.org/aspiramedia)

Please PM me with any updates, feedback, bugs, suggestions, criticism etc.
Please leave this header intact, adding your own comments in EDITOR'S COMMENTS.
Edited bots are NOT for submission into the CryptoTrader.org Strategies section.
###

### EDITOR'S COMMENTS
Made any edits? Why not explain here.
###

### DONATIONS
I am releasing this as a donation based bot. I am releasing this in hope of obtaining some donations from users here.
Please donate BTC to: 1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

### DISCLAIMER
As usual with all trading, only trade with what you are able to lose.
Start small. I am NOT responsible for your losses if any occur.
###

### CREDITS
The VIX and Swing indicators used here were originally by Chris Moody at TradingView.
Trading logic is my own.
Thanks to all at Cryptotrader.org that helped me along the way.
###

### ADVICE
Rather than just trading with this, perhaps make this bot your own. Use it as a learning tool. Edit it to trade as you like to match your strategy.
View this as a template for a long term trend trader with added scalping.
Backtesting is your friend. Backtest over long periods to identify strengths and weaknesses.
###


############
### CODE ###
############

STOP_LOSS = askParam 'Use a Stop Loss?', false
STOP_LOSS_PERCENTAGE = askParam 'If so, Stop Loss Percentage?', 5
SCALP = askParam 'Use Scalping?', true
SPLIT = askParam 'Split orders up?', false
SPLIT_AMOUNT = askParam 'If so, split into how many?', 4
PERIOD = askParam 'Trend reaction time (Max = 250 | Min = 50 | Default = 250 )', 250
SNIPE = askParam 'Use Fat Finger Sniping?', false
CODE = askParam 'Code to remove donation requests', 0

class VIX
    constructor: (@period) ->
        @close = []
        @wvf = []
        @trade = []
        @count = 0

        # INITIALIZE ARRAYS
        for [@close.length..22]
            @close.push 0
        for [@wvf.length..@period]
            @wvf.push 0
        for [@trade.length..10]
            @trade.push 0

    calculate: (instrument) ->

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]


        # INCREASE DATA COUNT
        @count++

        # REMOVE OLD DATA
        @close.pop()
        @wvf.pop()
        @trade.pop()

        # ADD NEW DATA
        @close.unshift(0)
        @wvf.unshift(0)
        @trade.unshift(0)

        # CALCULATE
        @close[0] = close

        highest = (@close.reduce (a,b) -> Math.max a, b)

        @wvf[0] = ((highest - low) / (highest)) * 100

        sdev = talib.STDDEV
            inReal: @wvf
            startIdx: 0
            endIdx: @wvf.length-1
            optInTimePeriod: @period
            optInNbDev: 1
        sdev = sdev[sdev.length-1]

        midline = talib.SMA
            inReal: @wvf
            startIdx: 0
            endIdx: @wvf.length-1
            optInTimePeriod: @period
        midline = midline[midline.length-1]

        lowerband = midline - sdev
        upperband = midline + sdev

        rangehigh = (@wvf.reduce (a,b) -> Math.max a, b) * 0.85
        rangelow = (@wvf.reduce (a,b) -> Math.min a, b) * 1.01

        if @wvf[0] >= upperband or @wvf[0] >= rangehigh
            @trade[0] = 0
            plotMark
                "wvf1": @wvf[0]
        else
            @trade[0] = 1
            plotMark
                "wvf2": @wvf[0]


        # RETURN DATA
        result =
            wvf: @wvf[0]
            rangehigh: rangehigh
            rangelow: rangelow
            trade: @trade

        return result

class GANNSWING
    constructor: (@period) ->
        @count = 0
        @buycount = 0
        @sellcount = 0
        @lowma = []
        @highma = []
        @fastlowma = []
        @fasthighma = []

        # INITIALIZE ARRAYS
        for [@lowma.length..5]
            @lowma.push 0
        for [@highma.length..5]
            @highma.push 0
        for [@fastlowma.length..5]
            @fastlowma.push 0
        for [@fasthighma.length..5]
            @fasthighma.push 0

    calculate: (instrument) ->

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # REMOVE OLD DATA
        @lowma.pop()
        @highma.pop()
        @fastlowma.pop()
        @fasthighma.pop()

        # ADD NEW DATA
        @lowma.unshift(0)
        @highma.unshift(0)
        @fastlowma.unshift(0)
        @fasthighma.unshift(0)


        # CALCULATE
        highma = talib.SMA
            inReal: instrument.high
            startIdx: 0
            endIdx: instrument.high.length-1
            optInTimePeriod: @period
        @highma[0] = highma[highma.length-1]

        lowma = talib.SMA
            inReal: instrument.low
            startIdx: 0
            endIdx: instrument.low.length-1
            optInTimePeriod: @period
        @lowma[0] = lowma[lowma.length-1]

        fasthighma = talib.SMA
            inReal: instrument.high
            startIdx: 0
            endIdx: instrument.high.length-1
            optInTimePeriod: @period / 5
        @fasthighma[0] = fasthighma[fasthighma.length-1]

        fastlowma = talib.SMA
            inReal: instrument.low
            startIdx: 0
            endIdx: instrument.low.length-1
            optInTimePeriod: @period / 5
        @fastlowma[0] = fastlowma[fastlowma.length-1]


        if close > @highma[1] * 0.998 or (close > @fasthighma[1] and close > @fastlowma[1] * 1.01 and @fasthighma[1] > @highma[1])
            hld = 1
        else if close < @lowma[1] / 0.998 or (close < @fastlowma[1] and close < @fasthighma[1] / 1.01 and @fastlowma[1] < @lowma[1])
            hld = -1
        else
            hld = 0

        if hld != 0
            @count++

        if hld != 0 && @count == 1
            hlv = hld
            @count = 0
        else
            hlv = 0

        if hlv == -1
            hi = @highma[0]
            plotMark
                "hi": 50
            @sellcount++
            @buycount = 0

        if hlv == 1
            lo = @lowma[0]
            plotMark
                "lo": -5
            @buycount++
            @sellcount = 0

        if @buycount == 3
            tradebuy = true
            @buycount = 0
        else
            tradebuy = false


        if @sellcount == 3
            tradesell = true
            @sellcount = 0
        else
            tradesell = false


        # RETURN DATA
        result =
            tradesell: tradesell
            tradebuy: tradebuy

        return result

class FUNCTIONS

    @ROUND_DOWN: (value, places) ->
        offset = Math.pow(10, places)
        return Math.floor(value*offset)/offset

class TRADE

    @BUY: (instrument, amount, split, timeout) ->
        price = instrument.price * 1.005

        if split > 0
            amount = FUNCTIONS.ROUND_DOWN((portfolio.positions[instrument.curr()].amount/split)/price, 8)
            for [0..split]
                buy(instrument, amount, price, timeout)
        else
            buy(instrument, null, price, timeout)

    @SELL: (instrument, amount, split, timeout) ->
        price = instrument.price * 0.995

        if split > 0
            amount = FUNCTIONS.ROUND_DOWN(portfolio.positions[instrument.asset()].amount/split, 8)
            for [0..split]
                sell(instrument, amount, price, timeout)
        else
            sell(instrument, amount, price, timeout)

init: (context)->

    context.vix     = new VIX(20)               # Period of stddev and midline
    context.swing   = new GANNSWING(PERIOD)       # Period of highma and lowma

    # FOR FINALISE STATS
    context.balance_curr = 0
    context.balance_btc = 0
    context.price = 0

    # TRADING
    if SPLIT
        context.trade_split = SPLIT_AMOUNT
    else
        context.trade_split = 0
    context.trade_timeout   = 3000



handle: (context, data, storage)->

    instrument = data.instruments[0]
    price = instrument.close[instrument.close.length - 1]
    storage.lastBuyPrice ?= 0
    storage.lastSellPrice ?= 0
    storage.TICK ?= 0
    storage.NAG ?= 1
    storage.wintrades ?= 0
    storage.losetrades ?= 0
    storage.coolOff ?= 0
    trading = 0

    # FOR FINALISE STATS
    context.price = instrument.close[instrument.close.length - 1]
    context.balance_curr = portfolio.positions[instrument.curr()].amount
    context.balance_btc = portfolio.positions[instrument.asset()].amount

    # CALLING INDICATORS
    vix = context.vix.calculate(instrument)
    wvf = vix.wvf
    rangehigh = vix.rangehigh
    rangelow = vix.rangelow
    trade = vix.trade

    swing = context.swing.calculate(instrument)
    tradesell = swing.tradesell
    tradebuy = swing.tradebuy

    # LOGGING

    today = new Date
    day = today.getDate()
    month = today.getMonth()
    combo = day + month + 1

    if storage.TICK == 0
        storage.balance_curr_start = portfolio.positions[instrument.curr()].amount
        storage.balance_btc_start = portfolio.positions[instrument.asset()].amount
        storage.price_start = price
        if combo == CODE
            storage.NAG = 0
         # WELCOME
        info "###"
        info "Welcome to the Trendatron 5000 Donation Bot."
        if storage.NAG == 1
            info "Thanks for choosing this free bot. As many hours have gone into its creation, please consider a donation to:"
            info "BTC: 1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74"
            info "(The bot carries on regardless of donations - don't worry.)"
            info "If you have donated PM me for a code to make donation requests disappear."
        else
            info "Thanks for choosing to donate. Appreciated."
        if STOP_LOSS == true
            info "You chose to use a Stop Loss, with a cutoff of " + STOP_LOSS_PERCENTAGE + " percent."
        if SCALP == true
            info "You chose to use scalping (default bot behaviour)"
        if SPLIT == true
            info "You chose to split orders up into " + SPLIT_AMOUNT + " orders."
        if SNIPE == true
            info "You chose to enable sniping."
        info "###"


    starting_btc_equiv = storage.balance_btc_start + storage.balance_curr_start / storage.price_start
    current_btc_equiv = context.balance_btc + context.balance_curr / price
    starting_fiat_equiv = storage.balance_curr_start + storage.balance_btc_start * storage.price_start
    current_fiat_equiv = context.balance_curr + context.balance_btc * price
    efficiency = Math.round((current_btc_equiv / starting_btc_equiv) * 1000) / 1000
    efficiency_percent = Math.round((((current_btc_equiv / starting_btc_equiv) - 1) * 100) * 10) / 10
    market_efficiency = Math.round((((context.price / storage.price_start) - 1) * 100) * 10) / 10
    bot_efficiency = Math.round((((current_fiat_equiv / starting_fiat_equiv) - 1) * 100) * 10) / 10
    pairs = instrument.id.toUpperCase().split '_'
    pair1 = pairs[0]
    pair2 = pairs[1]

    storage.TICK++

    if Math.round(storage.TICK/24) == (storage.TICK/24)
        warn " "
        info "================= Day " + Math.round(storage.TICK/24) + " Log ==================="
        debug "Current " + pair2 + ": " + Math.round(context.balance_curr*100)/100 + " | Current " + pair1 + ": " +  Math.round(context.balance_btc*100)/100
        debug "Starting " + pair2 + ": " + Math.round(storage.balance_curr_start*100)/100 + " | Starting " + pair1 + ": " +  Math.round(storage.balance_btc_start*100)/100
        debug "Current Portfolio Worth: " + Math.round(((context.balance_btc * price) + context.balance_curr)*100)/100
        debug "Starting Portfolio Worth: " + Math.round(((storage.balance_btc_start * storage.price_start) + storage.balance_curr_start)*100)/100
        debug "Trades: Won = " + storage.wintrades + " | Lost = " + storage.losetrades + " | Total = " + (storage.wintrades + storage.losetrades) + " | W/L = " + (Math.round(((storage.wintrades / (storage.wintrades + storage.losetrades) * 100))*100)/100) + "%"
        debug "Efficiency of Buy and Hold: " + market_efficiency + "%"
        debug "Efficiency of Bot: " + bot_efficiency + "%"
        debug "Efficiency of Bot Vs Buy and Hold: " + efficiency + " which equals " + efficiency_percent + "%"
        info "==============================================="
        warn " "

    if Math.round(storage.TICK/24) == (storage.TICK/24) && storage.NAG == 1
        info "###"
        info "Thanks for using this bot. Please consider a donation to:"
        info "BTC: 1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74"
        info "(The bot carries on regardless of donations - don't worry.)"
        info "If you have donated PM me for a code to make donation requests disappear."
        info "###"


    # TRADING
    if context.balance_curr/price > 0.01
        if tradebuy == true && storage.coolOff <= 0
            if TRADE.BUY(instrument, null, context.trade_split, context.trade_timeout)
                storage.lastBuyPrice = price
                storage.stop = true
                info "#########"
                info "Trend Buy"
                info "#########"
                trading = 1
                sendEmail "Trendatron TREND BUY" + " - Current Fiat: " + Math.round(context.balance_curr*100)/100 + " | Current BTC: " +  Math.round(context.balance_btc*100)/100

    if context.balance_curr/price > 0.01 && SCALP == true && storage.coolOff <= 0
        if trade[0] == 1 && trade[1] == 1 && trade[2] == 0 && trade[3] == 0 && trade[4] == 0 && trade[5] == 0 && wvf > 8.5
            if TRADE.BUY(instrument, null, context.trade_split, context.trade_timeout)
                storage.lastBuyPrice = price
                storage.stop = true
                info "#########"
                info "Scalp Buy"
                info "#########"
                trading = 1
                sendEmail "Trendatron SCALP BUY" + " - Current Fiat: " + Math.round(context.balance_curr*100)/100 + " | Current BTC: " +  Math.round(context.balance_btc*100)/100

    if context.balance_btc > 0.01
        if (tradesell == true && wvf < 2.85) or (tradebuy == true && wvf > 8.5 && trade[0] == 1 && trade[1] == 0)
            if TRADE.SELL(instrument, null, context.trade_split, context.trade_timeout)
                storage.lastSellPrice = price
                storage.stop = false
                warn "##########"
                warn "Trend Sell"
                warn "##########"
                trading = 1
                if storage.lastSellPrice > storage.lastBuyPrice
                    storage.wintrades++
                else
                    storage.losetrades++
                sendEmail "Trendatron TREND SELL" + " - Current Fiat: " + Math.round(context.balance_curr*100)/100 + " | Current BTC: " +  Math.round(context.balance_btc*100)/100

    if STOP_LOSS
        if storage.stop == true && price < storage.lastBuyPrice * (1 - (STOP_LOSS_PERCENTAGE / 100))
            if TRADE.SELL(instrument, null, context.trade_split, context.trade_timeout)
                storage.lastSellPrice = price
                storage.stop = false
                storage.coolOff = 30
                warn "##############"
                warn "Stop Loss Sell"
                warn "##############"
                trading = 1
                if storage.lastSellPrice > storage.lastBuyPrice
                    storage.wintrades++
                else
                    storage.losetrades++
                sendEmail "Trendatron STOP LOSS SELL" + " - Current Fiat: " + Math.round(context.balance_curr*100)/100 + " | Current BTC: " +  Math.round(context.balance_btc*100)/100

    if SNIPE && trading == 0
        if context.balance_btc > 0.05
            if sell instrument,null,instrument.price * 1.1,3000
                warn "##########"
                warn "Snipe Sell"
                warn "##########"
        if context.balance_curr > 10
            if buy instrument,null,instrument.price * 0.9,3000
                info "#########"
                info "Snipe Buy"
                info "#########"

    storage.coolOff--

    # PLOTTING / DEBUG
    plot
        wvf: wvf
        rangehigh: rangehigh
        rangelow: rangelow
    setPlotOptions
        wvf:
            secondary: true
        rangehigh:
            secondary: true
        rangelow:
            secondary: true
        wvf1:
            secondary: true
            color: 'blue'
            size: 1
        wvf2:
            secondary: true
            color: 'black'
            size: 1
        lo:
            color: 'green'
            secondary: true
            size: 4
        hi:
            color: 'red'
            secondary: true
            size: 4




finalize: (contex, data)->

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final Equiv: " + Math.round(context.balance_curr/context.price*100)/100
    if context.balance_btc > 0.05
        info "Final Value: " + Math.round(context.balance_btc*100)/100
