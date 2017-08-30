# SUPER SMOOTH FILTER (2-POLE/3-POLE)
# DERIVED FROM 'Cybernetic Analysis for Stocks and Futures'
# 15/07/2014

class SUPER_TWO_POLE
    constructor: (@period) ->
        @price_array = []
        @smooth_array = []
        @count = 0
        
        # INITIALIZE ARRAYS
        for [@price_array.length..3]
            @price_array.push 0
            
        for [@smooth_array.length..3]
            @smooth_array.push 0
        
    calculate: (instrument) ->
        
        # HIGH/LOW
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        price_average = (high+low)/2
        
        # INCREASE DATA COUNT
        @count++
        
        # REMOVE OLD DATA
        @price_array.pop()
        @smooth_array.pop()
        
        # ADD NEW DATA
        @price_array.unshift(price_average)
        @smooth_array.unshift(0)
        
        # CALCULATE
        a = Math.exp(-1.414*3.14159/@period)
        b = 2*a*Math.cos((1.414*180/@period)*(Math.PI/180))
        c = -a*a
        d = 1 - b - c
        
        if @count < 3
            @smooth_array[0] = @price_array[0]
        else
            @smooth_array[0] = (d * @price_array[0]) + (b * @smooth_array[1]) + (c * @smooth_array[2])

        
        # RETURN SMOOTHED DATA
        return @smooth_array[0]

class SUPER_THREE_POLE
    constructor: (@period) ->
        @price_array = []
        @smooth_array = []
        @count = 0
        
        # INITIALIZE ARRAYS
        for [@price_array.length..4]
            @price_array.push 0
        
        for [@smooth_array.length..4]
            @smooth_array.push 0
        
    calculate: (instrument) ->
        
        # HIGH/LOW
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        price_average = (high+low)/2
        
        # INCREASE DATA COUNT
        @count++
        
        # REMOVE OLD DATA
        @price_array.pop()
        @smooth_array.pop()
        
        # ADD NEW DATA
        @price_array.unshift(price_average)
        @smooth_array.unshift(0)
        
        # CALCULATE
        a = Math.exp(-3.14159/@period)
        b = 2*a*Math.cos((1.738*180/@period)*(Math.PI/180))
        c = a*a
        d = b+c
        e = -(c+b*c)
        f = c*c
        g = 1 - d - e - f
        
        if @count < 4
            @smooth_array[0] = @price_array[0]
        else
            @smooth_array[0] = (g * @price_array[0]) + (d * @smooth_array[1]) + (e * @smooth_array[2]) + (f * @smooth_array[3])
        
        # RETURN SMOOTHED DATA
        return @smooth_array[0]
        
init: (context)->
    
    context.two = new SUPER_TWO_POLE(15)
    context.three = new SUPER_THREE_POLE(15)

handle: (context, data)->
    instrument = data.instruments[0]
    
    supertwo = context.two.calculate(instrument)
    superthree = context.three.calculate(instrument)

    plot
        supertwo: supertwo
        superthree: superthree