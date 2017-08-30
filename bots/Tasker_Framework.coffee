# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Tasker Framework v1.3.0 by sportpilot
#
#   Donations: 1561k5XqWFJSHP8apmvGt15ecWjw9ZLKGi
# by sportpilot
# https://cryptotrader.org/strategies/wZQRxi7EQD9rbP8wQ
class Tasker

  @init: (context)->
    #**************************
    #  Task settings
    #**************************
    context.tasks =         # Execution cycle in minutes, Start at this many minutes past the hour (null = start immediately)
      task1:
        active  : yes
#        period  : 1
#        start   : 58
        data    : "p13_0"
      task2:
        active  : yes
        period  : 1
#        data    : "p5_0"
      task3:
        active  : no
      task4:
        active  : no
        data    : "p5_3"
      task5:
        active  : no
        data    : "p9_0"
      task6:
        active  : no
        data    : "p15_12"
      task7:
        active  : no
        data    : "p30_0"

    context.periods =
      p13_0:
        cnt   : 13
        ofs   : 0
#        limit : 1150
#      p5_3:
#        cnt   : 5
#        ofs   : 3
#        limit : 1000
#      p9_0:
#        cnt   : 9
#        ofs   : 0
#        limit : 100
#      p15_12:
#        cnt   : 15
#        ofs   : 12
#        limit : 100
#      p30_0:
#        cnt   : 30
#        ofs   : 13
#        limit : 100

    context.details =
      silent  : no
      err     : yes
      hist    : yes
      curdata : yes
      curtick : yes
      start   : yes
      final   : no

    context.def_limit = 1000

    context.s15 = null
    context.l15 = null

    # Do not change
    context.ticks = []
    context.task_data = null
    context.start = null
    context.exec = no
    context.exec_email = no
    context.initialize = on
    context.time = null
    context.mins = null

    context.market = []
    context.trades = []


  @serialize: (context)->
    tasks: context.tasks
#    task_data: context.task_data
    ticks: context.ticks
    initialize: context.initialize
    start: context.start
    exec: context.exec
    exec_email: context.exec_email


  @handle: (context, data)->
    ins = data.instruments[0]
    cur = ins.close.length - 1
    context.time = data.at / 60000
    context.mins = context.time % 60
    if context.exec
      if context.exec_email
        if context.mins is 0
          sendEmail "Cycle did not complete. Check the bot!
            You will continue to receive this email every hour until corrected."
      else
        context.exec_email = yes
        sendEmail "Cycle did not complete. Check the bot!"
    else
      context.exec = yes

    if context.initialize
      context.start = data.at
      if fx.initialize(context, ins)
        fx.init_hist(ins, context, context.time)    # Derive longer period candle history
        if context.details.hist and not context.details.silent
          fx.disp_hist(context)
      else
        return
    else
      if context.details.curtick and not context.details.silent
        info "[#{cur}] At: #{ins.ticks[cur].at / 60000} |
          #{new Date(ins.ticks[cur].at).toLocaleTimeString()} | O: #{ins.open[cur].toFixed(3)} |
          H: #{ins.high[cur].toFixed(3)} | L: #{ins.low[cur].toFixed(3)} |
          C: #{ins.close[cur].toFixed(3)} | V: #{ins.volumes[cur].toFixed(3)}"

      fx.cur_data(ins, context, context.time)    # Derive longer period candles

    # Check for tasks that need running
    for k in _.keys(context.tasks) when context.tasks["#{k}"].active and context.time >= context.tasks["#{k}"].next
      Tasks["#{k}"](context, data)

    context.exec = no

  @finalize: (context)->
    if context.details.final and not context.details.silent
      debug "================================================="
      info "History ticks"
      debug "Runtime ticks"
      debug "================================================="
      for y in _.keys(context.periods)
        warn "[#{y}] - Offset = #{context.periods["#{y}"].ofs} |
          #{_.size(_.where(context.ticks["#{y}"], {hist: yes}))}
          History Ticks | #{_.size(_.where(context.ticks["#{y}"], {hist: no}))} Runtime Ticks"
        for x in context.ticks["#{y}"]
          msg = "[#{y}] At: #{new Date(x.at).toLocaleTimeString()} | O: #{x.open.toFixed(3)} |
            H: #{x.high.toFixed(3)} | L: #{x.low.toFixed(3)} | C: #{x.close.toFixed(3)} |
            V: #{x.volume.toFixed(3)}"
          if x.hist then info msg else debug msg
        debug "================================================="


class Tasks
#**************************
#  Task handlers
#**************************

  @task1: (context, data)->
    fx.reset_task(context, "task1")
# <- Demo code -------------------->
#    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#    debug ">> Task 1 << | Period: #{context.periods["#{context.tasks.task1.data}"].cnt} min |
#      Offset: #{context.periods["#{context.tasks.task1.data}"].ofs}"
#    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#    task_data = {instruments: [fx.ins_data(context, context.tasks.task1.data)]}
    fx.ins_data(context, context.tasks.task1.data)
    EMA.handle(context, data, 10, 21)
    # Stats run here
#    Stats.report(context)
# <- End Demo code -------------------->


  @task2: (context, data)->
    fx.reset_task(context, "task2")
# <- Demo code -------------------->
#    fx.ins_data(context, context.tasks.task2.data)
    EMA2.handle(context, data, 10, 21)
#    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#    debug ">> Task 2 << | Period: #{context.periods["#{context.tasks.task2.data}"].cnt} min |
#      Offset: #{context.periods["#{context.tasks.task2.data}"].ofs}"
#    y = context.tasks.task2.data
#    x = _.last(context.ticks["#{y}"])
#    warn "[#{y} (#{_.size(context.ticks["#{y}"])})] At: #{x.at / 60000} |
#      #{new Date(x.at).toLocaleTimeString()} | O: #{x.open.toFixed(3)} |
#      H: #{x.high.toFixed(3)} | L: #{x.low.toFixed(3)} | C: #{x.close.toFixed(3)} |
#      V: #{x.volume.toFixed(3)}"
#    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#
#    if (x.at / 60000) % 10 is 0
#    # Startup Task 3
#      fx.start_time(context, "task3", yes)
# <- End Demo code -------------------->


  @task3: (context, data)->
    fx.reset_task(context, "task3")
# <- Demo code -------------------->
    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    debug ">> Task 3 << | Run Once: Now"
    debug " *** Started by Task 2 ***"
    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# <- End Demo code -------------------->


  @task4: (context, data)->
    fx.reset_task(context, "task4")
# <- Demo code -------------------->
    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    debug ">> Task 4 << | Period: #{context.periods["#{context.tasks.task4.data}"].cnt} min |
      Offset: #{context.periods["#{context.tasks.task4.data}"].ofs}"
    y = context.tasks.task4.data
    x = _.last(context.ticks["#{y}"])
    warn "[#{y} (#{_.size(context.ticks["#{y}"])})] At: #{x.at / 60000} |
      #{new Date(x.at).toLocaleTimeString()} | O: #{x.open.toFixed(3)} |
      H: #{x.high.toFixed(3)} | L: #{x.low.toFixed(3)} | C: #{x.close.toFixed(3)} |
      V: #{x.volume.toFixed(3)}"
    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# <- End Demo code -------------------->


  @task5: (context, data)->
    fx.reset_task(context, "task5")
# <- Demo code -------------------->
    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    debug ">> Task 5 << | Period: #{context.periods["#{context.tasks.task5.data}"].cnt} min |
      Offset: #{context.periods["#{context.tasks.task5.data}"].ofs}"
    y = context.tasks.task5.data
    x = _.last(context.ticks["#{y}"])
    warn "[#{y} (#{_.size(context.ticks["#{y}"])})] At: #{x.at / 60000} |
      #{new Date(x.at).toLocaleTimeString()} | O: #{x.open.toFixed(3)} |
      H: #{x.high.toFixed(3)} | L: #{x.low.toFixed(3)} | C: #{x.close.toFixed(3)} |
      V: #{x.volume.toFixed(3)}"
    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# <- End Demo code -------------------->


  @task6: (context, data)->
    fx.reset_task(context, "task6")
# <- Demo code -------------------->
    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    debug ">> Task 6 << | Period: #{context.periods["#{context.tasks.task6.data}"].cnt} min |
      Offset: #{context.periods["#{context.tasks.task6.data}"].ofs}"
    y = context.tasks.task6.data
    x = _.last(context.ticks["#{y}"])
    warn "[#{y} (#{_.size(context.ticks["#{y}"])})] At: #{x.at / 60000} |
      #{new Date(x.at).toLocaleTimeString()} | O: #{x.open.toFixed(3)} |
      H: #{x.high.toFixed(3)} | L: #{x.low.toFixed(3)} | C: #{x.close.toFixed(3)} |
      V: #{x.volume.toFixed(3)}"
    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# <- End Demo code -------------------->


  @task7: (context, data)->
    fx.reset_task(context, "task7")
# <- Demo code -------------------->
    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    debug ">> Task 7 << | Period: #{context.periods["#{context.tasks.task7.data}"].cnt} min |
      Offset: #{context.periods["#{context.tasks.task7.data}"].ofs}"
    y = context.tasks.task7.data
    x = _.last(context.ticks["#{y}"])
    warn "[#{y} (#{_.size(context.ticks["#{y}"])})] At: #{x.at / 60000} |
      #{new Date(x.at).toLocaleTimeString()} | O: #{x.open.toFixed(3)} |
      H: #{x.high.toFixed(3)} | L: #{x.low.toFixed(3)} | C: #{x.close.toFixed(3)} |
      V: #{x.volume.toFixed(3)}"
    debug "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# <- End Demo code -------------------->


class Actions

  @buy: (context)->
    debug "Buy"
#    context.tasks.task1.active = no      # Shutdown Task 1

  @sell: (context)->
    debug "Sell"
#    context.tasks.task2.active = no      # Shutdown Task 2


class fx

  @initialize: (context, ins)->
    # make sure we are running at 1 min period
    y = []
    for x in [0...50]
      y.push (ins.ticks[x + 1].at / 60000) - (ins.ticks[x].at / 60000)
    z = {}
    for x in y
      if z["#{x}"]? then z["#{x}"]++ else z["#{x}"] = 1
    z = _.pick(z, 1, 5, 15, 30, 60, 120, 240, 480, 720, 1440)
    period = parseInt(k1 for k1,v1 of z when v1 is _.max(v for k,v of z))
    if period != 1
      warn "This code must run at a 1 min period to function correctly.
        It is currently running at a #{period} min period."
      return false
    else
      context.initialize = off
      # Initialize tasks
      for k in _.keys(context.tasks) when context.tasks["#{k}"].active
        fx.start_time(context, k)
      return true


  @start_time: (context, task, active = null)->
    if context.tasks["#{task}"].start?
      if context.tasks["#{task}"].start < context.mins
        context.tasks["#{task}"].next = context.tasks["#{task}"].start + 60 - context.mins + context.time
      else
        context.tasks["#{task}"].next = context.tasks["#{task}"].start - context.mins + context.time
    else
      if context.tasks["#{task}"].data?
        fx.start_per(context, task)
      else
        context.tasks["#{task}"].next = context.time       # This will work as long as this task is lower priority
    if active?
      context.tasks["#{task}"].active = active


  @start_per: (context, task)->
    y = context.tasks["#{task}"].data
    if not context.periods["#{y}"].limit? then context.periods["#{y}"].limit = context.def_limit
    if context.time % context.periods["#{y}"].cnt is 0 and context.periods["#{y}"].ofs is 0
      context.tasks["#{task}"].next = context.time
    else
      context.tasks["#{task}"].next = context.time - (context.time % context.periods["#{y}"].cnt) +
        context.periods["#{y}"].cnt - context.periods["#{y}"].ofs
      if context.tasks["#{task}"].next < context.time
        context.tasks["#{task}"].next += context.periods["#{y}"].cnt


  @reset_task: (context, task)->
    if context.tasks["#{task}"].period?
      context.tasks["#{task}"].next += context.tasks["#{task}"].period
    else
      if context.tasks["#{task}"].data?
        context.tasks["#{task}"].next += context.periods["#{context.tasks["#{task}"].data}"].cnt
      else
        context.tasks["#{task}"].active = no


  @per_data: (ins, context, idx, min, per, hist = no) ->
    y = []
    for x in [idx - per..idx] when min > (ins.ticks[x].at / 60000) >= min - per
      y.push x
    if context.details.curdata and not context.details.silent and hist is no
      debug "[#{y.length}] records  | #{new Date((min - per) * 60000).toLocaleTimeString()}
        <= [at] <= #{new Date((min - 1) * 60000).toLocaleTimeString()}"
    if _.size(y) is 0
      warn ">> Empty Tick <<"
      return null
    z =
      at: (min - per) * 60000
      open: ins.open[_.first(y)]
      high: _.max(ins.high[x] for x in y)
      low: _.min(ins.low[x] for x in y)
      close: ins.close[_.last(y)]
      volume: (ins.volumes[x] for x in y).reduce (x,y) -> x + y
      hist: hist
    if context.details.curdata and not context.details.silent and hist is no
      for x in y
        warn "[#{x}] At: #{ins.ticks[x].at / 60000} | #{new Date(ins.ticks[x].at).toLocaleTimeString()} |
          O: #{ins.open[x].toFixed(3)} | H: #{ins.high[x].toFixed(3)} | L: #{ins.low[x].toFixed(3)} |
          C: #{ins.close[x].toFixed(3)} | V: #{ins.volumes[x].toFixed(3)}"
    return z


  @hist_data: (ins, context) ->
    for x in [0...ins.ticks.length]
      for y in _.keys(context.periods) when x >= context.periods["#{y}"].cnt
        min = ins.ticks[x].at / 60000
        if (context.periods["#{y}"].next - min) % context.periods["#{y}"].cnt is 0
          if not context.ticks["#{y}"]?
            context.ticks["#{y}"] = []
          z = fx.per_data(ins, context, x, min, context.periods["#{y}"].cnt, yes)
          if z?
            if _.size(context.ticks["#{y}"]) >= context.periods["#{y}"].limit
#              context.ticks["#{y}"] = context.ticks["#{y}"].slice(-(context.periods["#{y}"].limit - 1))
              context.ticks["#{y}"].shift()
            context.ticks["#{y}"].push z
            if context.details.hist and not context.details.silent
              info "[#{y}(#{x})] At: #{z.at / 60000} | #{new Date(z.at).toLocaleTimeString()} |
                O: #{z.open.toFixed(3)} | H: #{z.high.toFixed(3)} | L: #{z.low.toFixed(3)} |
                C: #{z.close.toFixed(3)} | V: #{z.volume.toFixed(3)}"
          if context.periods["#{y}"].next is context.start
            context.periods["#{y}"].next += context.periods["#{y}"].cnt


  @cur_data: (ins, context, min) ->
    if ins.close.length is not ins.ticks.length
      if context.details.err and not context.details.silent
        warn " ***** Array mismatch *****"
    cur = ins.close.length - 1
    for y in _.keys(context.periods) when min >= context.periods["#{y}"].next
      if min >= context.periods["#{y}"].next + context.periods["#{y}"].cnt
        if context.details.err and not context.details.silent
          warn "***** Empty Tick *****"
      else
        z = fx.per_data(ins, context, cur, context.periods["#{y}"].next, context.periods["#{y}"].cnt)
        if z?
          if _.size(context.ticks["#{y}"]) >= context.periods["#{y}"].limit
#            context.ticks["#{y}"] = context.ticks["#{y}"].slice(-(context.periods["#{y}"].limit - 1))
            context.ticks["#{y}"].shift()
          context.ticks["#{y}"].push z
          if context.details.curdata and not context.details.silent
            debug "[#{y} (#{_.size(context.ticks["#{y}"])})] At: #{z.at / 60000} |
              #{new Date(z.at).toLocaleTimeString()} | O: #{z.open.toFixed(3)} | H: #{z.high.toFixed(3)} |
              L: #{z.low.toFixed(3)} | C: #{z.close.toFixed(3)} | V: #{z.volume.toFixed(3)}"
      context.periods["#{y}"].next += context.periods["#{y}"].cnt


  @init_hist: (ins, context, min) ->
    context.hist = off
    context.start = min
    # Initialize .next times for all periods
    for y in _.keys(context.periods)
      if min % context.periods["#{y}"].cnt is 0 and context.periods["#{y}"].ofs is 0
        context.periods["#{y}"].next = min
      else
        context.periods["#{y}"].next = min - (min % context.periods["#{y}"].cnt) +
          context.periods["#{y}"].cnt - context.periods["#{y}"].ofs
        if context.periods["#{y}"].next < min
          context.periods["#{y}"].next += context.periods["#{y}"].cnt
    fx.hist_data(ins, context)                # Process History
    if context.details.start and not context.details.silent
      debug "================================================================================="
      warn "Start: #{new Date(min * 60000).toLocaleTimeString()} (all times are UTC)"
      for x in _.keys(context.tasks) when context.tasks["#{x}"].active
        task = x.slice(-1)
        if not context.tasks["#{x}"].data?
          debug "Task #{task}: [ins] Period: #{context.tasks["#{x}"].period} |
            #{if context.tasks["#{x}"].start? then "Offset: #{context.tasks["#{x}"].start} |" else ""}
            Next: #{new Date(min * 60000).toLocaleTimeString()} |
            History: #{_.size(ins.close)} records"
        else
          for y in _.keys(context.periods) when context.tasks["#{x}"].data is y
            debug "Task #{task}: [#{y}] Period: #{context.periods["#{y}"].cnt} | Offset: #{context.periods["#{y}"].ofs} |
              Next: #{new Date(context.periods["#{y}"].next * 60000).toLocaleTimeString()} |
              History: #{_.size(context.ticks["#{y}"])} records"
      debug "================================================================================="


  @disp_hist: (context) ->
    debug "================================================="
    info "History ticks"
#    debug "Runtime ticks"
    debug "================================================="
    for y in _.keys(context.periods)
      warn "[#{y}] - Offset = #{context.periods["#{y}"].ofs} |
        #{_.size(_.where(context.ticks["#{y}"], {hist: yes}))}
        History Ticks | #{_.size(_.where(context.ticks["#{y}"], {hist: no}))} Runtime Ticks"
      for x in context.ticks["#{y}"]
        msg = "[#{y}] At: #{new Date(x.at).toLocaleTimeString()} | O: #{x.open.toFixed(3)} |
          H: #{x.high.toFixed(3)} | L: #{x.low.toFixed(3)} | C: #{x.close.toFixed(3)} |
          V: #{x.volume.toFixed(3)}"
        if x.hist then info msg else debug msg
      debug "================================================="


  @ins_data: (context, task_data) ->
    ins = {open: [], low: [], high: [], close: [], volumes: [], ticks: []}
    for x in context.ticks["#{task_data}"]
      ins.open.push x.open
      ins.low.push x.low
      ins.high.push x.high
      ins.close.push x.close
      ins.volumes.push x.volume
      ins.ticks.push x
    context.task_data = {instruments: [ins]}


class ind

  @ema: (data, period, start = 0, end = data.length - 1)->
    if period > data.length then period = data.length
    ema = talib.EMA
      inReal : data
      startIdx: start
      endIdx: end
      optInTimePeriod: period
    ema = _.last ema


#**************************
#  Strategy Packages
#**************************

class EMA

  @init: (context) ->
    context.buy_threshold = 0.025
    context.sell_threshold = 0.25

  @handle: (context, data, s, l) ->
    instrument = data.instruments[0]
    ins = context.task_data.instruments[0]

    short = ind.ema(ins.close, s)
    long = ind.ema(ins.close, l)
    context.s15 = short
    context.l15 = long

    plot
     short10: short
     long21: long

    diff = 100 * (short - long) / ((short + long) / 2)
#    debug "short: #{short.toFixed(3)} | long: #{long.toFixed(3)} | diff: #{diff.toFixed(3)}"
#    if diff > context.buy_treshold
#      sell instrument
##      Stats.sell context, data
#    else
#      if diff < -context.sell_treshold
#        buy instrument
##        Stats.buy context, data


class EMA2

  @init: (context) ->
    context.buy_threshold = 0.025
    context.sell_threshold = 0.25

  @handle: (context, data, s, l) ->
    instrument = data.instruments[0]
#    ins = context.task_data.instruments[0]
    ins = instrument

    short = ind.ema(ins.close, s)
    long = ind.ema(ins.close, l)
    xlong = ind.ema(ins.close, 30)

    plot
     short2: short
     long9: long
#     xlong30: xlong

    diff = 100 * (short - long) / ((short + long) / 2)
    diffl = 100 * (context.s15 - context.l15) / ((context.s15 + context.l15) / 2)
    diffx = 100 * (long - context.s15) / ((long + context.l15) / 2)
#    debug "short: #{short.toFixed(3)} | long: #{long.toFixed(3)} | diff: #{diff.toFixed(3)}"
    if context.s15? and context.l15?
      if diff > context.buy_threshold and diffl > 0.09 and diffx > 0.05
        buy instrument
##        Stats.buy context, data
      else
        if short < xlong
          sell instrument
##      Stats.sell context, data


#**************************
#  Runtime methods
#**************************

init: (context) ->
  Tasker.init(context)
  EMA.init(context)

serialize: (context)->
  _.extend(Tasker.serialize(context), {})

handle: (context, data)->
  Tasker.handle(context, data)       # Stats.handle should come BEFORE Tasker.handle

finalize: (context) ->
  Tasker.finalize(context)
