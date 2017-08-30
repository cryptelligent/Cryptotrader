###
	Ice Whale
	pulsecat
	https://cryptotrader.org/strategies/nk5DQY7J8bjXtfE3N
  Iceberg algorithm for buying/selling large amount of assets

  The script engine is based on CoffeeScript (http://coffeescript.org)
  Any trading algorithm needs to implement two methods:
    init(context) and handle(context,data)

	orders are placed on top of the order book for getting the best price
	maximum/minimum price can be specified
	randomizes order amount +-10%
###
params = require 'params'
trading = require 'trading'
OP = params.add 'Buy or Sell', 'buy'
MIN_SELL_PRICE = params.add 'Min sell price', 0
MAX_BUY_PRICE = params.add 'Max buy price', 0
AVG_ORDER_SIZE = params.add 'Average order size', 50
TIMEOUT = params.add 'Order timeout (sec)', 30
STOP_AFTER_TRADE = params.add "Stop after trade is finished", true



class TRADE

    @BUY: (portfolio, ins, orderSize, maxPrice, timeout, tick) ->
        n = 1
        assets = portfolio.positions[ins.asset()].amount
        curr = portfolio.positions[ins.curr()].amount
        unless curr
            return true
        maxassets = curr/ins.price
        debug "Beginning to buy #{maxassets}  #{ins.asset().toUpperCase()}  at #{ins.price}"
        while true
            debug "#{assets} #{ins.asset().toUpperCase()} #{curr} #{ins.curr().toUpperCase()}"
            ticker = trading.getTicker ins
            if curr / ins.price < orderSize
                price = ticker.sell
                if trading.buy ins, 'limit', curr / maxPrice, maxPrice,timeout
                    debug "Finished buying"
                    return true
                break
            amount = Math.min(curr / ins.price,(0.8+0.4*Math.random())*orderSize)
            debug "Iceberg order ##{n} price: #{ticker.sell} amount: #{amount} tick: #{tick}"
            if maxPrice
                if ticker.buy > maxPrice
                    if trading.buy(ins, 'limit', amount, maxPrice, ins.interval * 60)
                        continue
                    else
                        return
            if trading.buy(ins, 'limit', amount, ticker.buy*1.0001, timeout)
               n++
            assets = portfolio.positions[ins.asset()].amount
            curr = portfolio.positions[ins.curr()].amount
    @SELL: (portfolio, ins, orderSize, minPrice, timeout, tick) ->
        n = 1
        assets = portfolio.positions[ins.asset()].amount
        curr = portfolio.positions[ins.curr()].amount
        unless assets
            return
        maxassets = assets
        debug "Beginning to sell #{maxassets} #{ins.asset().toUpperCase()} at #{ins.price}"
        while true
            debug "#{assets} #{ins.asset().toUpperCase()} #{curr} #{ins.curr().toUpperCase()}"
            ticker = trading.getTicker ins
            if assets < orderSize
                if trading.sell ins, 'limit', assets, minPrice, timeout
                    debug "Finished selling"
                    return true
            amount = Math.min(assets,(0.8+0.4*Math.random())*orderSize)
            debug "Iceberg order ##{n} price: #{ticker.buy} amount: #{amount} tick: #{tick}"
            if minPrice
                if ticker.sell < minPrice
                    if trading.sell(ins, 'limit', amount, minPrice, ins.interval * 60)
                        continue
                    return
            if trading.sell(ins, 'limit', amount, ticker.sell * 0.9999, timeout)
               n++
            assets = portfolio.positions[ins.asset()].amount
            curr = portfolio.positions[ins.curr()].amount



# This method is called for each tick
handle: ->
    # data object provides access to the current candle
    instrument = @data.instruments[0]
    storage.tick ?= 0
    storage.tick++
    op = OP.toLowerCase()
    if op is 'buy'
        buy_signal = true
    else if op is 'sell'
        sell_signal = true
    orderSize = AVG_ORDER_SIZE
    if buy_signal
        if TRADE.BUY @portfolio, instrument, AVG_ORDER_SIZE, MAX_BUY_PRICE, TIMEOUT, storage.tick
            if STOP_AFTER_TRADE
                stop()
    else
        if sell_signal
            if TRADE.SELL @portfolio, instrument, AVG_ORDER_SIZE, MIN_SELL_PRICE, TIMEOUT, storage.tick
                if STOP_AFTER_TRADE
                    stop()










