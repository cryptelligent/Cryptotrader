#See also: https://cryptotrader.org/topics/173357/aggregated-candles-and-smoothed-indicators
#by tweakaholic 

TICKLENGTH  =   15              #Current period in minutes
AGGREGATION =   240

##################################################################################################

class FUNCTIONS
    @aggregate: (array, ratio) ->
        if ratio==1
            result=array
        else
            result=[]
            for i in [array.length-1...0] by -ratio
                result.unshift(array[i])
        result

    @DIFF: (a, b) ->
        100*(a-b)/((a+b)/2)

    @EMA: (data, period) ->
        results = talib.EMA
            inReal: data
            startIdx: 0
            endIdx: data.length - 1
            optInTimePeriod: period

    @smooth: (label, array, ratio) ->
        
        if ratio == 1
            array
        else
            key = label+'s_smooth'
            debug key
            storage[key] = storage[key] or -1
            
            if storage[key] == -1
                    # MA_Type: 0=SMA, 1=EMA, 2=WMA, 3=DEMA, 4=TEMA, 5=TRIMA, 6=KAMA, 7=MAMA, 8=T3 (Default=SMA)
                storage[key] = [
                    array, 
                
                    talib.MA({
                        inReal: array
                        startIdx: 0
                        endIdx: array.length - 1
                        optInTimePeriod: ratio
                        optInMAType: 0
                    })
                ]
            else
                storage[key][0].push(_.last(array))
                storage[key][0] = _.last(storage[key][0], ratio)
                storage[key][1].push((storage[key][0].reduce (x, y) -> x + y) / ratio)
                storage[key][1] = _.last(storage[key][1], 250)
        
            return storage[key][1]        

init: (context)->

handle: (context, data, storage)->
    
    ins = data.instruments[0]
    price = ins.price
    curr = portfolio.positions[ins.curr()].amount
    assets = portfolio.positions[ins.asset()].amount
    
    # CALLING INDICATORS
    ratio       =   AGGREGATION/TICKLENGTH
    close_agg   =   FUNCTIONS.aggregate(ins.close,ratio)
    ema         =   FUNCTIONS.EMA(close_agg,10)
    smooth_ema  =   FUNCTIONS.smooth('smooth_ema',ema,ratio)
    plot
        ema: _.last(ema)
        smooth_ema: _.last(smooth_ema)

