################################ CREDITS #######################################
    #  Winners/Losers bot
    # a bot to show (each 1/2h) which token is winning on poloniex
    # development by cryptelligent
############################## END OF CREDITS ##################################
#NOTE: when backtesting start with Polonie, DASH/USDT, 5min
################################ HEAD ##########################################
trading = require 'trading'
ds = require 'datasources'
ds.add 'poloniex', 'bch_usdt', '5m'
ds.add 'poloniex', 'xmr_usdt', '5m'
ds.add 'poloniex', 'ltc_usdt', '5m'
ds.add 'poloniex', 'xrp_usdt', '5m'
ds.add 'poloniex', 'zec_usdt', '5m'

################################ END OF HEAD ###################################

handle: ->

    storage.botStartedAt ?= data.at
    storage.TICK ?= 0
    if (storage.TICK == 0)
        storage.tokens = []
        storage.tokensobj = {}
        for ins in @data.instruments
            tokensobj = {
                pair: ins.pair
                price: 0
                prev_price: ins.price
                volume: 0
                prev_volume: ins.volume
            }
            storage.tokens.push tokensobj
    if (storage.TICK % 6) == 0
        storage.prev_tokens = storage.tokens
        storage.tokens = []
        for ins in @data.instruments
            tokensobj = {
                pair: ins.pair
                price: ins.price
                volume: ins.volume
            }
            storage.tokens.push tokensobj
        debug ' '
        debug '| Token | Change,% |'
        for token, i in  storage.tokens
            percent = ((token.price - storage.prev_tokens[i].price) *100 / token.price).toFixed(2)
            debug '| ' + token.pair.toUpperCase() + ' | ' + percent + '%'
    storage.TICK++
