###
	Chaikin Money Flow Indicator
	by Thanasis
	see https://cryptotrader.org/topics/647771/chaikin-money-flow
###
init: (context)->

    context.period  =  20

handle: (context, data)->

    instrument  =   data.instruments[0]
    period      =   context.period

    A  =  0
    B  =  0

    for n in [1 .. context.period]
        price      =   instrument.close[instrument.close.length - n]
        open       =   instrument.open[instrument.open.length - n]
        high       =   instrument.high[instrument.high.length - n]
        low        =   instrument.low[instrument.low.length - n]
        close      =   instrument.close[instrument.close.length - n]
        volume     =   instrument.volumes[instrument.volumes.length - n]

        A   =  A + volume * [(close - low) - (high - close)] /(high - low)
        B   =  B + volume

    CMF = A / B

    debug "CMF : #{CMF}"
