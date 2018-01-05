### see: https://cryptotrader.org/backtests/SHoCeZKqfCRFMom3H
init: (context)->

    context.sar_A_accel = 0.02
    context.sar_A_max = 0.2
    context.sar_B_accel = 0.01
    context.sar_B_max = 0.1
    context.sar_C_accel = 0.005
    context.sar_C_max = 0.05
    context.sar_D_accel = 0.0025
    context.sar_D_max = 0.025
    context.sar_E_accel = 0.00125
    context.sar_E_max = 0.0125  
    context.sar_F_accel = 0.000625
    context.sar_F_max = 0.00625    
    
handle: (context, data)->
    instrument = data.instruments[0]
    

    
    sar_A = talib.SAR
        high: instrument.high
        low: instrument.low
        startIdx: 0
        endIdx: instrument.high.length - 1
        optInAcceleration: context.sar_A_accel
        optInMaximum: context.sar_A_max
    sar_A_last = _.last(sar_A)

    sar_B = talib.SAR
        high: instrument.high
        low: instrument.low
        startIdx: 0
        endIdx: instrument.high.length - 1
        optInAcceleration: context.sar_B_accel
        optInMaximum: context.sar_B_max
    sar_B_last = _.last(sar_B)
    
    
    sar_C = talib.SAR
        high: instrument.high
        low: instrument.low
        startIdx: 0
        endIdx: instrument.high.length - 1
        optInAcceleration: context.sar_C_accel
        optInMaximum: context.sar_C_max
    sar_C_last = _.last(sar_C)   
    
    sar_D = talib.SAR
        high: instrument.high
        low: instrument.low
        startIdx: 0
        endIdx: instrument.high.length - 1
        optInAcceleration: context.sar_D_accel
        optInMaximum: context.sar_D_max
    sar_D_last = _.last(sar_D)    
    
    sar_E = talib.SAR
        high: instrument.high
        low: instrument.low
        startIdx: 0
        endIdx: instrument.high.length - 1
        optInAcceleration: context.sar_E_accel
        optInMaximum: context.sar_E_max
    sar_E_last = _.last(sar_E)   
    
    sar_F = talib.SAR
        high: instrument.high
        low: instrument.low
        startIdx: 0
        endIdx: instrument.high.length - 1
        optInAcceleration: context.sar_F_accel
        optInMaximum: context.sar_F_max
    sar_F_last = _.last(sar_F)   

    
    PRICE = instrument.ema(2)
     
    if PRICE > sar_D_last
        buy instrument
    else if PRICE < sar_D_last
        sell instrument
        
    plot
        SAR_A: sar_A_last
        SAR_B: sar_B_last
        SAR_C: sar_C_last
        SAR_D: sar_D_last
        SAR_E: sar_E_last
        SAR_F: sar_F_last        
