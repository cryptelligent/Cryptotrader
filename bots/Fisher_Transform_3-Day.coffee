###
3-Day Fisher Transform
Copyright (C) 2018 DiSTANT (for CryptoTrader.org)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

trading = require 'trading'
talib = require 'talib'

init: (context) ->

    setPlotOptions
        bears:
            color: 'rgba(255,0,0,0.1)'
            secondary: true
            size: 5
        bulls:
            color: 'rgba(0,255,0,0.1)'
            secondary: true
            size: 5

handle: (context, data) ->
    storage.lastValue ?= null
    storage.lastFisher ?= null
    i = data.instruments[0]
    longPeriod = parseInt((24*60)/i.interval) * 3

    median = talib.MEDPRICE
        high: i.high
        low: i.low
        startIdx: i.high.length - 1 - longPeriod
        endIdx: i.high.length - 1

    high = talib.MAX
        inReal: median
        startIdx: 0
        endIdx: median.length - 1
        optInTimePeriod: longPeriod


    low = talib.MIN
        inReal: median
        startIdx: 0
        endIdx: median.length - 1
        optInTimePeriod: longPeriod
    
    high = _.last(high)
    low = _.last(low)
    median = _.last(median)

    value = (median - low) / (high - low)
    
    value = .33 * 2 * (value - .5)
    if (storage.lastValue != null)
        value += (.67 * storage.lastValue)

    if (value > .9999)
        value = .9999
    else if (value < -.9999)
        value = -.9999

    storage.lastValue = value
    
    value = (1 + value) / (1 - value)

    fisher = (.25 * Math.log(value))

    if (storage.lastFisher != null)
        fisher +=  (.5 * storage.lastFisher)

        if (fisher > storage.lastFisher)
            plotMark
                bulls: 1
            try
                trading.buy i
        else if (fisher < storage.lastFisher)
            try
                trading.sell i
            plotMark
                bears: -1

    storage.lastFisher = fisher
