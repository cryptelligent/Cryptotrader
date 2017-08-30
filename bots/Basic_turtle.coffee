###
  The script engine is based on CoffeeScript (http://coffeescript.org)
  A basic Turtle Strategy that builds a balanced portfolio with a mix
  of different assets
  Entry/exit parameters based on the Donchian channel that measures the highest
  high and the lowest low in a series of bars
  Utilizes the Iceberg algorithm for the most profitable execution of large orders
  https://cryptotrader.org/strategies/KG7H9Fqu6eqWRATux
     pulsecat
###
trading = require 'trading'
params = require 'params'
ds = require 'datasources'

ds.add 'poloniex', 'eth_btc', '4h'
ds.add 'poloniex', 'xmr_btc', '4h'
ds.add 'poloniex', 'zec_btc', '4h'


ENTER_FAST=42
EXIT_FAST=12

TIMEOUT=30

openPosition = (portfolio, ins, size) ->
    n = 1
    debug "Buying #{size / ins.price} #{ins.asset().toUpperCase()} at #{ins.price}"
    orderSize = (size / ins.price) / 10
    while true
        ticker = trading.getTicker ins
        price = ticker.buy * 1.0001
        amount = (0.9 + 0.2 * Math.random()) * orderSize
        if (portfolio.positions[ins.asset()].amount + amount) * price >= size
            price = ticker.sell * 1.01
            amount = (size / price - portfolio.positions[ins.asset()].amount)
            debug "Iceberg finishing buying"
            trading.buy(ins, 'limit', amount, price, TIMEOUT)
            break
        debug "Iceberg order ##{n} price: #{price} amount: #{amount}"
        trading.buy(ins, 'limit', amount, price, TIMEOUT)
        n++
        if n > 100
            break


closePosition = (portfolio, ins, size) ->
    n = 1
    debug "Selling #{size} #{ins.asset().toUpperCase()} at #{ins.price}"
    orderSize = size / 10
    while true
        ticker = trading.getTicker ins
        price = ticker.sell * 0.9999
        amount = (0.9 + 0.2 * Math.random()) * orderSize
        if portfolio.positions[ins.asset()].amount <= amount
            amount = portfolio.positions[ins.asset()].amount
            debug "Iceberg finishing selling"
            trading.sell(ins, 'limit', amount, ticker.buy*0.99, TIMEOUT)
            break
        debug "Iceberg order ##{n} price: #{price} amount: #{amount}"
        trading.sell(ins, 'limit', amount, price, TIMEOUT)
        n++
        if n > 100
            break

closeMarketPosition = (portfolio, ins) ->
    amount = portfolio.positions[ins.asset()].amount
    debug "Selling #{amount} #{ins.asset().toUpperCase()} at #{ins.price}"
    ticker = trading.getTicker ins
    price = ticker.buy * 0.99

    trading.sell(ins, 'limit', amount, price)



# This method is called for each tick
handle: ->
    # data object provides access to the current candle
    numPairs = @data.instruments.length-1
    primary = @data.instruments[0]
    total = @portfolio.positions[primary.curr()].amount
    for i in [1..@data.instruments.length-1] # skip primary instrument as we do no trade with it
        ins = @data.instruments[i]
        if ins.price
            total += @portfolio.positions[ins.asset()].amount * ins.price
    debug "Total portfolio: #{total} #{primary.curr().toUpperCase()}"
    for i in [1..@data.instruments.length-1]
        ins = @data.instruments[i]
        unless ins.price # market data might be unavailable for new pairs
            continue
        tick =
            high: _.last ins.high
            low: _.last ins.low
            open: _.last ins.open
            close: _.last ins.close

        size = (total / numPairs) / ins.price
        fastL = _.max(ins.close.slice(-ENTER_FAST,-1))
        fastLC = _.min(ins.close.slice(-EXIT_FAST,-1))
        enterL = tick.high > fastL
        exitL = tick.low <= fastLC
        debug "#{ins.pair} price: #{ins.price.toFixed(7)} enterL: #{enterL} exitL: #{exitL}"
        curSize = @portfolio.positions[ins.asset()].amount
        if enterL
            if curSize * ins.price <= 0.1 # check for minimum order amount
                openPosition @portfolio, ins, size * ins.price
        else if exitL
            if curSize * ins.price >= 0.1
                closeMarketPosition @portfolio, ins


















