#Panda Bot
#https://cryptotrader.org/strategies/2QubvPEesQdeqCvFN
#This bot is specially made for side-way trends. Most bots have difficulty getting profit when the market goes side-ways. This bot will protect your assets by custom code and I will keep developing the bot for better performance and stats.

class functions
    @align: (key, value, length = 0, char = '\u00A0') ->
        key = '' + key
        value = '' + value
        char = '' + char
        space = Math.ceil (length - (key.length + value.length)) / char.length
        _.times(space, -> key += char)
        key + value
    @stats: (instrument, current_price, current_assets, current_currency, initial_price, initial_assets, initial_currency, p_curr_gain, ticks, period, lastAction) ->
        start_assets = (initial_currency/initial_price) + initial_assets
        start_currency = (initial_assets * initial_price) + initial_currency
        assets = (current_currency/current_price) + current_assets
        currency = (current_assets * current_price) + current_currency

        pairs = instrument.id.toUpperCase().split '_'
        info [functions.align('|Panda v2.0', '' ,25) + ' |']
        debug [functions.align('|Day', (ticks * period/1440).toFixed(0), 25) + ' |' + functions.align('Last Action ', lastAction, 25) + '|']
        debug [functions.align('|Initial Price ', initial_price.toFixed(6),25) + ' |' + functions.align('Current Price ', current_price.toFixed(6),25) + '|']
        debug [functions.align('|Equity ' + pairs[1], currency.toFixed(2),25) + ' |' + functions.align('Start ', start_currency.toFixed(2),25) + '|']
        debug [functions.align('|Equity ' + pairs[0], assets.toFixed(2),25) + ' |' + functions.align('Start ', start_assets.toFixed(2),25) + '|']
        if p_curr_gain.toFixed(2) < 0
            warn [functions.align('|Profit ', p_curr_gain.toFixed(2) + '%',25) + ' |']
        else
            info [functions.align('|Profit ', p_curr_gain.toFixed(2) + '%',25) + ' |']
    @decide: (context, storage, instrument) ->
        p = instrument.price
        r = functions.rsi(instrument.close, context.rsi_p)

        if r < context.rsi_lo
            sell instrument
            context.lastAction = 'Sell'

        else if r > context.rsi_hi
          buy instrument
          context.lastAction = 'Buy'

    @rsi: (data, period, last = true) ->
        period = data.length unless data.length >= period
        results = talib.RSI
            inReal: data
            startIdx: 0
            endIdx: data.length - 1
            optInTimePeriod: period
        if last then _.last(results) else results

init: (context) ->
    context.rsi_p = 3
    context.rsi_lo = 30
    context.rsi_hi = 91
    context.multiplier = 1
    context.dynamic_offset = true
    context.calcTicks = 0
    context.lastAction = 'None'

handle: (context, data, storage)->
    instrument = data.instruments[0]

    current_price = instrument.price
    current_currency = portfolio.positions[instrument.curr()].amount
    current_assets = portfolio.positions[instrument.asset()].amount

    storage.initial_price ?= instrument.price
    storage.initial_assets ?= current_assets
    storage.initial_currency ?= current_currency
    storage.start_curr ?= (current_currency+current_assets*current_price)
    storage.curr_lim = (current_currency+current_assets*current_price)
    storage.p_curr_gain = ((storage.curr_lim/storage.start_curr-1)*100)
    functions.decide(context, storage, instrument)
    functions.stats(instrument, current_price, current_assets, current_currency, storage.initial_price, storage.initial_assets, storage.initial_currency, storage.p_curr_gain, context.calcTicks, instrument.period, context.lastAction)
    context.calcTicks++

