#by maksm 
#version1 API only
# see original post at https://cryptotrader.org/topics/206577/ichimoku-trader-revisted
class Ichimoku
    constructor: (@tenkan_n = 8,@kijun_n = 11)->
        @tenkan = Array(@tenkan_n)
        @kijun = Array(@kijun_n)
        @senkou_a = Array(@kijun_n)
        @senkou_b = Array(@kijun_n * 2)
        @chikou = []
    put: (ins) ->
        @tenkan.push(this.calc(ins,@tenkan_n))
        @kijun.push(this.calc(ins,@kijun_n))
        @senkou_a.push((@tenkan[@tenkan.length-1] + @kijun[@kijun.length-1])/2.0)
        @senkou_b.push(this.calc(ins,@kijun_n * 2))
        @chikou.push(ins.close[ins.close.length-@kijun_n])
    current: ->
        cr = false
        if @chikou[@chikou.length-1]-@chikou[@chikou.length-2] < 0
            cr = 'fall'
        else
            if @chikou[@chikou.length-1]-@chikou[@chikou.length-2] > 0
                cr = 'rise'
        c = 
            tenkan: @tenkan[@tenkan.length-1]
            kijun: @kijun[@kijun.length-1]
            senkou_a: @senkou_a[@senkou_a.length-@kijun_n]
            senkou_b: @senkou_b[@senkou_b.length-@kijun_n]
            chikou: @chikou[@chikou.length-1]
            chikou_rise: cr
        return c
    calc: (ins,n) ->
        hh = _.max(ins.high[-n..])
        ll = _.min(ins.low[-n..])
        return (hh + ll) / 2
init: (context)->
    context.pair = 'btc_usd'
    context.tenkan_n = 8
    context.kijun_n = 11
    context.ichi = new Ichimoku(context.tenkan_n, context.kijun_n)
    context.init = true
    context.open = 0.38
    context.open2 = 0.38
    context.open3 = 0.38
    context.close = 2
    context.close2 = 2
    context.close3 = 2
    context.pos = "free"
    
handle: (context, data)->
    instrument = data[context.pair]
    if context.init
        for i in [0...instrument.close.length]
            t =
                open: instrument.open[..i]
                close: instrument.close[..i]
                high: instrument.high[..i]
                low: instrument.low[..i]
            context.ichi.put(t)
        context.init = false
    context.ichi.put(instrument)
    
    #TENKAN/KIJUN CROSSOVER
    c = context.ichi.current()
    diff = 100 * ((c.tenkan - c.kijun) / ((c.tenkan + c.kijun)/2))
    diff = Math.abs(diff)
    
    #PRICE/KIJUN CROSSOVER
    price = instrument.price
    diff2 = 100 * ((price - c.kijun) / ((price + c.kijun)/2))
    diff2 = Math.abs(diff2)
    
    #PRICE/CHIKOU CROSSOVER
    diff3 = 100 * ((price - c.chikou) / ((price + c.chikou)/2))
    diff3 = Math.abs(diff3)

    min_senkou = _.min([c.senkou_a,c.senkou_b])
    max_senkou = _.max([c.senkou_a,c.senkou_b])
    
    min_tenkan = _.min([c.tenkan,c.kijun])
    max_tenkan = _.max([c.tenkan,c.kijun])

    min_price = _.min([price,c.kijun])
    max_price = _.max([price,c.kijun])      

    min_chikou = _.min([price,c.chikou])
    max_chikou = _.max([price,c.chikou])      
    
    #OPEN WITH STRONG TENKAN/KIJUN CROSSOVER SIGNALS, CLOSE WITH WEAK
    if diff >= context.close
        if context.pos == "long_tk" and c.tenkan < c.kijun# and max_tenkan < min_senkou
            sell(instrument)
            context.pos = "free"
        if context.pos == "short_tk" and c.tenkan > c.kijun# and min_tenkan > max_senkou 
            buy(instrument)
            context.pos = "free"
    if diff >= context.open# and context.pos = "free"
        if c.tenkan > c.kijun and min_tenkan > max_senkou 
            context.pos = "long_tk"
            buy(instrument)
        else if c.tenkan < c.kijun and max_tenkan < min_senkou
            context.pos = "short_tk"
            sell(instrument)
            
#    #OPEN WITH STRONG PRICE/KIJUN CROSSOVER SIGNALS, CLOSE WITH WEAK
#    if diff2 >= context.close2
#        if context.pos == "long_pk" and price < c.kijun# and max_tenkan < min_senkou
#            sell(instrument)
#            context.pos = "free"
#        if context.pos == "short_pk" and price > c.kijun# and min_tenkan > max_senkou 
#            buy(instrument)
#            context.pos = "free"
#    if diff2 >= context.open2# and context.pos = "free"
#        if price > c.kijun and min_price > max_senkou 
#            context.pos = "long_pk"
#            buy(instrument)
#        else if price < c.kijun and max_price < min_senkou
#            context.pos = "short_pk"
#            sell(instrument)

#    #OPEN WITH STRONG PRICE/CHIKOU CROSSOVER SIGNALS, CLOSE WITH WEAK
#    if diff3 >= context.close3
#        if context.pos == "long_pc" and price < c.chikou# and max_tenkan < min_senkou
#            sell(instrument)
#            context.pos = "free"
#        if context.pos == "short_pc" and price > c.chikou# and min_tenkan > max_senkou 
#            buy(instrument)
#            context.pos = "free"
#    if diff3 >= context.open3# and context.pos = "free"
#        if price > c.chikou and min_chikou > max_senkou and c.cr = 'fall'
#            context.pos = "long_pc"
#            buy(instrument)
#       else if price < c.chikou and max_chikou < min_senkou and c.cr = 'rise'
#            context.pos = "short_pc"
#            sell(instrument)
