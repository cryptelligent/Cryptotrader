###
Robbery
by aspiramedia (converted from this by ucsgears and originally by Steve Primo: https://www.tradingview.com/v/Q63cAkgW/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

###
petd = ema(close, 15)
up = close > petd ? green : red
###

class ROBBERY
    constructor: (@period) ->

        @count = 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]

        # CALCULATE
        petd = instrument.ema(@period)

        if close > petd
            direction = 1
            plotMark
                "up": close
        else
            direction = 0  
            plotMark
                "down": close      
        
        # TEMP DEBUG

        
        

        # RETURN DATA
        result =
            direction: direction
            petd: petd

        return result 
      

init: (context)->
    
    context.robbery = new ROBBERY(15)

    # FOR FINALISE STATS
    context.balance_curr = 0
    context.balance_btc = 0
    context.price = 0


handle: (context, data)->

    instrument = data.instruments[0]
    price = instrument.close[instrument.close.length - 1]

    # FOR FINALISE STATS
    context.price = instrument.close[instrument.close.length - 1]
    context.balance_curr = portfolio.positions[instrument.curr()].amount
    context.balance_btc = portfolio.positions[instrument.asset()].amount

    # CALLING INDICATORS
    robbery = context.robbery.calculate(instrument)
    direction = robbery.direction
    petd = robbery.petd
    
    # TRADING
    if direction == 1
        buy instrument
    else
        sell instrument

    
    # PLOTTING / DEBUG
    plot
        direction: direction
        petd: petd
    setPlotOptions
        direction:
            secondary: true
            lineWidth: 3
            color: 'blue'
        up: 
            color: 'green'
        down:
            color: 'red'




    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc