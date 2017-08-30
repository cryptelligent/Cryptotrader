#   SimonSays Simple Stoploss v1.2

#   MultiMode
#      Set context.strategy based on your desired operation.
#      1 = can buy only (start with fiat)
#      0 = can buy or sell - be careful of bandwidth on buy/sell price - multiple trades possible
#      1 = can sell only (start with coin)

#   Donations: BTC: 1CrEkrA6x5kmkUGA13brXEQs2ssXqfGcbx

init: (context)->

## USER INPUT VARIABLES

    context.buyprice = 810      #stop loss buy price
    context.sellprice = 800     #stop loss sell price
    context.strategy = 0        #indicates starting position. to allow 1 trade start with 1 == fiat or -1 == coin.  Otherwise 0 == will allow subsequnt orders

    # HOW MUCH DO YOU WANT TO BUY/SELL AT A TIME? (portion of portfolio)
    context.sell_portion = .5   # 0-1 indicates 0-100% of current holdings on market
    context.buy_portion = .5    # 0-1 indicates 0-100% of current holdings on market

    # IF THE BOT BUYS/SELLS - WILL YOU ALLOW IT TO CONTINUE BUYING/SELLING?  SET TO FALSE IF YOU WANT TO STOP AFTER BUY/SELL
    context.allow_subsequent_buys = true
    context.allow_subseqent_sells = true

    # THIS SETS INITIAL POSITION.  START WITH TRUE
    context.bought = true
    context.sold = true

# DO NOT MESS WITH ANYTHING BELOW:
serialize: (context)->

    bought:context.bought
    sold:context.sold


handle: (context, data)->

    instrument = data.instruments[0]
    balance = (portfolio.positions[instrument.asset()].amount.toFixed(2))       #   Coin balance
    Currbalance = portfolio.positions[instrument.curr()].amount                 #   Derived Currency Balance
    Price = (instrument.price.toFixed(2))                                       #   Closing price

# REPORT BALANCES AND PRICE
    debug 'P: ' + Price + ' | ' + 'USD: ' + (Currbalance.toFixed(3)) + ' | ฿ : '  + balance + '฿ | '

    if _.last(instrument.close) > context.buyprice && context.strategy  >= 0
        if context.bought == false or context.allow_subsequent_buys == true
            if buy(instrument, balance*context.buy_portion,null,null)
                context.bought = true
                context.sold = false

    if _.last(instrument.close) < context.sellprice && context.strategy <= 0
        if context.sold == false or context.allow_subsequent_sells == true
            if sell(instrument, balance*context.buy_portion,null,null)
                context.sold = true
                context.bought = false
