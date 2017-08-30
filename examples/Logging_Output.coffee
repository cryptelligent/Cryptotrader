#Open Source Logging Output
#DiSTANT
#https://cryptotrader.org/strategies/JEuDrt4L8jnWHkJFX
class FUNCTIONS

    @LOG_CTSTATS: (id, current_price, current_assets, current_currency, initial_price, initial_assets, initial_currency) ->
        start_assets = (initial_currency/initial_price) + initial_assets
        start_currency = (initial_assets * initial_price) + initial_currency
        assets = (current_currency/current_price) + current_assets
        currency = (current_assets * current_price) + current_currency

        pairs = id.toUpperCase().split '_'
        debug '|Initial Price: ' + initial_price.toFixed(8) + ' | Current Price: ' + current_price.toFixed(8)
        debug '|Equity (' + pairs[1] + ')\t| ' + currency.toFixed(8) + ' | Start\t| ' + start_currency.toFixed(8)
        debug '|Equity (' + pairs[0] + ')\t| ' + assets.toFixed(8) + ' | Start\t| ' + start_assets.toFixed(8)
        debug '---------------------------------------------------------------'
        debug ' '

init: (context) ->

handle: (context, data, storage) ->

    instrument = data.instruments[0]

    current_price = instrument.price
    current_assets = portfolio.positions[instrument.asset()].amount
    current_currency = portfolio.positions[instrument.curr()].amount

    storage.initial_price ?= instrument.price
    storage.initial_assets ?= current_assets
    storage.initial_currency ?= current_currency

    FUNCTIONS.LOG_CTSTATS(instrument.id, current_price, current_assets, current_currency, storage.initial_price, storage.initial_assets, storage.initial_currency)
