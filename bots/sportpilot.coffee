# Ichimoku + Heikin-Ashi + Parabolic SAR + AROON + MACD + RSI + Auto Market Config
# MtGox 2hr
# v1.0
#
# Includes Stats v0.2.1 by sportpilot
# See also: https://cryptotrader.org/topics/884632/my-contribution-stats-module-v0-2-1

class Ichimoku
  constructor: (@tenkan_n, @kijun_n, @senkou_a_n, @senkou_b_n, @chikou_n) ->
    @price = 0.0
    @tenkan = 0.0
    @kijun = 0.0
    @senkou_a = []
    @senkou_b = []
    @chikou = []

  # get current ichimoku state
  current: ->
    c =
      price: @price
      tenkan: @tenkan
      kijun: @kijun
      senkou_a: @senkou_a[0]
      senkou_b: @senkou_b[0]
#      chikou: @chikou[0]
      chikou: @chikou[@chikou.length - 1]
      chikou_span: @chikou[@chikou.length - 1] - @chikou[0]
    return c

  # update with latest instrument price data
  put: (ins) ->
    # update last close price
    @price = ins.close[ins.close.length - 1]
    # update tenkan sen
    @tenkan = this._hla(ins, @tenkan_n)
    # update kijun sen
    @kijun = this._hla(ins, @kijun_n)
    # update senkou span a
    @senkou_a.push((@tenkan + @kijun) / 2)
    this._splice(@senkou_a, @senkou_a_n)
    # update senkou span b
    @senkou_b.push(this._hla(ins, @senkou_b_n * 2))
    this._splice(@senkou_b, @senkou_b_n)
    # update chikou span
    @chikou.push(ins.close[ins.close.length - 1])
    this._splice(@chikou, @chikou_n)

  # calc average of price extremes (high-low avg) over specified period
  _hla: (ins, n) ->
    hh = _.max(ins.high[-n..])
    ll = _.min(ins.low[-n..])
    return (hh + ll) / 2

  # restrict array length to specified max
  _splice: (arr, l) ->
    while arr.length > l
      arr.splice(0, 1)


class HeikinAshi
  constructor: () ->
    @ins =
      open: []
      close: []
      high: []
      low: []

  # update with latest instrument price data
  put: (ins) ->
    if @ins.open.length == 0
      # initial candle
      @ins.open.push(ins.open[ins.open.length - 1])
      @ins.close.push(ins.close[ins.close.length - 1])
      @ins.high.push(ins.high[ins.high.length - 1])
      @ins.low.push(ins.low[ins.low.length - 1])
    else
      # every other candle
      prev_open = ins.open[ins.open.length - 2]
      prev_close = ins.close[ins.close.length - 2]
      curr_open = ins.open[ins.open.length - 1]
      curr_close = ins.close[ins.close.length - 1]
      curr_high = ins.high[ins.high.length - 1]
      curr_low = ins.low[ins.low.length - 1]
      @ins.open.push((prev_open + prev_close) / 2)
      @ins.close.push((curr_open + curr_close + curr_high + curr_low) / 4)
      @ins.high.push(_.max([curr_high, curr_open, curr_close]))
      @ins.low.push(_.min([curr_low, curr_open, curr_close]))


class Functions
  @diff: (x, y) ->
    ((x - y) / ((x + y) / 2)) * 100

  @ema: (data, period) ->
    results = talib.EMA
      inReal: data
      startIdx: 0
      endIdx: data.length - 1
      optInTimePeriod: period
    _.last(results)

  @sar: (high, low, accel, max) ->
    results = talib.SAR
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - 1
      optInAcceleration: accel
      optInMaximum: max
    _.last(results)

  @sar_ext: (high, low, start_value, offset_on_rev, accel_init_long, accel_long, accel_max_long, accel_init_short, accel_short, accel_max_short) ->
    results = talib.SAREXT
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - 1
      optInStartValue: start_value
      optInOffsetOnReverse: offset_on_rev
      optInAccelerationInitLong: accel_init_long
      optInAccelerationLong: accel_long
      optInAccelerationMaxLong: accel_max_long
      optInAccelerationInitShort: accel_init_short
      optInAccelerationShort: accel_short
      optInAccelerationMaxShort: accel_max_short
    _.last(results)

  @aroon: (high, low, period) ->
    results = talib.AROON
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - 1
      optInTimePeriod: period
    result =
      up: _.last(results.outAroonUp)
      down: _.last(results.outAroonDown)
    result

  @macd: (data, fast_period, slow_period, signal_period) ->
    results = talib.MACD
      inReal: data
      startIdx: 0
      endIdx: data.length - 1
      optInFastPeriod: fast_period
      optInSlowPeriod: slow_period
      optInSignalPeriod: signal_period
    result =
      macd: _.last(results.outMACD)
      signal: _.last(results.outMACDSignal)
      histogram: _.last(results.outMACDHist)
    result

  @rsi: (data, period) ->
    results = talib.RSI
      inReal: data
      startIdx: 0
      endIdx: data.length - 1
      optInTimePeriod: period
    _.last(results)


  @populate: (target, ins) ->
    for i in [0...ins.close.length]
      t =
        open: ins.open[..i]
        close: ins.close[..i]
        high: ins.high[..i]
        low: ins.low[..i]
      target.put(t)

  @can_buy: (ins, min_btc, fee_percent) ->
    portfolio.positions[ins.curr()].amount >= ((ins.price * min_btc) * (1 + fee_percent / 100))

  @can_sell: (ins, min_btc) ->
    portfolio.positions[ins.asset()].amount >= min_btc


class Config
  constructor: (@long_open, @long_close, @short_open, @short_close, @sar_accel, @sar_max, @aroon_period, @macd_fast_period, @macd_slow_period, @macd_signal_period, @macd_short, @macd_long, @rsi_period, @rsi_high, @rsi_low) ->

init: (context) ->
  context.pair = 'btc_usd'
  context.min_btc = 0.01
  context.fee_percent = 0.6
  context.ha = new HeikinAshi()
  context.ichi_bull = new Ichimoku(8, 11, 11, 11, 11)
  context.ichi_bear = new Ichimoku(7, 10, 11, 11, 11)
  context.config_bull = new Config(0.1, 2.2, 0.19, 2.14, 0.025, 0.2, 10, 10, 21, 8, -1, 1,20,52,48)
  context.config_bear = new Config(0.1, 0.3, 0.3, 2.4, 0.025, 0.2, 10, 14, 22, 9, 0, 1,20,52,48)
  context.bull_market_threshold = 0
  context.market_short = 12
  context.market_long = 90
  context.enable_ha = true
  context.pos = null
  context.init = true

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# context for Stats module
#   Installation: Paste this block after the other context
#     declarations but before the handle: method
#
  context.fee = 0.55          # Set to correct fee
  context.stats = true        # Display stats?
  context.triggers = true     # Display trade triggers?
  context.value_initial = 0   # - Do not modify
  context.price_initial = 0   # - Do not modify
  context.BTC_initial = 0     # - Do not modify
  context.buy_value = 0       # - Do not modify
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Serialized context for Stats module
#   Installation: Paste this block in the serialize: method
#     after the other declarations but before the
#     handle: method. If the serialize: method doesn't
#     exist, uncomment the serialize: (content)-> line
#
serialize: (context)->       # uncomment to add serialze: method
  value_initial:context.value_initial
  price_initial:context.price_initial
  BTC_initial:context.BTC_initial
  buy_value:context.buy_value
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

handle: (context, data) ->
  # get instrument
  instrument = data[context.pair]

  # handle instrument data
  if context.init
    if context.enable_ha
      # initialise heikin-ashi
      Functions.populate(context.ha, instrument)
      # initialise ichimoku (from heikin-ashi data)
      Functions.populate(context.ichi_bull, context.ha.ins)
      Functions.populate(context.ichi_bear, context.ha.ins)
    else
      # initialise ichimoku
      Functions.populate(context.ichi_bull, instrument)
      Functions.populate(context.ichi_bear, instrument)
    # initialisation complete
    context.init = false
  else
    if context.enable_ha
      # handle new instrument (via heikin-ashi)
      context.ha.put(instrument)
      context.ichi_bull.put(context.ha.ins)
      context.ichi_bear.put(context.ha.ins)
    else
      # handle new instrument
      context.ichi_bull.put(instrument)
      context.ichi_bear.put(instrument)

  # determine setup for current market condition (bull/bear)
  if context.enable_ha
    short = Functions.ema(context.ha.ins.close, context.market_short)
    long = Functions.ema(context.ha.ins.close, context.market_long)
  else
    short = Functions.ema(instrument.close, context.market_short)
    long = Functions.ema(instrument.close, context.market_long)
  if Functions.diff(short, long) >= context.bull_market_threshold
    # bull market
    config = context.config_bull
    c = context.ichi_bull.current()
  else
    # bear market
    config = context.config_bear
    c = context.ichi_bear.current()

  # log/plot data
  #  info "tenkan: " + c.tenkan + ", kijun:" + c.kijun + ", senkou_a:" + c.senkou_a + ", senkou_b:" + c.senkou_b
  plot
    short: short
    long: long
    tenkan: c.tenkan
    kijun: c.kijun
    senkou_a: c.senkou_a
    senkou_b: c.senkou_b

  # calc ichi indicators
  tk_diff = Math.abs(Functions.diff(c.tenkan, c.kijun))
  tenkan_min = _.min([c.tenkan, c.kijun])
  tenkan_max = _.max([c.tenkan, c.kijun])
  kumo_min = _.min([c.senkou_a, c.senkou_b])
  kumo_max = _.max([c.senkou_a, c.senkou_b])

  # calc sar indicator
  if context.enable_ha
    sar = Functions.sar(context.ha.ins.high, context.ha.ins.low, config.sar_accel, config.sar_max)
  else
    sar = Functions.sar(instrument.high, instrument.low, config.sar_accel, config.sar_max)

  # calc aroon indicator
  if context.enable_ha
    aroon = Functions.aroon(context.ha.ins.high, context.ha.ins.low, config.aroon_period)
  else
    aroon = Functions.aroon(instrument.high, instrument.low, config.aroon_period)

  # calc macd indicator
  if context.enable_ha
    macd = Functions.macd(context.ha.ins.close, config.macd_fast_period, config.macd_slow_period, config.macd_signal_period)
  else
    macd = Functions.macd(instrument.close, config.macd_fast_period, config.macd_slow_period, config.macd_signal_period)

  # calc rsi indicator
  if context.enable_ha
    rsi = Functions.rsi(context.ha.ins.close, config.rsi_period)
  else
    rsi = Functions.rsi(instrument.close, config.rsi_period)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Stats module v0.1.4 by sportpilot
#   Installation: Paste this block above (before) the init: method
#
#   Donations: 1561k5XqWFJSHP8apmvGt15ecWjw9ZLKGi
#

# Functions
  pow = (x, y) -> Math.pow(x, y)
  less_fee = (v) -> v * (1 - (context.fee / 100))

# Reporting
  price = instrument.price
  open = instrument.open[instrument.open.length - 1]
  high = instrument.high[instrument.high.length - 1]
  low = instrument.low[instrument.low.length - 1]
  price_prev = instrument.close[instrument.close.length - 2]
  current_USD = portfolio.positions.usd.amount
  current_BTC = portfolio.positions.btc.amount
  value = (current_BTC * price) + current_USD

  if context.value_initial == 0
    if current_BTC > 0
      context.BTC_initial = current_BTC
      context.buy_value = value
    else
      context.BTC_initial = less_fee(current_USD) / price
    context.price_initial = price
    context.value_initial = price * context.BTC_initial

  gain_loss = (value - context.value_initial)
  BH_gain_loss = (value - (price * context.BTC_initial)).toFixed(2)

  if context.stats
    debug "~~~~~~~~~~~~"
    debug "Price: #{price.toFixed(3)} | Open: #{open.toFixed(3)} | High: #{high.toFixed(3)} | Low: #{low.toFixed(3)}"
    debug "Balance: #{value.toFixed(2)} | USD: #{current_USD.toFixed(2)} | BTC: #{current_BTC.toFixed(5)}"
    if current_BTC > 0
      debug "[G/L] Session: #{gain_loss.toFixed(2)}  | Trade: #{(value - context.buy_value).toFixed(2)}  |  B&H: #{BH_gain_loss}"
    else
      debug "[G/L] Session: #{gain_loss.toFixed(2)}  |  B&H: #{BH_gain_loss}"

  if context.triggers
    if current_BTC > 0
      warn "Long - Close: #{tk_diff.toFixed(3)} >= #{config.long_close} [&] #{c.tenkan.toFixed(3)} <= #{c.kijun.toFixed(3)} [&] (#{c.chikou.toFixed(3)} <= #{sar.toFixed(3)} [or] #{rsi.toFixed(3)} <= #{config.rsi_low} [or] #{macd.histogram.toFixed(3)} <= #{config.macd_short})"
      warn "Short - Open: #{tk_diff.toFixed(3)} >= #{config.short_open} [&] #{c.tenkan.toFixed(3)} <= #{c.kijun.toFixed(3)} [&] #{tenkan_max.toFixed(3)} <= #{kumo_min.toFixed(3)} [&] #{c.chikou_span.toFixed(3)} <= 0 [&] #{aroon.up} < #{aroon.down}"
    else
      warn "Short - Close: #{tk_diff.toFixed(3)} >= #{config.short_close} [&] #{c.tenkan.toFixed(3)} >= #{c.kijun.toFixed(3)} [&] (#{c.chikou.toFixed(3)} >= #{sar.toFixed(3)} [or] #{rsi.toFixed(3)} >= #{config.rsi_low} [or] #{macd.histogram.toFixed(3)} >= #{config.macd_long})"
      warn "Long - Open: #{tk_diff.toFixed(3)} >= #{config.long_open} [&] #{c.tenkan.toFixed(3)} >= #{c.kijun.toFixed(3)} [&] #{tenkan_min.toFixed(3)} >= #{kumo_max.toFixed(3)} [&] #{c.chikou_span.toFixed(3)} >= 0 [&] #{aroon.up} >= #{aroon.down}"
#
# End Stats module
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # close position
  if context.pos == "long" and tk_diff >= config.long_close and c.tenkan <= c.kijun and (c.chikou <= sar or rsi <= config.rsi_low or macd.histogram <= config.macd_short)
    if Functions.can_sell(instrument, context.min_btc)
      sell(instrument)
      debug "long close"
    context.pos = null
  else if context.pos == "short" and tk_diff >= config.short_close and c.tenkan >= c.kijun and (c.chikou >= sar or rsi  >= config.rsi_high or macd.histogram >= config.macd_long)
    if Functions.can_buy(instrument, context.min_btc, context.fee_percent)
      buy(instrument)
      debug "short close"
    context.pos = null

  # open position
  if tk_diff >= config.long_open and c.tenkan >= c.kijun and tenkan_min >= kumo_max and c.chikou_span >= 0 and aroon.up >= aroon.down
    if Functions.can_buy(instrument, context.min_btc, context.fee_percent)
      buy(instrument)
      debug "long open"
    context.pos = "long"
  else if tk_diff >= config.short_open and c.tenkan <= c.kijun and tenkan_max <= kumo_min and c.chikou_span <= 0 and aroon.up < aroon.down
    if Functions.can_sell(instrument, context.min_btc)
      sell(instrument)
      debug "short open"
    context.pos = "short"
