###
Simple EMA Crossover with user parameters
aspiramedia
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

SHORT = askParam 'Short EMA', 10
LONG = askParam 'Long EMA', 21

init: (context)->

handle: (context, data)->

    instrument  =   data.instruments[0]
    price       =   instrument.close[instrument.close.length - 1]

    short = instrument.ema(SHORT)
    long = instrument.ema(LONG)

    plot
        Short: short
        Long: long

    if short > long
      buy instrument
    if short < long
      sell instrument