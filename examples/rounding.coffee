# by cryptomt 
# see also: https://cryptotrader.org/topics/719723/helpful-standardized-rounding-function-for-all-markets
round = (x, type) ->
    # set asset and base
    asset = @config.pair.split('_')[0].toUpperCase()
    base = @config.pair.split('_')[1].toUpperCase()
    if type is 'price'
        # special cases
        switch @config.market
            when 'coinbase'
                if base is 'USD' or base is 'EUR' or base is 'GBP' then return Math.round(x * 100) / 100
                if base is 'BTC' then return Math.round(x * 100000) / 100000
            when 'bittrex', 'poloniex'
                return Math.round(x * 100000000) / 100000000
            when 'bitstamp'
                if base is 'USD' or base is 'EUR'
                    if asset is 'XRP' then return Math.round(x * 100000) / 100000
                    return Math.round(x * 100) / 100
                return Math.round(x * 100000000) / 100000000
        switch
            when x >= 1000 then return Math.round(x)
            when x >= 100 then return Math.round(x * 10) / 10
            when x >= 10 then return Math.round(x * 100) / 100
            when x >= 1 then return Math.round(x * 1000) / 1000
            when x >= 0.1 then return Math.round(x * 10000) / 10000
            when x >= 0.01 then return Math.round(x * 100000) / 100000
            when x >= 0.001 then return Math.round(x * 1000000) / 1000000
            when x >= 0.0001 then return Math.round(x * 10000000) / 10000000
            else return Math.round(x * 100000000) / 100000000
    else if type is 'amount'
        # special cases
        switch @config.market
            when 'coinbase'
                if asset is 'LTC' then return Math.round(x * 100) / 100
                return Math.round(x * 10000) / 10000
            when 'bitfinex'
                return Math.round(x * 10000) / 10000
            when 'bittrex', 'poloniex', 'bitstamp', 'kraken'
                return Math.round(x * 100000000) / 100000000
        switch
            when x >= 1 then return Math.round(x)
            when x >= 0.1 then return Math.round(x * 10) / 10
            when x >= 0.01 then return Math.round(x * 100) / 100
            when x >= 0.001 then return Math.round(x * 1000) / 1000
            else return Math.round(x * 10000) / 10000
