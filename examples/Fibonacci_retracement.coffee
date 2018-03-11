https://cryptotrader.org/topics/407190/new-well-performing-trading-algorythm-fibonacci-example
#########################################################################
#                                                                       #
#   Algorythm based on the Fibonacci retracement by Metatron            #
#                                                                       #
#   If you like the algorythm i would really appreciate a donation!     #
#                                                                       #
#   BTC: 1KMemryoiygLd9vYoHh2hkNckjfs3ZN2yK                             #  
#                                                                       #
#   LTC: LWR81YRLveRLx2NVjYmcKUcpiTfSADjRvv                             #
#                                                                       #
#########################################################################

init: (context)->
    context.fibonacci_min = 770
    context.fibonacci_max = 1090
    
    context.ema_period_short = 2
    context.ema_period_long = 9
    
handle: (context, data)->
    instrument = data.instruments[0]

    max = context.fibonacci_max
    min = context.fibonacci_min
    
    ema_short = instrument.ema(context.ema_period_short)
    ema_long = instrument.ema(context.ema_period_long)
    
    fibonacci_38 = (max - min) * (1 - 0.382) + min
    fibonacci_50 = (max - min) * 0.5 + min
    fibonacci_61 = (max - min) * (1 - 0.618) + min
    
    price = instrument.price
    
    plot
        max: max
        min: min
        ema_short: ema_short
        ema_long: ema_long
        "38": (max - min) * (1 - 0.382) + min
        "50": (max - min) * 0.5 + min
        "61": (max - min) * (1 - 0.618) + min

    if ema_short < fibonacci_61
        buy instrument, null, price, 290
    
    if ema_short > fibonacci_38 and ema_long > ema_short
        sell instrument, null, price, 290
