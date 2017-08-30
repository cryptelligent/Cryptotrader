###
Bulkowski NR7/NR4 pattern identifier 
by aspiramedia (based on LazyBear's awesome work at TradingView: https://www.tradingview.com/v/4IneGo8h/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

class Bulkowsky
    constructor: () ->
        @range_array = []
        @count = 0
        
        # INITIALIZE ARRAYS
        for [@range_array.length..10]
            @range_array.push 0
        
    calculate: (instrument) ->

        # INCREASE DATA COUNT
        @count++
        
        # REMOVE OLD DATA
        @range_array.pop()

        # ADD NEW DATA
        @range_array.unshift(0)

        # CALCULATE        
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        nr4 = false
        nr7 = false

        @range_array[0] = high - low       

        if (@range_array[0] < @range_array[1]) and (@range_array[0] < @range_array[2]) and (@range_array[0] < @range_array[3])
            nr4 = true

        if (@range_array[0] < @range_array[1]) and (@range_array[0] < @range_array[2]) and (@range_array[0] < @range_array[3]) and (@range_array[0] < @range_array[4]) and (@range_array[0] < @range_array[5]) and (@range_array[0] < @range_array[6])
            nr7 = true


        # RETURN DATA
        result =
            nr4: nr4
            nr7: nr7

        return result 
      
init: (context)->
    
    context.bulkowsky = new Bulkowsky()

    # For finalise stats
    context.balance_curr = 0
    context.balance_btc = 0
    context.price = 0

handle: (context, data)->

    instrument = data.instruments[0]
    price = instrument.close[instrument.close.length - 1]

    # For finalise stats
    context.price = instrument.close[instrument.close.length - 1]
    context.balance_curr = portfolio.positions[instrument.curr()].amount
    context.balance_btc = portfolio.positions[instrument.asset()].amount

    bulkowsky = context.bulkowsky.calculate(instrument)
    nr4 = bulkowsky.nr4
    nr7 = bulkowsky.nr7

    plot
        nr4: nr4
        nr7: nr7
    setPlotOptions
        nr4:
          secondary: true
        nr7:
          secondary: true
    
finalize: (contex, data)-> 

    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc