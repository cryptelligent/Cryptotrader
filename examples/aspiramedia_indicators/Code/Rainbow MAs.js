###
Rainbow MAs Wave
by aspiramedia
BTC: 1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
Inspired by lazybear: https://www.tradingview.com/v/gWYg0ti0/
###


init: (context)->

  context.up = false
  context.down = false

handle: (context, data)->

    instrument = data.instruments[0]
    
    SMA1 = talib.SMA
      inReal: instrument.close
      startIdx: 0
      endIdx: instrument.close.length - 1
      optInTimePeriod: 2
    sma1 = _.last(SMA1)

    SMA2 = talib.SMA
      inReal: SMA1
      startIdx: 0
      endIdx: SMA1.length - 1
      optInTimePeriod: 2
    sma2 = _.last(SMA2)

    SMA3 = talib.SMA
      inReal: SMA2
      startIdx: 0
      endIdx: SMA2.length - 1
      optInTimePeriod: 2
    sma3 = _.last(SMA3)

    SMA4 = talib.SMA
      inReal: SMA3
      startIdx: 0
      endIdx: SMA3.length - 1
      optInTimePeriod: 2
    sma4 = _.last(SMA4)

    SMA5 = talib.SMA
      inReal: SMA4
      startIdx: 0
      endIdx: SMA4.length - 1
      optInTimePeriod: 2
    sma5 = _.last(SMA5)

    plot
        sma1: sma1
        sma2: sma2
        sma3: sma3
        sma4: sma4
        sma5: sma5
        up: context.up
        down: context.down
    setPlotOptions
        up:
          secondary: true
          color: 'green'
        down:
          secondary: true
          color: 'red'

    if (sma1 > sma2) && (sma2 > sma3) && (sma3 > sma4) && (sma4 > sma5)
      context.up = true
      buy instrument
    else
      context.up = false
    if (sma1 < sma2) && (sma2 < sma3) && (sma3 < sma4) && (sma4 < sma5)
      context.down = true
      sell instrument
    else context.down = false