###
	EMA 10 / 21
	https://cryptotrader.org/strategies/gBZe6HdD5XmFJcjm4
  EMA CROSSOVER TRADING ALGORITHM
  The script engine is based on CoffeeScript (http://coffeescript.org)
  Any trading algorithm needs to implement two methods:
    init(context) and handle(context,data)
###
talib = require 'talib'
trading = require 'trading'


# Initialization method called before a simulation starts.
# Context object holds script data and will be passed to 'handle' method.
init: ->
    @context.buy_treshold = 0.25
    @context.sell_treshold = 0.25

# This method is called for each tick
handle: ->
    # data object provides access to the current candle (ex. data.instruments[0].close)
    instrument = @data.instruments[0]
    short = instrument.ema(10) # calculate EMA value using ta-lib function
    long = instrument.ema(21)
    # draw moving averages on chart
    plot
        short: short
        long: long
    diff = 100 * (short - long) / ((short + long) / 2)
    # Uncomment next line for some debugging
    #debug 'EMA difference: '+diff.toFixed(3)+' price: '+instrument.price.toFixed(2)+' at '+new Date(data.at)
    if diff > @context.buy_treshold
        trading.buy instrument, 'market', @portfolio.positions[instrument.curr()].amount / instrument.price
    else
        if diff < -@context.sell_treshold
            trading.sell instrument, 'market', @portfolio.positions[instrument.asset()].amount

