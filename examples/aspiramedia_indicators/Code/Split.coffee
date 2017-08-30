class FUNCTIONS
    
    @SPLIT: (instrument, balance_curr, balance_btc) ->
        price = instrument.price

        if balance_curr > (balance_btc * price)
            curr_surplus = balance_curr - (balance_btc * price)
            buy_amount = curr_surplus / 2 
            buy instrument,buy_amount,price,60
        if balance_curr > (balance_btc * price)
            curr_surplus = balance_curr - (balance_btc * price)
            curr_sell = curr_surplus / 2 
            sell instrument,null,price,60


        return

init: (context)->

    # FOR FINALISE STATS
    context.balance_curr = 0
    context.balance_btc = 0
    context.price = 0


handle: (context, data, storage)->

    instrument = data.instruments[0]

    if instrument.ema(10) > instrument.ema(21)
        FUNCTIONS.SPLIT(instrument, portfolio.positions[instrument.curr()].amount, portfolio.positions[instrument.asset()].amount)