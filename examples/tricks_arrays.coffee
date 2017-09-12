################################ CREDITS #######################################
    #An example of function to adjust different instruments ticks arrays
    #11/09/2017
    #Developed byCryptelligent
    #see also 
############################## END OF CREDITS ##################################

################################ HEAD ##########################################
trading = require 'trading'
ds = require 'datasources'

ds.add 'poloniex', 'eth_btc', '5m'
ds.add 'poloniex', 'etc_eth', '5m'
ds.add 'poloniex', 'etc_btc', '5m'

################################ END OF HEAD ###################################
################################ functions ###################################
###
    function adjustInstruments buid 3 new arrays with corresponding timestamps
    Only for 3 instruments
    @params - instruments
    @return: array of instruments
###
adjustInsTicksArrays = (instrument0, instrument1, instrument2) ->
    if (instrument0.ticks.length >400)
        instrument0.ticks = instrument0.ticks.splice(400) #remove first 400 ticks
    ins0 = JSON.parse(JSON.stringify(instrument0)) #clone object
    ins0.ticks.length = 0 #delete ticks values
    ins1 = JSON.parse(JSON.stringify(instrument1))
    ins1.ticks.length = 0
    ins2 = JSON.parse(JSON.stringify(instrument2))
    ins2.ticks.length = 0
        
    for value, i in instrument0.ticks
        for value, k in instrument1.ticks
            for value, j in instrument2.ticks
                if ((instrument0.ticks[i].at == instrument1.ticks[k].at) and (instrument0.ticks[i].at == instrument2.ticks[j].at) and (instrument1.ticks[k].at == instrument2.ticks[j].at))
                    ins0.ticks.push (instrument0.ticks[i])
                    ins1.ticks.push (instrument1.ticks[k])
                    ins2.ticks.push (instrument2.ticks[j])
                    break;
    return [ins0, ins1, ins2]

################################ END functions ###############################

init: ->
handle: ->
    storage.botStartedAt ?= data.at
    ins0 = @data.instruments[0]
    ins1 = @data.instruments[1]
    ins2 = @data.instruments[2]
    warn "initial length ins0:#{ins0.ticks.length} ins1:#{ins1.ticks.length} ins2:#{ins2.ticks.length}"
    debug "ins0 starts at #{new Date(ins0.ticks[0].at)} and ends at #{new Date(ins0.ticks[ins0.ticks.length-1].at)}"
    debug "ins1 starts at #{new Date(ins1.ticks[0].at)} and ends at #{new Date(ins1.ticks[ins1.ticks.length-1].at)}"
    debug "ins2 starts at #{new Date(ins2.ticks[0].at)} and ends at #{new Date(ins2.ticks[ins2.ticks.length-1].at)}"
    tmp_arr = adjustInsTicksArrays(ins0,ins1,ins2)
    ins0 = tmp_arr[0]
    ins1 = tmp_arr[1]
    ins2 = tmp_arr[1]
    warn "after trasformation length ins0:#{ins0.ticks.length} ins1:#{ins1.ticks.length} ins2:#{ins2.ticks.length}"
    debug "ins0 starts at #{new Date(ins0.ticks[0].at)} and ends at #{new Date(ins0.ticks[ins0.ticks.length-1].at)}"
    debug "ins1 starts at #{new Date(ins1.ticks[0].at)} and ends at #{new Date(ins1.ticks[ins1.ticks.length-1].at)}"
    debug "ins2 starts at #{new Date(ins2.ticks[0].at)} and ends at #{new Date(ins2.ticks[ins2.ticks.length-1].at)}"
#    for value, key in ins0.ticks
#        debug "key #{key} value #{ins0.ticks[key].at} second #{ins1.ticks[key].at} third #{ins1.ticks[key].at}"
#    if ((ins0.ticks[ins0.ticks.length-1].at != ins1.ticks[ins1.ticks.length-1].at) or (ins0.ticks[ins0.ticks.length-1].at != ins2.ticks[ins2.ticks.length-1].at) or (ins1.ticks[ins1.ticks.length-1].at != ins2.ticks[ins2.ticks.length-1].at))
#        warn "timestamps are different"
#        debug "ins0 price  at #{ins0.ticks[ins0.ticks.length-1].at}"
#        debug "ins1 price  at #{ins1.ticks[ins1.ticks.length-1].at}"
#        debug "ins2 price  at #{ins2.ticks[ins2.ticks.length-1].at}"
    
    stop()

