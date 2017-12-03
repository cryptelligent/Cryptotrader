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
