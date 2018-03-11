see also: https://cryptotrader.org/backtests/DkxAH7TuBTs3MCdEf
###########################################################  
#                                                         #
# Thanasis      Correl / Autocorrel Indicator             #
#                                                         #
# Full name:    Thanasis Efthymiou                        #
#                                                         #
# BTC:          1CRSH4LGGRWVWqgwfquky2Rk5eJK6gsyus        #
#                                                         #
# e-mail:       cryptotrader.thanasis@gmail.com           #
#                                                         #
###########################################################

class Init

  @init_context: (context) ->
 
     context.shift_lag       = 20  # shift_lag ticks bakcwards for the autocorrelation
    
class functions
  
  @correl: (data1, data2) ->
     cross_product       =  0
     norm_data1          =  0
     norm_data2          =  0
     for n in [1..Math.min(_.size(data1), _.size(data2)) - 1]
         cross_product   =  cross_product +  data1[n] * data2[n]
         norm_data1      =  norm_data1    +  data1[n] * data1[n]
         norm_data2      =  norm_data2    +  data2[n] * data2[n]
     cross_product       =  Math.abs(cross_product)
     norm_data1          =  Math.sqrt(norm_data1)
     norm_data2          =  Math.sqrt(norm_data2)
     correl              =  cross_product / (norm_data1 * norm_data2)
     return correl

  @autocorrel: (data,shift) ->
     cross_product       =  0
     norm_data           =  0
     norm_data_shift     =  0
     for n in [shift.._.size(data) - 1]
         cross_product   =  cross_product +  data[n] * data[n - shift]
         norm_data       =  norm_data     +  data[n] * data[n]
         norm_data_shift =  norm_data     +  data[n  - shift] * data[n - shift]
     cross_product       =  Math.abs(cross_product)
     norm_data           =  Math.sqrt(norm_data)
     norm_data_shift     =  Math.sqrt(norm_data_shift)
     autocorrel          =  cross_product / (norm_data * norm_data_shift)
     return autocorrel

  
init: (context) ->

  Init.init_context(context)

handle: (context, data)->

    instrument =  data.instruments[0]
    
  
     
    # I use the high series and the volumes series of the ticks to see how much similar they are

    correl     = functions.correl(instrument.high, instrument.volumes)


    # I use the close series to see how much similar is with itself when it is shifted backwards for context.shift_lag ticks.
     
    autocorrel = functions.autocorrel(instrument.close, context.shift_lag)  


    debug "angle of correl in degrees: #{Math.round((Math.acos(correl) * 180 / Math.PI) * 100)/100}" 
    debug "correl: #{correl}"
    debug "angle of autocorrel in degrees: #{Math.round((Math.acos(autocorrel) * 180 / Math.PI) * 100)/100}" 
    debug "autocorrel: #{autocorrel}"
    debug "-------------------------------------------------------------------------"




    

 

 
