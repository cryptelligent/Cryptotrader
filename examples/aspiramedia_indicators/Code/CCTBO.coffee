###
CCT Bollinger Band Oscillator (CCTBO)
aspiramedia (https://cryptotrader.org/aspiramedia)
BTC: 1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74

Originally by lazybear: https://www.tradingview.com/v/iA4XGCJW/
###


init: (context)->

  context.period = 21
  context.NbDev  = 1

handle: (context, data)->

    instrument =  data.instruments[0]
    
    close      =  instrument.close[instrument.close.length - 1]
    
    SMA = talib.SMA
      inReal: instrument.close
      startIdx: 0
      endIdx: instrument.close.length - 1
      optInTimePeriod: context.period
    sma = _.last(SMA)

    STDDEV = talib.STDDEV
      inReal: instrument.close
      startIdx: 0
      endIdx: instrument.close.length - 1
      optInTimePeriod: context.period
      optInNbDev: context.NbDev
    stddev = _.last(STDDEV)

    cctbbo = 100 * (close + 2 * stddev - sma) / (4 * stddev)

    plot
      cctbbo: cctbbo
    setPlotOptions
      cctbbo:
        secondary: true