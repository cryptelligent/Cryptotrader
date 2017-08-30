#https://cryptotrader.org/topics/460576/tweakaholic-2-0-btcorbust
###########################################################
##      Tweakaholic Framework v2.1
##
##            >btcorbust<
##
## BTC: 1KvPi4XybwC6bmErQ53GDKLvrJrobK1PER
## LTC: LW8v6hocT7jGaXfWxwJrU4taeYBRH4V5Kr
##
##        btcorbust@gmail.com
###########################################################

class I
  @init: (context) ->
    # algorithm config - required
    context.indicators = ['ichi', 'sar', 'aroon', 'macd', 'rsi', 'stoch', 'mfi']
    context.ha = new HeikinAshi(3) # 0 = disabled

    # bull/bear market config
    context.bull_bear_enabled = true
    context.bull_market_threshold = -0.30
    context.bear_market_threshold = 0
    context.market_short = 15
    context.market_long = 85

    # bull market config (ie. bull_bear_enabled = true)
    #  - only the config for the indicators specified above is required
    #  - any additional config (eg. thresholds, etc) may be added as needed
    #  - safe to remove if bull/bear disabled
    context.config_bull =
      ichi: new Ichimoku(8, 11, 11, 11, 10)
      sar:
        accel: 0.025
        max: 0.2
      aroon:
        period: 10
      macd:
        fast: 10
        slow: 21
        signal: 8
      rsi:
        period: 20
      stoch:
        k_fast: 14
        k_slow: 3
        d_slow: 3
      mfi:
        period: 21

    # bear market config (ie. bull_bear_enabled = true)
    #  - only the config for the indicators specified above is required
    #  - any additional config (eg. thresholds, etc) may be added as needed
    #  - safe to remove if bull/bear disabled
    context.config_bear =
      ichi: new Ichimoku(7, 10, 11, 11, 42)
      sar:
        accel: 0.025
        max: 0.2
      aroon:
        period: 5
      macd:
        fast: 14
        slow: 22
        signal: 9
      rsi:
        period: 20
      stoch:
        k_fast: 14
        k_slow: 3
        d_slow: 3
      mfi:
        period: 21

    # all markets config (ie. bull_bear_enabled = false)
    #  - only the config for the indicators specified above is required
    #  - any additional config (eg. thresholds, etc) may be added as needed
    #  - safe to remove if bull/bear enabled
    context.config = {}

    # limit order configuration
    # use this to control execution of limit orders
    context.limit_order_enabled = false
    context.limit_sell_adjust = 0.02
    context.limit_buy_adjust = 0.02
    context.limit_max_retries = 10
    context.limit_timeout = 60

    # partial order configuration
    # use this to control execution of partial orders
    context.partial_order_enabled = false
    context.partial_strategy = 'parts' # percent, parts, amount, random
    context.partial_percent = 50
    context.partial_amount = 0.24
    context.partial_parts = 10
    context.partial_rand_min = 0.1
    context.partial_rand_max = 0.5

    # kelly criterion configuration
    # use this to enable auto sizing of orders
    context.kelly_enabled = false
    context.kelly_rsi_period = 20
    context.kelly_min_amt = 0.1

    # used to prevent trades when balances are too low
    # set this to match the fee of the exchange you are using
    context.fee_percent = 0.2
    context.min_asset_amt = 0.01

    # miscellaneous
    context.trade_period_mins = 120
    context.price_decimals = 3

    # test mode is for backtesting only!
    # use with at least 10 BTC and $5000
    context.test_mode = false

    # enable/disable plot lines
    context.plot = true
    context.plot_offset = null

    # enable/disable tick logging and frequency
    context.tick = true
    context.tick_freq = 1

    # DO NOT MODIFY!
    context.tick_cnt = 0
    context.init = true


#==========================================================#

# Decision Maker - core buy/sell logic
class D
  @decide: (context, ins, config, price, ind) ->
    # Plot
    if context.plot
      context.plot_offset = ins.price if !context.plot_offset
      plot
    # plot data

    #############################################
    ## SELL
    #############################################

    # mix/match/combine the indicators to generate sell signals here


    # mix/match/combine the sell signals to determine bearish-ness
    bearish = false


    # if bearish, sell!
    if bearish
      T.sell(context, ins)


    #############################################
    ## BUY
    #############################################

    # mix/match/combine the indicators to generate buy signals


    # mix/match/combine the buy signals to determine bullish-ness
    bullish = false


    # if bullish, buy!
    if bullish
      T.buy(context, ins)


#==========================================================#
# TA-Lib & Other Indicators
class A
  # EMA
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

  # WMA
  @wma: (data, period, last = true) ->
    if period == 1
      results = data
    else
      period = data.length unless data.length >= period
      results = talib.WMA
        inReal: data
        startIdx: 0
        endIdx: data.length - 1
        optInTimePeriod: period
    if last then _.last(results) else results

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

  # Aroon
  @aroon: (high, low, period, last = true) ->
    period = high.length unless high.length >= period
    results = talib.AROON
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - 1
      optInTimePeriod: period
    if last
      result =
        up: _.last(results.outAroonUp)
        down: _.last(results.outAroonDown)
    else
      result =
        up: results.outAroonUp
        down: results.outAroonDown
    result

  # Aroon Oscillator
  @aroonosc: (high, low, period, last = true) ->
    period = high.length unless high.length >= period
    results = talib.AROONOSC
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - 1
      optInTimePeriod: period
    if last then _.last(results) else results

  # Parabolic SAR
  @sar: (high, low, accel, max, last = true) ->
    period = high.length unless high.length >= period
    results = talib.SAR
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - 1
      optInAcceleration: accel
      optInMaximum: max
    if last then _.last(results) else results

  # MACD
  @macd: (data, fast_period, slow_period, signal_period, last = true) ->
    results = talib.MACD
      inReal: data
      startIdx: 0
      endIdx: data.length - 1
      optInFastPeriod: fast_period
      optInSlowPeriod: slow_period
      optInSignalPeriod: signal_period
    if last
      result =
        macd: _.last(results.outMACD)
        signal: _.last(results.outMACDSignal)
        histogram: _.last(results.outMACDHist)
    else
      result =
        macd: results.outMACD
        signal: results.outMACDSignal
        histogram: results.outMACDHist
    result

  # Linear Regression Slope
  @slope: (data, period, last = true) ->
    period = data.length unless data.length >= period
    results = talib.LINEARREG_SLOPE
      inReal: data
      startIdx: 0
      endIdx: data.length - 1
      optInTimePeriod: period
    if last then _.last(results) else results

  # Linear Regression Angle
  @angle: (data, period, last = true) ->
    period = data.length unless data.length >= period
    results = talib.LINEARREG_ANGLE
      inReal: data
      startIdx: 0
      endIdx: data.length - 1
      optInTimePeriod: period
    if last then _.last(results) else results

  # Stochastic
  @stoch: (high, low, close, k_period_fast, k_period_slow, d_period_slow, ma_type = 0, last = true) ->
    # MAType: 0=SMA, 1=EMA, 2=WMA, 3=DEMA, 4=TEMA, 5=TRIMA, 6=KAMA, 7=MAMA, 8=T3 (Default=SMA)
    results = talib.STOCH
      high: high
      low: low
      close: close
      startIdx: 0
      endIdx: close.length - 1
      optInFastK_Period: k_period_fast
      optInSlowK_Period: k_period_slow
      optInSlowK_MAType: ma_type
      optInSlowD_Period: d_period_slow
      optInSlowD_MAType: ma_type
    if last
      result =
        k: _.last(results.outSlowK)
        d: _.last(results.outSlowD)
    else
      result =
        k: results.outSlowK
        d: results.outSlowD
    result

  # RSI
  @rsi: (data, period, last = true) ->
    period = data.length unless data.length >= period
    results = talib.RSI
      inReal: data
      startIdx: 0
      endIdx: data.length - 1
      optInTimePeriod: period
    if last then _.last(results) else results

  # MFI
  @mfi: (high, low, close, volume, period, last = true) ->
    period = close.length unless close.length >= period
    results = talib.MFI
      high: high
      low: low
      close: close
      volume: volume
      startIdx: 0
      endIdx: close.length - 1
      optInTimePeriod: period
    if last then _.last(results) else results


  # Savitzky-Golay Filter/Smoothing
  # http://www.chem.uoa.gr/applets/appletsmooth/appl_smooth2.html
  # http://www.vias.org/tmdatanaleng/cc_savgol_coeff.html
  @sg: (data, n = 11, last = true) ->
    coeffs = {
      5: [-3, 12, 17],
      7: [-2, 3, 6, 7],
      9: [-21, 14, 39, 54, 59],
      11: [-36, 9, 44, 69, 84, 89],
      13: [-11, 0, 9, 16, 21, 24, 25],
      15: [-78, -13, 42, 87, 122, 147, 162, 167],
      17: [-21, -6, 7, 18, 27, 34, 39, 42, 43],
      19: [-136, -51, 24, 89, 144, 189, 224, 249, 264, 269],
      21: [-171, -76, 9, 84, 149, 204, 249, 284, 309, 324, 329],
      23: [-42, -21, -2, 15, 30, 43, 54, 63, 70, 75, 78, 79],
      25: [-253, -138, -33, 62, 147, 222, 287, 343, 387, 422, 447, 462, 467]
    }
    results = []
    if data.length <= coeffs[n].length
      return results
    for d in [0..(data.length - coeffs[n].length - 1)]
      num = 0
      den = 0
      for c in [1..coeffs[n].length]
        coeff = F.prev(coeffs[n], c)
        num += coeff * F.prev(data, d + c)
        den += coeff
      results.unshift(F.rnd(num / den))
    if last then _.last(results) else results

  # Rainbow
  @rainbow: (data, last = true) ->
    period = 2
    wma0 = @wma(data, period, false)
    wma1 = @wma(wma0, period, false)
    wma2 = @wma(wma1, period, false)
    wma3 = @wma(wma2, period, false)
    wma4 = @wma(wma3, period, false)
    wma5 = @wma(wma4, period, false)
    wma6 = @wma(wma5, period, false)
    wma7 = @wma(wma6, period, false)
    wma8 = @wma(wma7, period, false)
    wma9 = @wma(wma8, period, false)
    results = []
    for i in [0..wma9.length - 1]
      results.push(@_rainbow(wma0[i + 9], wma1[i + 8], wma2[i + 7], wma3[i + 6],
        wma4[i + 5], wma5[i + 4], wma6[i + 3], wma7[i + 2], wma8[i + 1], wma9[i]))
    if last then _.last(results) else results

  # calc rainbow
  @_rainbow: (i0, i1, i2, i3, i4, i5, i6, i7, i8, i9) ->
    (5 * i0 + 4 * i1 + 3 * i2 + 2 * i3 + i4 + i5 + i6 + i7 + i8 + i9) / 20


#==========================================================#

# Utility Functions
class F
  # percent difference between values
  @diff: (x, y) ->
    ((x - y) / ((x + y) / 2)) * 100

  # round a value to specified number decimal places
  @rnd = (x, d = 3) ->
    if d <= 0 then return Math.round(x)
    n = Math.pow(10, (if d < 0 then 0 else d))
    Math.round(x * n) / n

  # retrieve nth value from end of array
  @prev = (data, n) ->
    data[-n..][0]

  # scale a value between two points (r0-r1) based
  # on a reference range and value (v0-v1, v)
  @scale: (r0, r1, v0, v1, v, limit = false) ->
    if limit and v < v0 then v = v0
    if limit and v > v1 then v = v1
    if v0 == v1 then (r0 + r1) / 2 else (v - v0) / (v1 - v0) * (r1 - r0) + r0

  # restrict array length to specified max
  @splice: (arr, l) ->
    while arr.length > l
      arr.splice(0, 1)

  # populates the target array with instrument price data
  @populate: (target, ins) ->
    for i in [0..ins.close.length - 1]
      t =
        open: ins.open[..i]
        close: ins.close[..i]
        high: ins.high[..i]
        low: ins.low[..i]
        volumes: ins.volumes[..i]
      target.put(t)

  # dump an object
  @dump: (o, label = "object") ->
    if o
      debug "#{label}:"
      for own key, value of o
        debug "* #{key} : #{value}"
    else
      debug "#{label}: null"

  # was there a bull cross during last n periods?
  @bull_cross: (data, ref, n = 5) ->
    if _.isArray(ref)
      crossed = _.last(data) > _.last(ref)
    else
      crossed = _.last(data) > ref
    crossed and @was_lt(data, ref, n)

  # was there a bear cross during last n periods?
  @bear_cross: (data, ref, n = 5) ->
    if _.isArray(ref)
      crossed = _.last(data) < _.last(ref)
    else
      crossed = _.last(data) < ref
    crossed and @was_gt(data, ref, n)

  # were any of the data values greater than
  # the reference values for the last n periods?
  @was_gt: (data, ref, n = 5) ->
    @_was(data, ref, n, (x, y) -> y > x)

  # were any of the data values equal to
  # the reference values for the last n periods?
  @was_eq: (data, ref, n = 5) ->
    @_was(data, ref, n, (x, y) -> y == x)

  # were any of the data values greater than or equal to
  # the reference values for the last n periods?
  @was_gte: (data, ref, n = 5) ->
    @_was(data, ref, n, (x, y) -> y >= x)

  # were any of the data values less than
  # the reference values for the last n periods?
  @was_lt: (data, ref, n = 5) ->
    @_was(data, ref, n, (x, y) -> y < x)

  # were any of the data values less than or equal to
  # the reference values for the last n periods?
  @was_lte: (data, ref, n = 5) ->
    @_was(data, ref, n, (x, y) -> y <= x)

  @_was: (data, ref, n, cb) ->
    if _.isArray(ref)
      result = false
      if ref.length and data.length and n > 0
        n = _.min([ref.length, data.length, n])
        for i in [1..n]
          if cb(ref[ref.length - i], data[data.length - i])
            result = true
            break
      result
    else
      result = data[-n..].filter (y) -> cb(ref, y)
      result.length


#==========================================================#

# Trade Operations
class T
  @buy: (context, ins, amt = null) ->
    if context.test_mode
      # execute test mode buy
      return buy(ins, context.min_asset_amt)

    else
      # [kelly] determine asset amount to buy (if specific amount not set)
      if !amt and context.kelly_enabled
        amt = @kelly_amt_buy(context, ins)

      # determine fiat cost to buy asset
      if amt
        fiat_amt = ins.price * amt
      else
        amt = portfolio.positions[ins.curr()].amount / ins.price
        fiat_amt = portfolio.positions[ins.curr()].amount

      # determine fiat reserve amount
      fiat_reserve = portfolio.positions[ins.curr()].amount - fiat_amt

      # if possible, buy determined amount of asset
      if @can_buy(context, ins, fiat_amt, fiat_reserve)
        result = null
        if context.partial_order_enabled
          # [partial] buy via partial orders
          result = @part_buy(context, ins, amt, fiat_reserve)
        else
          # buy via single order
          result = @_do_buy(context, ins, amt)

        if result
          debug T.position(ins)
          debug '==========================================='

        # return trade result
        return result

    # buy skipped
    return null

  @sell: (context, ins, amt = null) ->
    if context.test_mode
      # execute test mode sell
      return sell(ins, context.min_asset_amt)

    else
      # [kelly] determine asset amount to sell (if specific amount not set)
      if !amt and context.kelly_enabled
        amt = @kelly_amt_sell(context, ins)

      # determine asset amount to sell
      if !amt
        amt = portfolio.positions[ins.asset()].amount

      # determine asset reserve amount
      amt_reserve = portfolio.positions[ins.asset()].amount - amt

      # if possible, sell determined amount of asset
      if @can_sell(context, ins, amt, amt_reserve)
        result = null
        if context.partial_order_enabled
          # [partial] sell via partial orders
          result = @part_sell(context, ins, amt, amt_reserve)
        else
          # sell via single order
          result = @_do_sell(context, ins, amt)

        if result
          debug T.position(ins)
          debug '==========================================='

        # return trade result
        return result

    # sell skipped
    return null

  @part_buy: (context, ins, amt, fiat_reserve) ->
    switch context.partial_strategy
      when 'percent' then return @_part_buy_percent(context, ins, amt, fiat_reserve)
      when 'parts' then return @_part_buy_parts(context, ins, amt, fiat_reserve)
      when 'amount' then return @_part_buy_amount(context, ins, amt, fiat_reserve)
      when 'random' then return @_part_buy_random(context, ins, amt, fiat_reserve)
      else
        warn "Invalid partial order strategy: #{context.partial_strategy}!"
    return null

  @part_sell: (context, ins, amt, amt_reserve) ->
    switch context.partial_strategy
      when 'percent' then return @_part_sell_percent(context, ins, amt, amt_reserve)
      when 'parts' then return @_part_sell_parts(context, ins, amt, amt_reserve)
      when 'amount' then return @_part_sell_amount(context, ins, amt, amt_reserve)
      when 'random' then return @_part_sell_random(context, ins, amt, amt_reserve)
      else
        warn "Invalid partial order strategy: #{context.partial_strategy}!"
    return null

  @lim_buy: (context, ins, amt = null) ->
    price = ins.price
    info "Base buy price: #{price}"
    x = 0
    while x < context.limit_max_retries
      x++
      price = F.rnd(price * (1 + context.limit_buy_adjust / 100), context.price_decimals)
      info "* ##{x} -> adjusted buy price: #{price}"
      trade = buy(ins, amt, price, context.limit_timeout)
      if trade then return trade
    return null

  @lim_sell: (context, ins, amt = null) ->
    price = ins.price
    warn "Base sell price: #{price}"
    x = 0
    while x < context.limit_max_retries
      x++
      price = F.rnd(price * (1 - context.limit_sell_adjust / 100), context.price_decimals)
      warn "* ##{x} -> adjusted sell price: #{price}"
      trade = sell(ins, amt, price, context.limit_timeout)
      if trade then return trade
    return null

  @can_buy: (context, ins, fiat_amt, fiat_reserve = 0) ->
    fiat_amt >= ((ins.price * context.min_asset_amt) * (1 + context.fee_percent / 100)) and fiat_amt <= portfolio.positions[ins.curr()].amount - fiat_reserve * 0.9999

  @can_sell: (context, ins, asset_amt, asset_reserve = 0) ->
    asset_amt >= context.min_asset_amt and asset_amt <= portfolio.positions[ins.asset()].amount - asset_reserve * 0.9999

  @position: (ins) ->
    asset_amt = portfolio.positions[ins.asset()].amount
    asset_value = asset_amt * ins.price
    curr_amt = portfolio.positions[ins.curr()].amount
    total_value = asset_value + curr_amt
    return "Position => #{F.rnd(asset_amt, 2)} BTC ($#{F.rnd(asset_value, 2)}) + $#{F.rnd(curr_amt, 2)} = $#{F.rnd(total_value, 2)} (#{F.rnd((total_value) / ins.price, 2)} BTC)"

  @kelly_amt_buy: (context, ins) ->
    fraction = @_kelly_fraction(context, ins)
    max_amt = portfolio.positions[ins.curr()].amount / ins.price
    return _.max([max_amt * fraction, _.min([_.max([context.kelly_min_amt, context.min_asset_amt]), max_amt])])

  @kelly_amt_sell: (context, ins) ->
    fraction = @_kelly_fraction(context, ins)
    max_amt = portfolio.positions[ins.asset()].amount
    return _.max([max_amt * fraction, _.min([_.max([context.kelly_min_amt, context.min_asset_amt]), max_amt])])

  @_kelly_fraction: (context, ins) ->
    return 2 * (A.rsi(ins.close, context.kelly_rsi_period, true) / 100) - 1

  @_do_buy: (context, ins, amt = null) ->
    if context.limit_order_enabled
      return @lim_buy(context, ins, amt)
    return buy(ins, amt)

  @_do_sell: (context, ins, amt = null) ->
    if context.limit_order_enabled
      return @lim_sell(context, ins, amt)
    return sell(ins, amt)

  @_part_buy_percent: (context, ins, amt, fiat_reserve) ->
    spend = ins.price * amt * context.partial_percent / 100
    return @_do_part_buy(context, ins, ((context, ins) -> spend), fiat_reserve)

  @_part_buy_parts: (context, ins, amt, fiat_reserve) ->
    spend = ins.price * amt / context.partial_parts
    return @_do_part_buy(context, ins, ((context, ins) -> spend), fiat_reserve)

  @_part_buy_amount: (context, ins, amt, fiat_reserve) ->
    return @_do_part_buy(context, ins, ((context, ins) -> ins.price * context.partial_amount), fiat_reserve)

  @_part_buy_random: (context, ins, amt, fiat_reserve) ->
    return @_do_part_buy(context, ins, ((context, ins) -> ins.price * amt * (Math.random() * (context.partial_rand_max - context.partial_rand_min) + context.partial_rand_min)), fiat_reserve)

  @_part_sell_percent: (context, ins, amt, amt_reserve) ->
    return @_do_part_sell(context, ins, ((context, ins) -> amt * context.partial_percent / 100), amt_reserve)

  @_part_sell_parts: (context, ins, amt, amt_reserve) ->
    offer = amt / context.partial_parts
    return @_do_part_sell(context, ins, ((context, ins) -> offer), amt_reserve)

  @_part_sell_amount: (context, ins, amt, amt_reserve) ->
    return @_do_part_sell(context, ins, ((context, ins) -> context.partial_amount), amt_reserve)

  @_part_sell_random: (context, ins, amt, amt_reserve) ->
    return @_do_part_sell(context, ins, ((context, ins) -> amt * (Math.random() * (context.partial_rand_max - context.partial_rand_min) + context.partial_rand_min)), amt_reserve)

  @_do_part_buy: (context, ins, strategy, fiat_reserve) ->
    spend = @_spend(context, ins, strategy, fiat_reserve)
    trade = null
    i = 0
    while @can_buy(context, ins, spend, fiat_reserve) and i < @_max_parts(context)
      amt = F.rnd(spend / ins.price, context.price_decimals)
      info ">> Partial buy amount ##{++i}: #{amt}"
      result = @_do_buy(context, ins, amt)
      if result then trade = result
      spend = @_spend(context, ins, strategy, fiat_reserve)
      info '==========================================='
    return trade

  @_do_part_sell: (context, ins, strategy, amt_reserve) ->
    offer = @_offer(context, ins, strategy, amt_reserve)
    trade = null
    i = 0
    while @can_sell(context, ins, offer, amt_reserve) and i < @_max_parts(context)
      amt = F.rnd(offer)
      warn ">> Partial sell amount ##{++i}: #{amt}"
      result = @_do_sell(context, ins, amt)
      if result then trade = result
      offer = @_offer(context, ins, strategy, amt_reserve)
      warn '==========================================='
    return trade

  @_max_parts: (context) ->
    trade_timeout = if context.limit_order_enabled then context.limit_timeout else 30
    Math.round(context.trade_period_mins * 60 / trade_timeout) - 1

  @_spend: (context, ins, strategy, fiat_reserve) ->
    spend = _.min([portfolio.positions[ins.curr()].amount - fiat_reserve, strategy(context, ins)])
    _.max([context.min_asset_amt * ins.price * (1 + context.fee_percent / 100), spend])

  @_offer: (context, ins, strategy, amt_reserve) ->
    offer = _.min([portfolio.positions[ins.asset()].amount - amt_reserve, strategy(context, ins)])
    _.max([context.min_asset_amt, offer])


#==========================================================#

# Ichimoku
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
      chikou_span: F.diff(@chikou[@chikou.length - 1], @chikou[0])
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
    F.splice(@senkou_a, @senkou_a_n)
    # update senkou span b
    @senkou_b.push(this._hla(ins, @senkou_b_n * 2))
    F.splice(@senkou_b, @senkou_b_n)
    # update chikou span
    @chikou.push(ins.close[ins.close.length - 1])
    F.splice(@chikou, @chikou_n)

  # calc average of price extremes (high-low avg) over specified period
  _hla: (ins, n) ->
    hh = _.max(ins.high[-n..])
    ll = _.min(ins.low[-n..])
    return (hh + ll) / 2


#==========================================================#

# Heikin-Ashi Candles
class HeikinAshi
  constructor: (@ha_method = 3) ->
    @ins =
      open: []
      close: []
      high: []
      low: []
      volumes: []

  # update with latest instrument price data
  put: (ins) ->
    # push raw volume
    @ins.volumes.push(ins.volumes[ins.volumes.length - 1])

    # current raw candle (open/close/high/low)
    curr_open = ins.open[ins.open.length - 1]
    curr_close = ins.close[ins.close.length - 1]
    curr_high = ins.high[ins.high.length - 1]
    curr_low = ins.low[ins.low.length - 1]
    if @ha_method <= 0
      # HA Disabled!
      @ins.open.push(curr_open)
      @ins.close.push(curr_close)
      @ins.high.push(curr_high)
      @ins.low.push(curr_low)

    # There seem to be two main ways to calculate Heikin-Ashi candlesticks...
    if @ha_method == 1
      # HA Method 1 -  implemented in accordance with:
      #  - http://www.investopedia.com/terms/h/heikinashi.asp
      #  - http://www.forextraders.com/forex-indicators/heiken-ashi-indicator-explained.html
      if @ins.open.length == 0
        # initial candle
        @ins.open.push(curr_open)
        @ins.close.push(curr_close)
        @ins.high.push(curr_high)
        @ins.low.push(curr_low)
      else
        # every other candle
        prev_open = ins.open[ins.open.length - 2]
        prev_close = ins.close[ins.close.length - 2]
        @ins.open.push((prev_open + prev_close) / 2)
        @ins.close.push((curr_open + curr_close + curr_high + curr_low) / 4)
        @ins.high.push(_.max([curr_high, curr_open, curr_close]))
        @ins.low.push(_.min([curr_low, curr_open, curr_close]))

    if @ha_method == 2
      # HA Method 2 -  implemented in accordance with:
      #  - http://daytrading.about.com/od/indicators/a/HeikinAshi.htm
      #  - http://stockcharts.com/help/doku.php?id=chart_school:chart_analysis:heikin_ashi#calculation
      if @ins.open.length == 0
        # initial candle
        @ins.open.push((curr_open + curr_close) / 2)
        @ins.close.push((curr_open + curr_close + curr_high + curr_low) / 4)
        @ins.high.push(curr_high)
        @ins.low.push(curr_low)
      else
        # every other candle
        # previous ha candle open/close
        prev_open_ha = @ins.open[@ins.open.length - 1]
        prev_close_ha = @ins.close[@ins.close.length - 1]
        # calculate current ha candle
        curr_open_ha = (prev_open_ha + prev_close_ha) / 2
        curr_close_ha = (curr_open + curr_close + curr_high + curr_low) / 4
        @ins.open.push(curr_open_ha)
        @ins.close.push(curr_close_ha)
        @ins.high.push(_.max([curr_high, curr_open_ha, curr_close_ha]))
        @ins.low.push(_.min([curr_low, curr_open_ha, curr_close_ha]))

    if @ha_method == 3
      # HA Method 3 - similar to method 2 except open is based on
      # previous raw candle instead of previous HA candle.
      if @ins.open.length == 0
        # initial candle
        @ins.open.push(curr_open)
        @ins.close.push(curr_close)
        @ins.high.push(curr_high)
        @ins.low.push(curr_low)
      else
        # every other candle
        # previous raw candle open/close
        prev_open = ins.open[ins.open.length - 2]
        prev_close = ins.close[ins.close.length - 2]
        # calculate current ha candle
        curr_open_ha = (prev_open + prev_close) / 2
        curr_close_ha = (curr_open + curr_close + curr_high + curr_low) / 4
        @ins.open.push(curr_open_ha)
        @ins.close.push(curr_close_ha)
        @ins.high.push(_.max([curr_high, curr_open_ha, curr_close_ha]))
        @ins.low.push(_.min([curr_low, curr_open_ha, curr_close_ha]))

    if @ha_method == 4
      # HA Method 4 - similar to method 2 except open is based on
      # combination of previous raw candle and previous HA candle.
      if @ins.open.length == 0
        # initial candle
        @ins.open.push(curr_open)
        @ins.close.push(curr_close)
        @ins.high.push(curr_high)
        @ins.low.push(curr_low)
      else
        # every other candle
        # previous raw candle (close)
        prev_close = ins.close[ins.close.length - 2]
        # previous ha candle (open)
        prev_open_ha = @ins.open[@ins.open.length - 1]
        # calculate current ha candle
        curr_open_ha = (prev_open_ha + prev_close) / 2
        curr_close_ha = (curr_open + curr_close + curr_high + curr_low) / 4
        @ins.open.push(curr_open_ha)
        @ins.close.push(curr_close_ha)
        @ins.high.push(_.max([curr_high, curr_open_ha, curr_close_ha]))
        @ins.low.push(_.min([curr_low, curr_open_ha, curr_close_ha]))

    # restrict array lengths to reasonable max
    _max_length = 250
    F.splice(@ins.open, _max_length)
    F.splice(@ins.close, _max_length)
    F.splice(@ins.high, _max_length)
    F.splice(@ins.low, _max_length)
    F.splice(@ins.volumes, _max_length)


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
  # get instrument
  ins = data.instruments[0]

  # handle instrument data
  if context.init
    # initialise heikin-ashi
    F.populate(context.ha, ins)
    # initialise ichimoku (from heikin-ashi data)
    if 'ichi' in context.indicators
      F.populate(context.config_bull.ichi, context.ha.ins)
      F.populate(context.config_bear.ichi, context.ha.ins)
    # initialisation complete
    context.init = false
  else
    # handle new instrument (via heikin-ashi)
    context.ha.put(ins)
    # initialise ichimoku (from heikin-ashi data)
    if 'ichi' in context.indicators
      context.config_bull.ichi.put(context.ha.ins)
      context.config_bear.ichi.put(context.ha.ins)

  # historic price values to be used with signals
  price = context.ha.ins.close

  # plot price
  if context.plot
    plot
      price: _.last(price)

  # market determination
  if context.bull_bear_enabled
    # determine current market condition (bull/bear)
    short = A.ema(context.ha.ins.close, context.market_short)
    long = A.ema(context.ha.ins.close, context.market_long)
    mkt_diff = F.diff(short, long)
    is_bull = mkt_diff >= context.bull_market_threshold
    is_bear = mkt_diff <= context.bear_market_threshold
    # plot market data
    if context.plot
      plot
        short: short
        long: long

  # market config
  trend = '[no trend]'
  if is_bull and context.config_bull
    trend = '[bullish]'
    config = context.config_bull
  else if is_bear and context.config_bear
    trend = '[bearish]'
    config = context.config_bear
  else if context.config
    trend = ''
    config = context.config

  # log tick
  Tick.tick(context, "#{trend}")

  # abort if no config found
  # this usually indicates market is between bull/bear
  if !config
    return

  # init indicator result
  ind = {}

  # calc ichimoku indicators
  if 'ichi' in context.indicators
    c = config.ichi.current()
    ichi =
      tk_diff: F.diff(c.tenkan, c.kijun)
      tenkan_min: _.min([c.tenkan, c.kijun])
      tenkan_max: _.max([c.tenkan, c.kijun])
      kumo_min: _.min([c.senkou_a, c.senkou_b])
      kumo_max: _.max([c.senkou_a, c.senkou_b])
    # copy in current ichi state
    for own key of c
      ichi[key] = c[key]
    ind.ichi = ichi

  # calc parabolic sar indicator
  if 'sar' in context.indicators
    ind.sar = A.sar(context.ha.ins.high, context.ha.ins.low, config.sar.accel, config.sar.max, false)

  # calc aroon indicator
  if 'aroon' in context.indicators
    ind.aroon = A.aroon(context.ha.ins.high, context.ha.ins.low, config.aroon.period, false)

  # calc rsi indicator
  if 'rsi' in context.indicators
    ind.rsi = A.rsi(context.ha.ins.close, config.rsi.period, false)

  # calc macd indicator
  if 'macd' in context.indicators
    ind.macd = A.macd(context.ha.ins.close, config.macd.fast, config.macd.slow, config.macd.signal, false)

  # calc stochastic indicator
  if 'stoch' in context.indicators
    ind.stoch = A.stoch(context.ha.ins.high, context.ha.ins.low, context.ha.ins.close, config.stoch.k_fast, config.stoch.k_slow, config.stoch.d_slow, false)

  # calc mfi indicator
  if 'mfi' in context.indicators
    ind.mfi = A.mfi(context.ha.ins.high, context.ha.ins.low, context.ha.ins.close, context.ha.ins.volumes, config.mfi.period, false)

  # decision time!
  D.decide(context, ins, config, price, ind)


serialize: (context) ->
  # serialize bot state
