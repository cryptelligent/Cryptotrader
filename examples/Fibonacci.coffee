###
    Fibonacci Support and Resistance lines
    inspired by DISTANT https://cryptotrader.org/live/iWXWehmxdp5mMLnxk
    by Cryptelligent
    see also 
###

trading = require 'trading' # import core trading module
talib = require 'talib' # import technical indicators library (https://cryptotrader.org/talib)
params = require 'params'
######################### Settings
_lag = 1
######################## Functions
###
    function calculate min and max values for a certain period
    @params - data, lag, period
    @return: object with max and min properties
###
minmax = (data,lag,period) ->
    results = talib.MINMAX
      inReal: data
      startIdx: 0
      endIdx: data.length - lag
      optInTimePeriod: period
    result =
      min: _.last(results.outMin)
      max: _.last(results.outMax)
    result
######################### initialisation
init: ->
    setPlotOptions
        r3:
            color: '#621216'
            lineWidth: 1
        r2:
            color: '#d93436'
            lineWidth: 1
        r1:
            color: '#f06d6e'
            lineWidth: 1
        s1:
            color: '#b2d649'
            lineWidth: 1
        s2:
            color: '#83bd1a'
            lineWidth: 1
        s3:
            color: '#446a12'
            lineWidth: 1
################################# main            
handle: ->
    ins = data.instruments[0]
    price = ins.price
    _f_period = 1440 / ins.interval
    Max = minmax(ins.high, _lag, _f_period)
    max = Max.max
    Min = minmax(ins.low, _lag, _f_period)
    min = Min.min
    s1 = min - (max - min) * 0.382
    s2 = min - (max - min) * 0.5
    s3 = min - (max - min) * 0.618
    r1 = max + (max - min) * 0.382
    r2 = max + (max - min) * 0.5
    r3 = max + (max - min) * 0.618
    plot
        r3: r3 
        r2: r2 
        r1: r1 
        s1: s1
        s2: s2 
        s3: s3
###########################

