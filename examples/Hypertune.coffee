###
   Hypertune v1.0
        by
    >btcorbust<

  BTC     : 1KvPi4XybwC6bmErQ53GDKLvrJrobK1PER
  LTC     : LW8v6hocT7jGaXfWxwJrU4taeYBRH4V5Kr

  btcorbust@gmail.com
  see also:https://cryptotrader.org/topics/662737/hypertune-by-btcorbust

###

class I
  @init: (context) ->
    ######################################################
    # algorithm config                                   #
    ######################################################
    context.ema_period = 10
    context.bthresh = 1.012
    context.sthresh = 0.988


    ######################################################
    # hypertune config                                   #
    ######################################################
    # enable/disable hypertune
    #  [default: false]
    context.ht_enabled = true

    # enable/disable hypertune debug logging
    #  [default: false]
    context.ht_debug = false

    # hypertune interval (fixed): no. periods between hypertunes
    #  - takes precendence over hi/lo interval self-tuning below
    #  - this must be specified if hi/lo interval self-tuning is not configured.
    #context.ht_interval = 20

    # hypertune interval (self-tune): no. periods between hypertunes
    #  - hypertune engine will self-tune to an execution interval between the
    #    specified hi/lo values. Based on market volatility (higher volatility
    #    tends towards smaller interval).
    context.ht_interval_lo = 10
    context.ht_interval_hi = 20

    # hypertune range (fixed): no. historic periods to consider during hypertune
    #  - takes precendence over hi/lo range self-tuning below
    #  - this must be specified if hi/lo range self-tuning is not configured.
    #context.ht_range = 100

    # hypertune range (self-tune): no. historic periods to consider during hypertune
    #  - hypertune engine will self-tune to a historic period range between the
    #    specified hi/lo values. Based on market volatility (higher volatility
    #    tends towards smaller range).
    context.ht_range_lo = 20
    context.ht_range_hi = 100

    # number of hypertune passes to perform over historic data
    #  - the optimum number of passes is dependent on the number of parameters to
    #    be hypertuned. A single hypertuned parameter requires only a single pass.
    #  [default: 1]
    context.ht_passes = 1

    # hypertuned parameter specifications
    #  - all hypertuned parameters must specify 'min', 'max' & 'step' values. These
    #    define the range over which the parameter will be hypertuned.
    #  - all hypertuned parameters must have a corresponding default value configured
    #    directly on the context (see section above). The default should be a reasonable
    #    value.
    #  - all hypertuned parameters should be serialized.
    context.ht_spec =
      bthresh:
        min: 1.008
        max: 1.012
        step: 0.001
      sthresh:
        min: 0.988
        max: 0.992
        step: 0.001

    ######################################################
    # trade config                                       #
    ######################################################
    # miscellaneous
    context.trade_period_mins = 1440
    context.price_decimals = 3


    ######################################################
    # other config                                       #
    ######################################################
    # enable/disable plot lines
    context.plot = true

    # enable/disable tick logging and frequency
    context.tick = false
    context.tick_freq = 1

    # DO NOT MODIFY!
    context.tick_cnt = 0
    context.ht_last = null
    context.plot_offset = null


#==========================================================#

# Decision Maker - core buy/sell logic
class D
  @decide: (context, ins) ->
    # Buy/sell logic

    # define bot strategy
    # must return an [action,plot data] tuple!
    strategy = ((c, i) ->
      
      ema = A.ema(i.open, c.ema_period)
      
      points =
        ema: ema

      if _.last(i.open) > ema * c.bthresh
        return [Action.BUY, points]

      if _.last(i.open) < ema * c.sthresh
        return [Action.SELL, points]
        
      return [Action.NONE, points]
    )

    # peform hypertune
    Hypertune.tune(context, ins, strategy)

    # execute strategy
    [action, points] = strategy(context, ins)

    # execute trade action
    if action == Action.BUY
      buy ins
    if action == Action.SELL
      sell ins

    # plot data points
    if context.plot and points
      plot points


#==========================================================#

# Dynamic hypertune engine
class Hypertune
  @can_tune: (context, ins) ->
    if !context.ht_enabled || !context.ht_spec
      return false

    if context.ht_interval
      ht_interval = context.ht_interval
    else
      ht_interval = @_scale_period(context.ht_interval_lo, context.ht_interval_hi, ins)

    now = ins.ticks[ins.ticks.length - 1].at
    result = !context.ht_last or (now - context.ht_last) / 60000 >= ht_interval * context.trade_period_mins
    context.ht_last = now unless !result
    return result

  @tune: (context, ins, strategy) ->
    if !@can_tune(context, ins)
      return

    if context.ht_debug
      debug '+================HYPERTUNE================+'

    if context.ht_range
      ht_range = context.ht_range
    else
      ht_range = @_scale_period(context.ht_range_lo, context.ht_range_hi, ins)

    if context.ht_debug
      debug "HT range: #{ht_range}"

    epoch = _.min([ins.close.length - 1, ht_range])

    passes = context.ht_passes
    passes = 1 unless context.ht_passes > 1

    result = {}
    for pass in [1..passes]
      if context.ht_debug and passes > 1
        debug '-------------------------------------------'
        debug "Performing HT pass ##{pass}..."

      for own param, spec of context.ht_spec
        raw = {}
        x = spec.min
        while x <= spec.max
          ctx = F.clone(context)
          if result
            for own key of result
              ctx[key] = result[key]

          ctx[param] = x

          coin = 1
          fiat = 1000
          last_action = null
          for i in [epoch..1]
            n = ins.close.length - i
            _ins =
              price: F.prev(ins.close, i)
              open: ins.open[0..n]
              close: ins.close[0..n]
              high: ins.high[0..n]
              low: ins.low[0..n]
              volumes: ins.volumes[0..n]
            [action] = strategy(ctx, _ins)
            if action != last_action
              if action == Action.BUY
                coin += fiat / _ins.price
                fiat = 0
                last_action = Action.BUY
              if action == Action.SELL
                fiat += (coin * _ins.price)
                coin = 0
                last_action = Action.SELL

          total = fiat + coin * ins.price

          if context.ht_debug
            debug "#{param} [#{x}] => $#{F.rnd(fiat, 2)} + #{F.rnd(coin)} BTC => $#{F.rnd(total, 2)}"

          raw[x] = total

          x += spec.step

        k0 = null
        v0 = null
        for key, val of raw
          if !k0 or val > v0
            k0 = key
            v0 = val

        result[param] = k0

      if context.ht_debug
        debug '-------------------------------------------'
        F.dump(result, 'hypertune')

    if result
      for own key of result
        context[key] = result[key]

    if context.ht_debug
      debug '+===============/HYPERTUNE================+'

  @_scale_period: (period_lo, period_hi, ins) ->
    natr_lo = A.natr(ins.high, ins.low, ins.close, period_lo)
    natr_hi = A.natr(ins.high, ins.low, ins.close, period_hi)
    return F.rnd(period_lo + (period_hi - period_lo) * _.min([natr_hi / natr_lo, 1]), 0)

Action =
  BUY: 'BUY'
  SELL: 'SELL'
  NONE: 'NONE'

#==========================================================#
# TA-Lib & Other Indicators
class A
  # NATR
  @natr: (high, low, close, period, last = true) ->
    period = close.length unless close.length >= period
    results = talib.NATR
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: close.length - 1
      optInTimePeriod: period
    if last then _.last(results) else results
    
  @ema: (data, period, last = true) ->
    if period == 1
      results = data
    else
      period = data.length unless data.length >= period
      results = talib.EMA
        inReal: data
        startIdx: 0
        endIdx: data.length - 1
        optInTimePeriod: period
    if last then _.last(results) else results

#==========================================================#

# Utility Functions
class F
  # object deep copy
  @clone: (obj) ->
    if not obj? or typeof obj isnt 'object'
      return obj

    if obj instanceof Date
      return new Date(obj.getTime())

    if obj instanceof RegExp
      flags = ''
      flags += 'g' if obj.global?
      flags += 'i' if obj.ignoreCase?
      flags += 'm' if obj.multiline?
      flags += 'y' if obj.sticky?
      return new RegExp(obj.source, flags)

    newInstance = new obj.constructor()
    for key of obj
      newInstance[key] = @clone(obj[key])
    return newInstance

  # round a value to specified number decimal places
  @rnd = (x, d = 3) ->
    if d <= 0 then return Math.round(x)
    n = Math.pow(10, (if d < 0 then 0 else d))
    Math.round(x * n) / n

  # retrieve nth value from end of array
  @prev = (data, n = 1) ->
    if data.length < n then return NaN
    data[data.length - n]

  # dump an object
  @dump: (o, label = "object") ->
    if o
      debug "#{label}:"
      for own key, value of o
        debug "* #{key} : #{value}"
    else
      debug "#{label}: null"


#==========================================================#

# Ticker
class Tick
  @tick = (context, msg = '') ->
    if context.tick and context.tick_cnt % context.tick_freq == 0
      debug "tick ##{context.tick_cnt} #{msg}"
    context.tick_cnt++


#==========================================================#

# Cryptotrader Hooks
init: (context) ->
  # initialise context
  I.init context


handle: (context, data)->
  # tick!
  Tick.tick context
  # decision time!
  D.decide context, data.instruments[0]


serialize: (context) ->
  # serialize bot state
  ema_period: context.ema_period
  bthresh: context.bthresh
  sthresh: context.sthresh
