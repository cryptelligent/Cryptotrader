###########################################################  
#
# Thanasis      utility backtest of max profitability code
#
# Full name:    Thanasis Efthymiou
#
# BTC:          1CRSH4LGGRWVWqgwfquky2Rk5eJK6gsyus
#
# e-mail:       cryptotrader.thanasis@gmail.com
#
###########################################################
#see also https://cryptotrader.org/topics/470887/thanasis-backtest-utility-code-of-max-profitability

class Init

  @init_context: (context) ->
   
    context.k   =   1
    context.m   =   0
    context.have_fiat  = false   
    context.have_coins = true 

class functions
      
  @percent: (x,y) ->

    ((x-y)/y) * 100
    
  
init: (context) ->

    Init.init_context(context)


serialize: (context)->
    k                  :   context.k
    m                  :   context.m 
    first_price_found  :   context.first_price_found
    first_capital      :   context.first_capital
    have_fiat          :   context.have_fiat
    have_coins         :   context.have_coins 


handle: (context, data)->

    instrument        =   data.instruments[0]
    price            =   instrument.close[instrument.close.length - 1]
    high_1            =   instrument.high[instrument.close.length - 1]
    high_2            =   instrument.high[instrument.close.length - 2]
    high_3            =   instrument.high[instrument.close.length - 3]
    low_1             =   instrument.low[instrument.close.length - 1]  
    low_2             =   instrument.low[instrument.close.length - 2]    
    low_3             =   instrument.low[instrument.close.length - 3] 

    
    unless context.first_price_found
      context.first_price = price
      fiat  =  portfolio.positions[instrument.curr()].amount
      coins =  portfolio.positions[instrument.asset()].amount
      context.first_capital =  fiat + coins * price
      if  low_2 <= low_3
          context.m = context.m + 1    
          context.have_fiat  = false 
          context.have_coins = true
          debug "SELL"         
        else if high_2 >= high_3
               context.m  = context.m + 1
               context.have_fiat  = true
               context.have_coins = false
               debug "BUY" 
      context.first_price_found   =  true





    if high_2 > high_3 and  high_2 > high_1  and context.have_coins = true
         context.k  = context.k * (1 + functions.percent(high_2, high_3)/100)
         context.m  = context.m + 1
         context.have_fiat  = true
         context.have_coins = false
         debug "SELL"
       else if low_2 < low_3 and   low_2 < low_1 and context.have_fiat  = true
            context.k = context.k * (1 - functions.percent(low_2, low_3)/100)
            context.m = context.m + 1    
            context.have_fiat  = false 
            context.have_coins = true
            debug "BUY"
  
    


    percent_buy_and_hold  =  functions.percent(price, context.first_price)
    percent_bot           =  100 * (context.k - 1) 
    bot_capital           =  context.k * context.first_capital
    buy_and_hold_capital  =  (1 + percent_buy_and_hold / 100)  * context.first_capital

    percent_buy_and_hold  =  Math.round(100 * percent_buy_and_hold)/100
    percent_bot           =  Math.round(100 * percent_bot) / 100
    context.first_capital =  Math.round(100 * context.first_capital) / 100
    bot_capital           =  Math.round(100 * bot_capital) / 100
    buy_and_hold_capital  =  Math.round(100 * buy_and_hold_capital) / 100

    debug "Total number of Buy/Sell orders : #{context.m}"
    debug "Start Capital :#{context.first_capital} "
    debug "Bot Last Capital : #{bot_capital}  ||||  B/H last Capital : #{buy_and_hold_capital}"
    debug "Bot efficiency :#{percent_bot} %   ||||  B/H efficiency : #{percent_buy_and_hold} %"

