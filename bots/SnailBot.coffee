#Snail Bot
#https://cryptotrader.org/strategies/8esWE9tucPRQTEE8z
#squ1zzy
#Iceberg buys and sells

class functions
    @align: (key, value, length = 0, char = '\u00A0') ->
        key = '' + key
        value = '' + value
        char = '' + char
        space = Math.ceil (length - (key.length + value.length)) / char.length
        _.times(space, -> key += char)
        key + value
    @stats: (id, current_price, current_assets, current_currency, initial_price, initial_assets, initial_currency, p_curr_gain, ticks, period, lastAction) ->
        start_assets = (initial_currency/initial_price) + initial_assets
        start_currency = (initial_assets * initial_price) + initial_currency
        assets = (current_currency/current_price) + current_assets
        currency = (current_assets * current_price) + current_currency

        pairs = id.toUpperCase().split '_'
        info [functions.align('|Uber Snail Bot v3.6', '' ,25) + ' |']
        debug [functions.align('|Day', (ticks * period/1440).toFixed(0), 25) + ' |' + functions.align('Last Action ', lastAction, 25) + '|']
        debug [functions.align('|Initial Price ', initial_price.toFixed(6),25) + ' |' + functions.align('Current Price ', current_price.toFixed(6),25) + '|']
        debug [functions.align('|Equity ' + pairs[1], currency.toFixed(2),25) + ' |' + functions.align('Start ', start_currency.toFixed(2),25) + '|']
        debug [functions.align('|Equity ' + pairs[0], assets.toFixed(2),25) + ' |' + functions.align('Start ', start_assets.toFixed(2),25) + '|']
        if p_curr_gain.toFixed(2) < 0
            warn [functions.align('|Profit ', p_curr_gain.toFixed(2) + '%',25) + ' |']
        else
            info [functions.align('|Profit ', p_curr_gain.toFixed(2) + '%',25) + ' |']
    @roundDown: (value, places) ->
        offset = Math.pow(10, places)
        return Math.floor(value*offset)/offset
    @buy: (instrument, split, timeout, price, curr, assets, n = 0) ->
        assetLimit = assets+curr/price
        minimum = 0.05*price
        amount = functions.roundDown(assetLimit/split, 4)
        debug "Beginning to buy #{assetLimit.toFixed(2)} in #{split} orders"
        buying = true
        while buying == true
            if curr >= 1.1*amount*price
                n++
                debug "Iceberg order #{n}"
                tradeamount = functions.roundDown(((0.9+0.2*Math.random())*amount),4)
                buy(instrument, tradeamount, null, timeout)
                curr = portfolio.positions[instrument.curr()].amount
                if curr < minimum
                    debug "Last order"
                    buy instrument
                    buying = false
                    n = 0
                    debug "Finished Buying"
            else
                debug "Last Order"
                buy instrument
                buying = false
                n = 0
                debug "Finished Buying"
    @sell: (instrument, split, timeout, price, curr, assets, n = 0) ->
        assetLimit = assets+curr/price
        minimum = 0.05
        amount = functions.roundDown(assetLimit/split, 4)
        debug "Beginning to sell #{assetLimit.toFixed(3)} in #{split} orders"
        selling = true
        while selling == true
            if assets >= 1.1*amount
                n++
                debug "Iceberg order #{n}"
                tradeamount = functions.roundDown(((0.9+0.2*Math.random())*amount),4)
                sell(instrument, tradeamount, null, timeout)
                assets = portfolio.positions[instrument.asset()].amount
                if assets  < minimum
                    debug "Last order"
                    sell instrument
                    selling = false
                    n = 0
                    debug "Finished Selling"
            else
                debug "Last order"
                sell instrument
                selling = false
                n = 0
                debug "Finished Selling"
init: (context) ->
    context.buyTreshold = 0.18
    context.sellTreshold = 0.25
    context.calcTicks = 0
    context.lastAction = 'None'
handle: (context, data, storage) ->
    instrument = data.instruments[0]

    short = instrument.ema(56)
    long = instrument.ema(84)

    current_price = instrument.price
    current_assets = portfolio.positions[instrument.asset()].amount
    current_currency = portfolio.positions[instrument.curr()].amount

    storage.initial_price ?= instrument.price
    storage.initial_assets ?= current_assets
    storage.initial_currency ?= current_currency
    storage.start_curr ?= (current_currency+current_assets*current_price)
    storage.curr_lim = (current_currency+current_assets*current_price)
    storage.p_curr_gain = ((storage.curr_lim/storage.start_curr-1)*100)

    diff = 100 * (short - long) / ((short + long) / 2)
    if diff > context.buyTreshold && current_currency >= 0.01
        functions.buy instrument, 5, 30, current_price, current_currency, current_assets
        context.lastAction = 'Buy'
    else
        if diff < -context.sellTreshold && current_currency < 0.01
            functions.sell instrument, 5, 30, current_price, current_currency, current_assets
            context.lastAction = 'Sell'
    functions.stats(instrument.id, current_price, current_assets, current_currency, storage.initial_price, storage.initial_assets, storage.initial_currency, storage.p_curr_gain, context.calcTicks, instrument.period, context.lastAction)

    context.calcTicks++
