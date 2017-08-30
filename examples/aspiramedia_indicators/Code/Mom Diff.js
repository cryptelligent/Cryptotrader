init: (context) ->

    context.lag             = 1
    context.periodmom       = 2
    context.periodmom2      = 3

handle: (context, data)->

 
########################################
####### define instrument ##############

    instrument =  data.instruments[0]
    
    price      =  instrument.close[instrument.close.length - 1]
    open       =  instrument.open[instrument.open.length - 1]
    high       =  instrument.high[instrument.high.length - 1]
    low        =  instrument.low[instrument.low.length - 1]
    close      =  instrument.close[instrument.close.length - 1]
    volume     =  instrument.volumes[instrument.volumes.length - 1]


########################################
##### define indicator functions ####### 
  
    MOM = talib.MOM
      inReal: instrument.open
      startIdx: 0
      endIdx: instrument.close.length - 1
      optInTimePeriod: context.periodmom
    mom = _.last(MOM)

    MOM2 = talib.MOM
      inReal: instrument.open
      startIdx: 0
      endIdx: instrument.close.length - 1
      optInTimePeriod: context.periodmom2
    mom2 = _.last(MOM2)
    
    momema = talib.DEMA
        inReal: MOM
        startIdx: 0
        endIdx: MOM.length-1
        optInTimePeriod: 8
    momema_result = momema[momema.length-1]

    mom2ema = talib.DEMA
        inReal: MOM2
        startIdx: 0
        endIdx: MOM2.length-1
        optInTimePeriod: 8
    mom2ema_result = mom2ema[mom2ema.length-1]
 

########################################
######    plot  signals ################

    plot 
        momema: momema_result
        mom2ema: mom2ema_result
   
    
########################################
######    buy or sell Strategy #########

    if momema_result < mom2ema_result
      buy instrument
    if momema_result > mom2ema_result
      sell instrument