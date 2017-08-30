# LEADING DIFF
# V1: https://cryptotrader.org/backtests/iECWSnZtMMypooJwk
# LTC/BTC: https://cryptotrader.org/backtests/RtX8Q97Mx2jgY4KFr

###
PSEUDO CODE:
Vars: Lead(0),
alpha1(.25),
alpha2(.33);
NetLead(0),
EMA(0);
Lead = 2*Price +(alpha1 - 2)*Price[1] 
+ (1 - alpha1)*Lead[1];
NetLead = alpha2*Lead + (1 - alpha2)*NetLead[1];
EMA = .5*Price + .5*EMA[1];
Plot1(NetLead, “Lead”);
Plot2(EMA, “EMA”);
###

class LEAD
    constructor: () ->
        @price_array = []
        @lead_array = []
        @net_array = []
        @ema_array = []
        @diff_array = []
        @count = 0
        
        # INITIALIZE ARRAYS
        for [@price_array.length..3]
            @price_array.push 0
            
        for [@lead_array.length..3]
            @lead_array.push 0

        for [@net_array.length..3]
            @net_array.push 0

        for [@ema_array.length..3]
            @ema_array.push 0

        for [@diff_array.length..3]
            @diff_array.push 0
        
    calculate: (instrument) ->

        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]
        price_average = (high+low)/2

        # INCREASE DATA COUNT
        @count++
        
        # REMOVE OLD DATA
        @price_array.pop()
        @lead_array.pop()
        @net_array.pop()
        @diff_array.pop()

        # ADD NEW DATA
        @price_array.unshift(price_average)
        @lead_array.unshift(0)
        @net_array.unshift(0)
        @ema_array.unshift(0)
        @diff_array.unshift(0)

        # CALCULATE
        a1 = 0.25
        a2 = 0.33
        @lead_array[0] = (2 * @price_array[0]) + ((a1 - 2) * @price_array[1]) + ((1 - a1) * @lead_array[1])
        @ema_array[0] = (0.5 * @price_array[0]) + (0.5 * @ema_array[1])

        if @count < 3
            @net_array[0] = @price_array[0]
        else
            @net_array[0] = (a2 * @lead_array[0]) + ((1 - a2) * @net_array[1])
        
        @diff_array[0] = @net_array[0] - @ema_array[0]

        result =
            lead: @net_array
            ema: @ema_array
            diff: @diff_array

        return result
      
init: (context)->
    
    context.lead = new LEAD()

handle: (context, data)->
    instrument = data.instruments[0]
    
    lead = context.lead.calculate(instrument)

    plot
        lead: lead.lead[0]
        ema: lead.ema[0]
        diff: lead.diff[0]
    setPlotOptions
        diff:
          secondary: true

    if lead.diff[0] > (lead.diff[1] * 1.1) > lead.ema[0] - lead.ema[1]
        buy instrument
    if lead.diff[0] < (lead.diff[1] / 1.1) < lead.ema[0] - lead.ema[1]
        sell instrument