###
ChaosBot
https://cryptotrader.org/strategies/KETXmtygtCdfHcnpH
A very simple bot using a custom indicator discovered by ChaosHunter. This bot works nearly equally well on Bitstamp, BTC-E or Kraken with daily ticks.

ChaosHunter input was an ms-dos .csv file containing the OHLC day charts of the Coindesk BPI from Jan 1 2014 to Aug 1. All four columns were selected as input with close as the output column.

WIth an 8core 16gig machine, I overdrove most of the settings and let it optimize in evolution mode overnight.
This is the result.

###
###
  CHAOS TRADING ALGORITHM
###

#
init: (context)->
    context.buy_threshold = 2.4721
    context.sell_threshold = 0.774749

#
handle: (context, data, storage)->
    instrument = data.instruments[0]

    signal = 1 / ((((instrument.close[instrument.close.length-1] - instrument.close[instrument.close.length-13]) / 13) - ((instrument.close[instrument.close.length-13] - instrument.close[instrument.close.length-26]) / 13)) / 13)

    if signal >= context.buy_threshold
        buy instrument

    if signal <= context.sell_threshold
        sell instrument
