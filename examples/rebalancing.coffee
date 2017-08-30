###
  REBALANCING TRADING ALGORITHM
  The portfolio rebalancing bot will buy and sell to maintain a
  constant asset allocation ratio of exactly 50/50 = fiat/BTC
  The script engine is based on CoffeeScript (http://coffeescript.org)
  Any trading algorithm needs to implement two methods:
    init(context) and handle(context,data)
###

# Initialization method called before a simulation starts.
# Context object holds script data and will be passed to 'handle' method.
init: (context)->
    context.DISTANCE  = 5 # percent price distance of next rebalancing

# This method is called for each tick
handle: (context, data)->
    # data object provides access to the current candle
    instrument = data.instruments[0]
    fiat_have = portfolio.positions[instrument.curr()].amount
    btc_have = portfolio.positions[instrument.asset()].amount
    price_then = instrument.price

    btc_value_then = btc_have * price_then
    diff = fiat_have - btc_value_then
    diff_btc = diff / price_then
    must_buy = diff_btc / 2
    perc_diff = diff_btc/btc_have*100

    # TRADE
    if Math.abs(perc_diff)>context.DISTANCE
        if must_buy>0
            buy(instrument,must_buy)
        else
            sell(instrument,Math.abs(must_buy))
