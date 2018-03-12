# Thanasis Stop Loss - Scrubbed by Litepresence
# see also https://cryptotrader.org/topics/746664/thanasis-trailing-stop-loss
class Init
  @init_context: (context) ->
    context.zig_zag_threshold   =  0.015   #%
    context.stop_percent        =  0.065   #
    context.stop                      =   0
    context.price_buy                 =   0
    context.price_sell                =   0 
    context.first_price               =   0
class ZigZag
    constructor: (@threshold) ->
        @data = 0.0
        @zigzag = 0.0
    filter: (@data) ->
        if @zigzag == 0.0
            @zigzag = @data
        d = (@data/@zigzag)-1
        if (d >= @threshold) or (d <= -@threshold)
            @zigzag = @data
        return @zigzag
init: (context) ->
  Init.init_context(context)
  context.zigzag = new ZigZag(context.zig_zag_threshold) 
serialize: (context)->
    stop_loss_buy       :   context.stop
    first_price        :   context.first_price
    
handle: (context, data)->
    instrument =  data.instruments[0]
    price      =  instrument.close[instrument.close.length - 1]
    unless context.first_price_found
      context.first_price           =  price
      fiat                          =  portfolio.positions[instrument.curr()].amount
      coins                         =  portfolio.positions[instrument.asset()].amount
      context.first_capital         =  fiat + coins * price
      maximum = Math.max(fiat, coins * price)
      if maximum == fiat
         context.have_fiat          = true
         context.have_coins         = false 
      else 
         context.have_fiat          = false
         context.have_coins         = true  
      context.first_price_found     = true
    fiat     =  portfolio.positions[instrument.curr()].amount
    coins    =  portfolio.positions[instrument.asset()].amount
    capital  =  fiat + coins * price
    buy_signal   =  off
    sell_signal  =  off
    if context.have_fiat == true
      if context.zigzag.filter(instrument.price)   >  context.stop
        buy_signal   =  on
        sell_signal  =  off
        context.stop =  context.zigzag.filter(instrument.price)  - context.stop_percent * price  
      else if context.stop > context.zigzag.filter(instrument.price)  + context.stop_percent * price
        context.stop =  context.zigzag.filter(instrument.price)  + context.stop_percent * price
    if context.have_coins ==  true   
      if   context.zigzag.filter(instrument.price) <  context.stop
        buy_signal   =  off
        sell_signal  =  on
        context.stop =   context.zigzag.filter(instrument.price) + context.stop_percent * price  
      else if context.stop <  context.zigzag.filter(instrument.price)  - context.stop_percent * price
        context.stop =  context.zigzag.filter(instrument.price)  - context.stop_percent * price 
    if buy_signal and fiat > 10
        if context.have_fiat
           buy instrument, null, price * 1.001, 295
           context.have_coins          =  true
           context.have_fiat           =  false
    if sell_signal
        if context.have_coins 
           sell instrument, null, price * 0.999, 295
           context.have_coins          =  false
           context.have_fiat           =  true
    plot 
        zigzag: context.zigzag.filter(instrument.price)    
        stop: context.stop


   
 
    

    
    
