###
  see also:https://cryptotrader.org/topics/147866/feature-request-sell-stop-orders
  
  The script engine is based on CoffeeScript (http://coffeescript.org)
  The Cryptotrader API documentation is available at https://cryptotrader.org/api
  
  The margin trading module enables leveraged trading for opening either long or short position
  
###

mt = require 'margin_trading' # import margin trading module 
talib = require 'talib'  # import technical indicators library (https://cryptotrader.org/talib)


init: -> 
    # note that init and handle methods don't need arguments
    # @data, @storage and @context can be accessed from anywhere in the code
    @context.invested = false


handle: ->
    instrument = @data.instruments[0]
    info = mt.getMarginInfo instrument
    debug "price: #{instrument.price} margin balance: #{info.margin_balance} tradeable balance: #{info.tradable_balance}"

    pos = mt.getPosition instrument
    # check if position is open
    if pos
        debug "position: #{pos.amount} at #{pos.price}"
    unless @context.invested
        try 
            price = instrument.price
            # open short position
            if mt.buy instrument, 'limit', info.tradable_balance / price,price,instrument.interval * 60
                pos = mt.getPosition instrument   
                debug "New position: #{pos.amount}"
                @context.invested = true
                amount = Math.abs(pos.amount) 
                # addOrder takes single object as argument
                takeProfitOrder = mt.addOrder 
                    instrument: instrument
                    side: 'sell'
                    type: 'limit'
                    amount: amount
                    price: instrument.price * 1.25

                @storage.takeProfitOrder = takeProfitOrder.id 
                stopOrder = mt.addOrder 
                    instrument: instrument
                    side: 'sell'
                    type: 'stop'
                    amount: amount
                    price: instrument.price * 0.98
        catch e 
            # the exception will be thrown if funds are not enough
            if /insufficient funds/.exec e
                error "insufficient funds"
            else
                throw e # it is important to rethrow an unhandled exception

onStop: ->
    instrument = @data.instruments[0]
    # unlike orders open positions don't get cancelled when the bot is stopped
    # the below snippet can be used to programmatically close it
    pos = mt.getPosition instrument
    if pos
        debug "Closing position"
        mt.closePosition instrument 

            
            
            
          
