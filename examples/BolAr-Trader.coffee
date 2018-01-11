see also: https://cryptotrader.org/topics/407190/new-well-performing-trading-algorythm-fibonacci-example
#########################################################################
#                                                                       #
#                   BolAr-Trader by Metatron                            #
#                                                                       #
#   If you like the Bot i would really appreciate a donation!           #
#                                                                       #
#   BTC: 1KMemryoiygLd9vYoHh2hkNckjfs3ZN2yK                             #  
#                                                                       #
#   LTC: LWR81YRLveRLx2NVjYmcKUcpiTfSADjRvv                             #
#                                                                       #
#########################################################################

init: (context)->
    context.BBANDS_period = 20
    
    context.aroon_period = 240
    context.aroon_diff = 35
    
handle: (context, data)->
    instrument = data.instruments[0]
    
    #Aroon
    AROONresults = talib.AROON
        high: instrument.high
        low: instrument.low
        startIdx: 0
        endIdx: instrument.close.length-1
        optInTimePeriod: context.aroon_period
    AroonUp = _.last(AROONresults.outAroonUp)
    AroonDown = _.last(AROONresults.outAroonDown)
	
    #Bollinger Bands
    BBANDSresult = talib.BBANDS
        inReal: instrument.close
        startIdx: 0
        endIdx: instrument.close.length-1
        optInTimePeriod: context.BBANDS_period
        optInNbDevUp: 2
        optInNbDevDn: 2
        optInMAType: 1
    bbandsupper = _.last BBANDSresult.outRealUpperBand
    bbandsmiddle = _.last BBANDSresult.outRealMiddleBand
    bbandslower = _.last BBANDSresult.outRealLowerBand
	
    balance_curr = portfolio.positions[instrument.curr()].amount
    balance_btc = portfolio.positions[instrument.asset()].amount
    price = instrument.price
	
    plot
        Bollinger_supper: bbandsupper
        Bollinger_middle:bbandsmiddle
        Bollinger_lower: bbandslower
        AroonUp: AroonUp + 850
        AroonDown: AroonDown + 850

    
    if price < bbandslower and AroonUp - AroonDown > context.aroon_diff and balance_curr > 10
        buy instrument, null, price, 60
        #debug balance_curr

    if price > bbandsupper and AroonDown - AroonUp > context.aroon_diff and balance_btc > 0.01
        sell instrument, null, price, 60
        #debug balance_btc
