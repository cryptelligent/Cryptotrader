##https://cryptotrader.org/topics/485251/api-error-handling-for-order-processing
trading = require "trading"

handle: ->
  instrument = @data.instruments[0]
  try
    if trading.sell instrument
      debug 'SELL order traded'
  catch e
    if /insufficient funds/i.exec e
      debug "Insufficient funds error"
    else if /minimum order amount/i.exec e
      debug "Minimum order amount error"
    else
      throw e # rethrow an unhandled exception
