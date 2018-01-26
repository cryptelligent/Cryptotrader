By DISTANT
see also: discussion at https://cryptotrader.org/topics/405158/developer-university-lesson-2-your-first-order-data-instruments-and-trading-part-1
trading = require "trading"

class Utilities
    @Print: (name, object) ->
        try
            debug "-------------------------------------------------------------------"
            for k, v of object
                message = "#{name}.#{k} = #{v}"
                if (message.length < 175)
                    debug message
                else
                    i = 0
                    loop
                        output = message.substr(i, 175)
                        if (output.length == 175)
                            i += 175
                            debug output
                        else
                            debug output
                            break
        catch ex
            debug "#{ex}"

handle: ->
    #@Utilities.Print("data", data)
    @Utilities.Print("data.eth_btc", data.eth_btc)
    #@Utilities.Print("data.instruments[0]", data.instruments[0])
    #loopCount = 0
    #loop
        #sleep 5000
        #data.instruments[0].update data
        #loopCount += 1
        #break if loopCount >= 10
