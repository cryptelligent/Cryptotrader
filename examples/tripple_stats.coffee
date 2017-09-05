################################ CREDITS #######################################
#simple script to calculate trples stats
#crypteligent 4/9/2017
############################## END OF CREDITS ##################################

################################ HEAD ##########################################
trading = require 'trading'
params = require 'params'
ds = require 'datasources'

ds.add 'bitstamp', 'btc_usd', '5m'
ds.add 'bitstamp', 'eth_btc', '5m'
ds.add 'bitstamp', 'eth_usd', '5m'

FEE = 0.0025
################################ END OF HEAD ###################################

init: ->
    #This runs once when the bot is started

handle: ->
######################### INITIALIZING VARIABLES ###############################
    storage.botStartedAt ?= data.at
    storage.TICK ?= 0
    storage.minus ?= 0
    storage.plus ?= 0
    storage.sum_pos ?= 0
    storage.sum_neg ?= 0
    storage.max ?= 0
    storage.min ?= 1
    numberOfPairs = @data.instruments.length-1 #used for multiple pairs of trade (2)
    instrument = [0.. numberOfPairs] #[0..2]
    currencyAvailable = [0.. numberOfPairs]
    assetsAvailable = [0.. numberOfPairs]
    ins1 = @data.instruments[0]
    storage.pair1 = ins1.pair
    ins2 = @data.instruments[1]
    storage.pair2 = ins2.pair
    ins3 = @data.instruments[2]
    storage.pair3 = ins3.pair
    factor = ins1.price * ins2.price / ins3.price
    if factor > 1.0075
        storage.plus++
        storage.sum_pos = storage.sum_pos + factor
        if storage.max < factor
            storage.max = factor
    if factor < 0.9925
        storage.minus++
        storage.sum_neg = storage.sum_neg + factor
        if storage.min > factor
            storage.min = factor

    storage.TICK++
onStop: ->
    info "Bot started at #{new Date(storage.botStartedAt)}"
    info "Bot stopped at #{new Date(data.at)}"
    warn "#{storage.pair1}>>#{storage.pair2}>>#{storage.pair3}"
    warn "totalticks:#{storage.TICK} plus:#{storage.plus} minus:#{storage.minus}"
    avg_pos = storage.sum_pos / storage.plus
    avg_neg = storage.sum_neg / storage.minus
    warn "max:#{storage.max} min:#{storage.min}"
    warn "avg_pos:#{avg_pos} avg_neg:#{avg_neg}"

