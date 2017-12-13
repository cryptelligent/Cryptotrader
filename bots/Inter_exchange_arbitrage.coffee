################################ CREDITS #######################################
    #Inter exchange arbitrage (IA) bot
    # a bot to trade triples when discrepancies in prices occur
    #version 1.02 11/27/2017
    #Idea by EuroTurtle
    #development by cryptelligent
############################## END OF CREDITS ##################################

################################ HEAD ##########################################
trading = require 'trading'
ds = require 'datasources'
params = require 'params'

ds.add 'bitstamp', 'btc_usd', '1m'
ds.add 'bitstamp', 'eth_btc', '1m'
ds.add 'bitstamp', 'eth_usd', '1m'

CONSERVATIVE = params.add 'Conservative', 1 #possible values: 1 - for trading with factor above/below averages,  0 - for trading with factor above/below fees
UPPER_THRESHOLD = params.add 'UPPER THRESHOLD', 1.009 #average positive number above 1+FEE
LOWER_THRESHOLD = params.add 'LOWER THRESHOLD', 0.99 #average negative number below 1-FEE
FEES = params.add 'Exchange fees per 1 transaction in %', 0.25
MINIMUM_AMOUNT = params.add 'Minimum tradable amount in fiat', 20
MAXIMUM_AMOUNT = params.add 'Maximum tradable amount in fiat', 1000
RISK = params.add 'Risk (1,2,3 1- minimum)', 1 #the more the greater the risk. Possible values 1,2,3
MARKET_ONLY = params.add 'Order Type (0 - market and limit, 1 - market only)', 0 #1-market only, 0 - market and limit
SAFETY_FACTOR = params.add 'Safety factor', 1

ORDER_TYPE = 1 # 1-market, null -limit
#ICEBERG = 1 # not implemented yet
TEST_MODE = 0 #possible values: 1 - for testing with fictional order books values, 0 for production
DEBUG = 0 #possible values: 1 - to show all debug messages, 0 to show only trade's messages
TIME_OUT = 1200 # do not change it if you do not have  a reason, order expire in 20 min
resolutionMs = 1800 #will sleep 1.8 sec between iteration
ITERATIONS = 12 #will do 12 iteration per minute = 1 iteration each 5 sec
#CRASH_FACTOR = 0.2 # if balance fail 20% sell all assets
#change if needed checkActiveOrders for VALID PAIRS, storage.TICK == 0 and storage.iterations in handle
################################ END OF HEAD ###################################
################################ FUNCTIONS #####################################
###
    find the minimum tradeable amount by comparing cash and both coins
    @params - 3 instruments
    @return: minimum tradeable amount in cash
###
findMinTradableAmount = (ins) ->
    currency = @portfolios[ins[0].market].positions[ins[0].curr()].amount
    asetts0 = @portfolios[ins[0].market].positions[ins[0].asset()].amount
    asetts1 = @portfolios[ins[1].market].positions[ins[1].asset()].amount
    minAmount = Math.round(Math.min(currency, asetts0 * ins[0].price, asetts1 * ins[2].price)*SAFETY_FACTOR)
    if TEST_MODE
        minAmount = 200 #because in test mode only 2 coins exists so min would be 0
    if minAmount > MAXIMUM_AMOUNT
    	minAmount = MAXIMUM_AMOUNT
    return minAmount

###
    find the ask price for which AMOUNT can be bought
    @params - amount, orderBook
    @return: price or 0
###
findAskPrice = (amount, book) ->
    volume = amount
    sum = 0
    for val, key in book.asks
        sum += val[1]
        if sum >= volume
            price = val[0]
            return price
    debug "cannot calculate ask price for #{amount}"
    return 0

###
    find the BID price for which AMOUNT can be sold
    @params - amount, orderBook
    @return: price or 0
###
findBidPrice = (amount, book) ->
    volume = amount
    sum = 0
    for val, key in book.bids
        sum += val[1]
        if sum >= volume
            price = val[0]
            return price
    debug "cannot calculate bid price for #{amount}"
    return 0

###
    function calculateSignals calculate buy and sell signals on 3 orderbooks
    @params - array of 3 order books
    @return: signal objects or null if no buy and sell signals
###
calculateSignals = (books, ins) ->
    buy = 0
    sell = 0

    #amounts are calculated only aproximately
    amount0 = storage.minAmount / ins[0].price #in BTC
    amount1 = amount0 / ins[1].price #in ETH
    amount2 = amount1
    bestAsk0 = findAskPrice(amount0,books[0])
    bestAsk1 = findAskPrice(amount1,books[1])
    bestAsk2 = findAskPrice(amount2,books[2])

    bestBid0 = findBidPrice(amount0,books[0])
    bestBid1 = findBidPrice(amount1,books[1])
    bestBid2 = findBidPrice(amount2,books[2])


#    buyFactor = factor 							#sell, sell, buy
#    sellFactor = factor							 #buy, buy, sell

    buyFactor  = bestBid0 * bestBid1 / bestAsk2 #sell, sell, buy, no risk
    buyFactor0 = ins[0].price * bestBid1 / bestAsk2 #sell, sell, buy, big risk
    buyFactor1 = bestBid0 * bestBid1 / ins[2].price #sell, sell, buy, big risk
    buyFactor2 = ins[0].price * bestBid1 / ins[2].price #sell, sell, buy, most risk

    sellFactor = bestAsk0 * bestAsk1 / bestBid2 #buy, buy, sell, no risk
    sellFactor0 = ins[0].price * bestAsk1 / bestBid2 #buy, buy, sell, big risk
    sellFactor1 = bestAsk0 * bestAsk1 / ins[2].price #buy, buy, sell, big risk
    sellFactor2 = ins[0].price * bestAsk1 / ins[2].price #buy, buy, sell, most risk

#    debug "buy0:#{buyFactor0} buy1:#{buyFactor1} buy2:#{buyFactor2} sell0:#{sellFactor0} sell1:#{sellFactor1} sell2:#{sellFactor2}"
    if ((buyFactor > storage.upper_threshold) and (RISK == 1))
        if DEBUG
            debug "buyFactor: #{buyFactor} bestBid0 #{bestBid0}-#{amount0} bestBid1 #{bestBid1}-#{amount1} bestAsk2 #{bestAsk2}-#{amount2}"
        return {'sell':[[bestBid0, amount0], [bestBid1, amount1], [bestAsk2, amount2]]}
    else if ((buyFactor0 > storage.upper_threshold) and (RISK == 2))
        if DEBUG
            debug "buyFactor0: #{buyFactor0} ins[0].price #{ins[0].price}-#{amount0} bestBid1 #{bestBid1}-#{amount1} bestAsk2 #{bestAsk2}-#{amount2}"
        return {'sell':[[ins[0].price, amount0, ORDER_TYPE], [bestBid1, amount1], [bestAsk2, amount2]]}
    else if ((buyFactor1 > storage.upper_threshold) and (RISK == 3))
        if DEBUG
            debug "buyFactor1: #{buyFactor1} bestBid0 #{bestBid0}-#{amount0} bestBid1 #{bestBid1}-#{amount1} ins[2].price #{ins[2].price}-#{amount2}"
        return {'sell':[[bestBid0, amount0], [bestBid1, amount1], [ins[2].price, amount2, ORDER_TYPE]]}
    else if ((buyFactor2 > storage.upper_threshold) and (RISK == 3))
        if DEBUG
            debug "buyFactor2: #{buyFactor2} ins[0].price #{ins[0].price}-#{amount0} bestBid1 #{bestBid1}-#{amount1} ins[2].price #{ins[2].price}-#{amount2}"
        return {'sell':[[ins[0].price, amount0, ORDER_TYPE], [bestBid1, amount1], [ins[2].price, amount2, ORDER_TYPE]]}
    else if ((sellFactor < storage.lower_threshold) and (RISK == 1))
        if DEBUG
            debug "sellFactor: #{sellFactor} bestAsk0 #{bestAsk0}-#{amount0} bestAsk1 #{bestAsk1}-#{amount1} bestBid2 #{bestBid2}-#{amount2}"
        return {'buy':[[bestAsk0, amount0], [bestAsk1, amount1], [bestBid2, amount2]]}
    else if ((sellFactor0 < storage.lower_threshold) and (RISK == 2))
        if DEBUG
            debug "sellFactor0: #{sellFactor0} ins[0].price #{ins[0].price}-#{amount0} bestAsk1 #{bestAsk1}-#{amount1} bestBid2 #{bestBid2}-#{amount2}"
        return {'buy':[[ins[0].price, amount0, ORDER_TYPE], [bestAsk1, amount1], [bestBid2, amount2]]}
    else if ((sellFactor1 < storage.lower_threshold) and (RISK == 3))
        if DEBUG
            debug "sellFactor1: #{sellFactor1} bestAsk0 #{bestAsk0}-#{amount0} bestAsk1 #{bestAsk1}-#{amount1} ins[2].price #{ins[2].price}-#{amount2}"
        return {'buy':[[bestAsk0, amount0], [bestAsk1, amount1], [ins[2].price, amount2, ORDER_TYPE]]}
    else if ((sellFactor2 < storage.lower_threshold) and (RISK == 3))
        if DEBUG
            debug "sellFactor2: #{sellFactor2} ins[0].price #{ins[0].price}-#{amount0} bestAsk1 #{bestAsk1}-#{amount1} ins[2].price #{ins[2].price}-#{amount2}"
        return {'buy':[[ins[0].price, amount0, ORDER_TYPE], [bestAsk1, amount1], [ins[2].price, amount2, ORDER_TYPE]]}
    else
        sleep(resolutionMs)
        storage.iterations--
        return null

###
    function makes Simultaneous trades
    @params - tradeSignal, array of instruments
    @return: number of executed trades (should be 3)
###
makeSimultaneousTrade = (trade, insts) ->
    buySignal = null
    sellSignal = null
    if trade.buy
        side = 'buy'
        arr = trade.buy
    if trade.sell
        side = 'sell'
        arr = trade.sell
    orders = []

    for val, key in arr
        if val[2]
            Type = 'market'
        else
            Type = 'limit'
        if MARKET_ONLY
            Type = 'market'
        if (key == 2)
            if (side == 'buy') #reverse trade
                side = 'sell'
            else if (side == 'sell')
                side = 'buy'

        if DEBUG
            debug "#{side} order#{key} vol #{val[1]} #{insts[key]._pair[0]} at price #{val[0]} #{insts[key]._pair[0]}/#{insts[key]._pair[1]}"
        if (side == 'buy')
            currencyAvailable = @portfolios[insts[key].market].positions[insts[key].curr()].amount
            if (currencyAvailable  < val[1] * val[0])
                if DEBUG
                    debug "not enough currency. have:#{currencyAvailable} needed: #{val[1] * val[0]}"
                break

        if (side == 'sell')
            assetsAvailable = @portfolios[insts[key].market].positions[insts[key].asset()].amount
            if (assetsAvailable < val[1])
                if DEBUG
                    debug "not enough assets:#{assetsAvailable} needed #{val[1]}"
                break

        ord = {
                instrument: insts[key]
                side: side
                type: Type
                amount: val[1]
                price: val[0]
                timeout: TIME_OUT
            }
        orders.push(ord)

    #sanity check
    if (orders.length < 3)
        return 0

    if (trade.sell and (orders[0].side == 'sell') and (orders[1].side == 'sell') and (orders[2].side == 'buy'))
        executed = executeTrade(orders)
    else if (trade.buy and (orders[0].side == 'buy') and (orders[1].side == 'buy') and (orders[2].side == 'sell'))
        executed = executeTrade(orders)
    else
        if DEBUG
            warn "wrong sequence of trades"
        return 0
    return executed
###
    function execute given order
    @params - order
    @return: number of executed trades (should be 3), 0 if error
###
executeTrade = (orders) ->
    counter = 0
    for ord, key in orders
        try
            order = trading.addOrder(ord)
            counter++
        catch e
            if /insufficient funds/i.exec e
                debug "Insufficient funds error"
                return 0
            else if /minimum order/i.exec e
                debug "minimum order amount error"
                return 0
            else
                throw e # rethrow unhandled exception
                return 0
    return counter
###
    function check active orders if they are still active and change order type if needed
    @params - none
    @return: false if no active orders, true if there are
###
checkActiveOrders = (ins) ->
    activeOrders = []
    activeOrders = trading.getActiveOrders()
    if (activeOrders and activeOrders.length)
        stillActive = []
        for activeOrder in activeOrders
            stillActive.push activeOrder.id
        if (stillActive and stillActive.length)
            warn "orders #{stillActive.join(',')} are still active"
        if (storage.TickTimer == 0)
            storage.TickTimer = storage.TICK
        if (storage.TICK == (storage.TickTimer + 2)) #on second tick change it to markert to cut losses
            for order in activeOrders
                if (order and (order.type == 'limit'))
                    debug "changing type of #{order.id} (price:#{order.price}, side:#{order.side}) from #{order.type} to market"
                    if (order.pair == 'btc_usd')
                        instrument = ins[0]
                    else if (order.pair == 'eth_btc')
                        instrument = ins[1]
                    else if (order.pair == 'eth_usd')
                        instrument = ins[2]

                    neworder = trading.addOrder
                        instrument: instrument
                        side: order.side
                        type: 'market'
                        amount: order.amount
                        price: order.price


                    debug "neworder id:#{neworder.id} was submitted"
                    debug "cancelling old order: #{order.id}"
                    trading.cancelOrder(order)
                else
                    debug "cannot get order"
        return true
    else
        storage.TickTimer = 0
        return false
###
    function print debug statements with balance and gain info
    @params - array of instruments
    @return: print debug messages
###
report = (ins) ->
    updateStorage(ins)
    coinName = ins[0]._pair[1].toUpperCase()
    debug "Tick:#{storage.TICK} Balance: #{storage.balance}#{coinName} (before price change:#{storage.realtotal}#{coinName}) Gain/Loss total: #{storage.total_gain}% #{storage.BH}"
###
    function update storage values
    @params - array of instruments
    @return: none
###
updateStorage = (ins) ->
    currency = @portfolios[ins[0].market].positions[ins[0].curr()].amount
    asetts0 = @portfolios[ins[0].market].positions[ins[0].asset()].amount
    asetts1 = @portfolios[ins[1].market].positions[ins[1].asset()].amount
    storage.coin0 = asetts0
    storage.coin0_price = ins[0].price
    storage.coin1 = asetts1
    storage.coin1_price = ins[2].price
    total = (currency + asetts0 * ins[0].price + asetts1 * ins[2].price).toFixed(2)
    realtotal = (currency + asetts0 * storage.coin0_price_ini + asetts1 * storage.coin1_price_ini).toFixed(2)
    storage.realtotal = realtotal
    prev_balance = storage.balance
    storage.balance = total
    tick_gain = ((storage.balance - prev_balance) * 100 / prev_balance).toFixed(2)
    total_gain = ((storage.realtotal - storage.inibalance) * 100 / storage.inibalance).toFixed(2)
    storage.tick_gain = tick_gain
    storage.total_gain = total_gain

    coinName = ins[0]._pair[1].toUpperCase()
    BH1 = ((storage.coin0_price - storage.coin0_price_ini) * 100 / storage.coin0_price_ini).toFixed(2)
    BH2 = ((storage.coin1_price - storage.coin1_price_ini) * 100 / storage.coin1_price_ini).toFixed(2)
    storage.BH = "B&H: #{ins[0]._pair[0].toUpperCase()}:#{BH1}% #{ins[1]._pair[0].toUpperCase()}:#{BH2}%"

###
    function print debug statements with balance and gain info
    @params - array of instruments
    @return: print debug messages
###
iniBalance = (ins) ->
    currency = @portfolios[ins[0].market].positions[ins[0].curr()].amount
    asetts0 = @portfolios[ins[0].market].positions[ins[0].asset()].amount
    asetts1 = @portfolios[ins[1].market].positions[ins[1].asset()].amount
    total = (currency + asetts0 * ins[0].price + asetts1 * ins[2].price).toFixed(2)
    coinName = ins[0]._pair[1].toUpperCase()
    storage.inibalance = total
    storage.coin0_ini = asetts0
    storage.coin0_price_ini = ins[0].price
    storage.coin1_ini = asetts1
    storage.coin1_price_ini = ins[2].price
    debug "Initial Balance: #{currency.toFixed(2)}#{coinName} + #{asetts0.toFixed(4)}#{ins[0]._pair[0].toUpperCase()}(#{(asetts0 * ins[0].price).toFixed(2)}#{coinName}) + #{asetts1.toFixed(4)}#{ins[1]._pair[0].toUpperCase()}(#{(asetts1 * ins[2].price).toFixed(2)}#{coinName}) = #{total}#{coinName}"
    debug "Initial prices: #{asetts0.toFixed(4)}#{ins[0]._pair[0].toUpperCase()} price: #{ins[0].price.toFixed(2)} + #{asetts1.toFixed(4)}#{ins[1]._pair[0].toUpperCase()} price: #{ ins[2].price.toFixed(2)}"
    debug "Tradeable amount: #{storage.minAmount}"
################################ END FUNCTIONS #################################

init: ->
    #This runs once when the bot is started

handle: ->
    FEE = FEES * 3 / 100 # calculated as exchange fees(in %) / 100 * number of transactions (3)
    finishAndStop = 0
    storage.iterations ?= 0
    storage.botStartedAt ?= data.at
    storage.TICK ?= 0
    if CONSERVATIVE
        storage.upper_threshold = UPPER_THRESHOLD
        storage.lower_threshold = LOWER_THRESHOLD
    else
        storage.upper_threshold = 1 + FEE
        storage.lower_threshold = 1 - FEE

    if (storage.TICK == 0)
        ins0 = ds.get 'bitstamp', 'btc_usd', 1 # primary instrument
        ins1 = ds.get 'bitstamp', 'eth_btc', 1
        ins2 = ds.get 'bitstamp', 'eth_usd', 1
        storage.minAmount = findMinTradableAmount([ins0,ins1,ins2])
        inibalance = iniBalance([ins0,ins1,ins2])
        storage.trades = 0

    storage.iterations = ITERATIONS

    for i in [0 .. (storage.iterations - 1)]
        ins0 = ds.get 'bitstamp', 'btc_usd', 1 # primary instrument
        ins1 = ds.get 'bitstamp', 'eth_btc', 1
        ins2 = ds.get 'bitstamp', 'eth_usd', 1

        if TEST_MODE
            oBook0 = {'asks':[[3025.00,0.0298640],[3022.00,1.01654500]],'bids':[[3025.00,0.42307311],[3020.02,2.12444616]]}
            oBook1 = {'asks':[[0.068,0.26600000],[0.06811100,1.98765000]],'bids':[[0.068,1.90000000],[0.06774344,2.86000000]]}
            oBook2 = {'asks':[[212.00,0.00047333],[204.34,49.56100000]],'bids':[[212.00,5.00000000],[205.02,10.89100000]]}
        else
            oBook0 = trading.getOrderBook ins0
            oBook1 = trading.getOrderBook ins1
            oBook2 = trading.getOrderBook ins2

        activeOrders = checkActiveOrders([ins0,ins1,ins2])
        if  (!activeOrders) # do not trade if there are active orders and if storage.trades ==1
            if (oBook0 and oBook1 and oBook2)
                tradeSignal = calculateSignals([oBook0, oBook1, oBook2],[ins0,ins1,ins2])
                if (tradeSignal)
                    report([ins0,ins1,ins2]) #to report just before the trade
                    trades = makeSimultaneousTrade(tradeSignal, [ins0,ins1,ins2])
                    if ((trades < 3) and (trades > 0))
                        warn "only #{trades} orders were executed. Human intervention is required"
                        sendEmail "only #{trades} orders were executed. Human intervention is required"
                        finishAndStop = 1
                    else if DEBUG
                        debug "#{trades} orders were executed."
                    else
                        storage.trades = 1
            else
                warn "Order Book 0:#{oBook0} 1:#{oBook1} 2:#{oBook2} not available"
        else
            report([ins0,ins1,ins2]) #to report after the trade
            break
    #end of for loop
    updateStorage([ins0,ins1,ins2])
    if (storage.TICK % 180) == 0 #frequency of reports,60 - once in an hour
        report([ins0,ins1,ins2])

    if finishAndStop
        stop()
    storage.TICK++

 onRestart: ->
    info "_____  BOT RESTARTED  ______"
    debug "Bot restarted at #{new Date(data.at)}"
    debug "Starting balance: #{storage.inibalance}"
    debug "Ending balance: #{storage.balance}"
    debug "Profit/Loss total: #{storage.profit}%"
    debug "#{storage.BH}"
    debug "_________________________________________________________________"

onStop: ->
    info "_____  BOT STOPED  ____"
    debug "Bot started at #{new Date(storage.botStartedAt)}"
    debug "Bot stopped at #{new Date(data.at)}"
    debug "Starting balance: #{storage.inibalance}"
    debug "Ending balance: #{storage.balance}"
    warn "Profit/Loss total (at initial prices): #{storage.total_gain}%"
    debug "#{storage.BH}"
    debug "_________________________________________________________________"


 

