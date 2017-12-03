###
  generic example how to find best parameters on the fly
  by cryptelligent
  see also: 
###

###*
# @int[] Array of values to iterate over
###

data = [
  1
  2
  3
  4
  5
]
# bogus data

###*
# Set of parameters to call function with and their configuration
#
# @type {Array}
###

params_config = [
  {
    name: 'short'
    min: 8
    max: 11
    increment: 1
  }
  {
    name: 'long'
    min: 10
    max: 12
    increment: 1
  }
  {
    name: 'extra'
    min: 100
    max: 102
    increment: 1
  }
]

###*
# Function that calculates value to be maximized (e.g. revenue)
#
# @param arr500[] - array of tick values
# @param params[] - array of input parameters
#
# @return maximizer - value to be maximized
###

f = (arr500, params) ->
  # DEFINE YOUR TRADING STRATEGY HERE

  # sample function that ignores data
  result = params.long * params.short - (params.extra)
  #console.log("Input:", params, "Output:", result);
  result

###*
# Function that figures out parameter values that produce highest value (e.g. highest revenue) on historical data
#
# @param params_config Configuration of all parameters to iterate over
# @param maximizer A function that generates a value to maximize
#
# @return {}
###

calculator = (params_config, maximizer) ->
  # 1. for each param combination, run f and collect resulting maximizer values
  # 2. find maximum maximizer value and return corresponding param values
  params_queue = params_config.reduce(((accumulator, param) ->
    new_accumulator = []
    if accumulator.length == 0
      val = param.min
      while val <= param.max
        new_result = {}
        new_result[param.name] = val
        # creating initial object with values of first item
        new_accumulator.push new_result
        val += param.increment
    else
      new_accumulator = accumulator.reduce(((new_results, result) ->
        `var val`
        `var new_result`
        val = param.min
        while val <= param.max
          new_result = Object.assign({}, result)
          # clone entry from previous step
          new_result[param.name] = val
          # add new value
          new_results.push new_result
          val += param.increment
        new_results
      ), [])
    new_accumulator
  ), [])
  # console.log("All parameter variations:", params_queue);
  if params_queue.length == 0
    return null
    # there are no parameters to pick from
  else if params_queue.length == 1
    return params_queue[0]
    # there is only one choice, let's return it
  values = params_queue.map(maximizer)
  max_index = 0
  max_value = values[0]
  i = 1
  while i < values.length
    if values[i] > max_value
      max_index = i
      max_value = values[i]
    i++
  params_queue[max_index]

console.log 'Parameters resulting in highest outcome:', calculator(params_config, (params) ->
  f data, params
)
