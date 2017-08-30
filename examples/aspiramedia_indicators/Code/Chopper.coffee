init: (context)->

	# FOR FINALISE STATS
    context.balance_curr = 0
    context.balance_btc = 0
    context.price = 0

handle: (context, data, storage)->

    instrument = data.instruments[0]
    price = instrument.close[instrument.close.length - 1]
    pricelookback = instrument.close[instrument.close.length - 3]
    storage.count ?= 0
    storage.chopcount ?= 0
    storage.chopupcount ?= 0
    storage.chopdowncount ?= 0

    storage.count++

    if price / pricelookback > 1.03
    	storage.chopcount++
    	storage.chopupcount++
    	plotMark
    		"chopup": price

    if price / pricelookback < 0.97
    	storage.chopcount++
    	storage.chopdowncount++
    	plotMark
    		"chopdown": price

    chopratio = storage.chopcount / storage.count
    
    debug "Count: " + storage.count + " | Chops: " + storage.chopcount + " | Chop Ratio: " + chopratio

    plot
    	chopupratio: (storage.chopupcount/storage.count)
    	chopdownratio: (storage.chopdowncount/storage.count)
    setPlotOptions
    	chopupratio:
    		secondary: true
    	chopdownratio:
    		secondary: true

