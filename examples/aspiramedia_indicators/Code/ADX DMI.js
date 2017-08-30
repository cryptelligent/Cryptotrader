###
ADX DMI
As shown here: http://www.signalstrengthfinance.com/better-know-an-indicator-adx/
aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

init: (context)->
  
    context.adxperiod = 10
    context.dmiperiod = 10
   
handle: (context, data)->

    instrument  =   data.instruments[0]
    price       =   instrument.close[instrument.close.length - 1]
    adxperiod   =   context.adxperiod
    dmiperiod   =   context.dmiperiod

    ADX = talib.ADX
      high: instrument.high
      low: instrument.low
      close: instrument.close
      startIdx: 0
      endIdx: instrument.close.length - 1
      optInTimePeriod: adxperiod
    adx = _.last(ADX)

    DMPLUS = talib.PLUS_DM
      high: instrument.high
      low: instrument.low
      startIdx: 0
      endIdx: instrument.close.length - 1
      optInTimePeriod: dmiperiod
    dmplus = _.last(DMPLUS)

    DMMINUS = talib.MINUS_DM
      high: instrument.high
      low: instrument.low
      startIdx: 0
      endIdx: instrument.close.length - 1
      optInTimePeriod: dmiperiod
    dmminus = _.last(DMMINUS)

    plot
      adx: adx
      dmplus: dmplus
      dmminus: dmminus

    if adx > 20
      if dmplus > dmminus
        buy instrument
      if dmplus < dmminus
        sell instrument
