###
Configurable Fisher Transform with MACD and RSI confirmation
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
params = require 'params'

NUMBER_OF_DAYS = params.add "Number of days used for calculations", 3
CONSECUTIVE_BUY_SIGNALS = params.add "Consecutive buy signals required", 1
CONSECUTIVE_SELL_SIGNALS = params.add "Consecutive sell signals required", 1
PCT_OF_FUNDS = params.add "Percent of funds to use for orders", 100
PCT_OF_SPLIT = params.add "Percent iceberg split", 25
MINIMUM_ORDER_VALUE = params.add "Minimum order value (exchange threshold)", .001

init: (context) ->

    info "Thanks for using the #{NUMBER_OF_DAYS}-Day Fisher Transform Bot By DiSTANT"
    info "Please be patient while the bot waits for a signal"

    setPlotOptions
        bought:
            color: 'rgba(46, 204, 113, .25)'
        sold:
            color: 'rgba(231, 76, 60, .25)'
        bears:
            color: 'rgba(192, 57, 43, .25)'
            secondary: true
            size: 5
        bulls:
            color: 'rgba(39, 174, 96, .25)'
            secondary: true
            size: 5

handle: (context, data) ->
    storage.consecutiveSellSignals ?= 0
    storage.consecutiveBuySignals ?= 0
    storage.wins ?= 0
    storage.losses ?= 0
    storage.sells ?= 0
    storage.sold ?= false
    storage.lastSellPrice ?= null
    storage.buys ?= 0
    storage.bought ?= false
    storage.lastBuyPrice ?= null
    storage.lastValue ?= null
    storage.lastFisher ?= null
    i = data.instruments[0]
    startCurrency = @portfolio.positions[i.curr()].amount
    startAssets = @portfolio.positions[i.asset()].amount
    longPeriod = Math.min(parseInt((24*60)/i.interval) * NUMBER_OF_DAYS, i.size - 1)
    shortPeriod = parseInt(longPeriod/3)

    currentPrice = _.last(i.close)
    currentWorth = startCurrency + startAssets * currentPrice

    storage.initialWorth ?= currentWorth
    storage.initialPrice ?= currentPrice

    rsi = talib.RSI
        inReal: i.close
        startIdx: 0
        endIdx: i.close.length - 1
        optInTimePeriod: longPeriod

    macd = talib.MACD
        inReal: i.close
        startIdx: 0
        endIdx: i.close.length - 1
        optInFastPeriod: shortPeriod
        optInSlowPeriod: longPeriod
        optInSignalPeriod: shortPeriod

    m = macd.outMACD
    s = macd.outMACDSignal
    h = macd.outMACDHist

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
            storage.consecutiveSellSignals = 0
            storage.consecutiveBuySignals += 1
            plotMark
                bulls: 1

            minimumCurrency = i.price * MINIMUM_ORDER_VALUE
            if (!storage.bought and storage.consecutiveBuySignals >= CONSECUTIVE_BUY_SIGNALS and _.last(s) > s[s.length - 2] and _.last(rsi) > rsi[rsi.length - 2])
                currentCurrency = startCurrency
                currentAssets = startAssets

                totalCurrencyToSpend = startCurrency * (PCT_OF_FUNDS/100)
                split = (totalCurrencyToSpend * (PCT_OF_SPLIT/100))

                if (split < minimumCurrency)
                    split = totalCurrencyToSpend

                amountRemaining = totalCurrencyToSpend
                infLoop = 0
                while (infLoop++ < 100 and amountRemaining >= minimumCurrency)
                    startingCurrency = @portfolio.positions[i.curr()].amount
                    startingAssets = @portfolio.positions[i.asset()].amount

                    ticker = trading.getTicker(i)
                    buyAmount = Math.min((split/ticker.buy)*.9975, amountRemaining/ticker.buy)
                    try
                        trading.buy i, 'market', buyAmount
                    catch error
                        if (/insufficient funds/i.exec(error))
                            currentCurrency = startingCurrency
                            currentAssets = startingAssets
                            break

                    sleep(30000)
                    i.update
                    currentCurrency = @portfolio.positions[i.curr()].amount
                    currentAssets = @portfolio.positions[i.asset()].amount
                    currencyDelta = (startingCurrency - currentCurrency)
                    if (currencyDelta != 0)
                        assetDelta = (currentAssets - startingAssets)
                        salePrice = (currencyDelta/assetDelta)
                        info "Bought #{assetDelta.toFixed(8)} #{i._pair[0].toUpperCase()} at #{salePrice.toFixed(8)} #{i._pair[1].toUpperCase()}"
                    amountRemaining -= currencyDelta

                totalBought = (currentAssets - startAssets)
                currencySpent = (startCurrency - currentCurrency)
                salePrice = currencySpent/totalBought
                info "Bought a total of #{totalBought.toFixed(8)} #{i._pair[0].toUpperCase()} at #{salePrice.toFixed(8)} #{i._pair[1].toUpperCase()}"
                info "Finished Buying!"
                storage.sold = false
                storage.bought = true
                storage.consecutiveBuySignals = 0
                storage.consecutiveSellSignals = 0
                storage.lastBuyPrice = salePrice
                storage.buys++

                plotMark
                    bought: salePrice
        else if (fisher < storage.lastFisher)
            storage.consecutiveSellSignals += 1
            storage.consecutiveBuySignals = 0
            plotMark
                bears: -1

            if (!storage.sold and storage.consecutiveSellSignals >= CONSECUTIVE_SELL_SIGNALS and _.last(s) < s[s.length - 2] and _.last(rsi) < rsi[rsi.length - 2])
                currentCurrency = startCurrency
                currentAssets = startAssets

                totalAssetsToSell = startAssets * (PCT_OF_FUNDS/100)
                split = (totalAssetsToSell * (PCT_OF_SPLIT/100))

                if (split < MINIMUM_ORDER_VALUE)
                    split = totalAssetsToSell

                amountRemaining = totalAssetsToSell
                infLoop = 0
                while (infLoop++ < 100 and amountRemaining >= MINIMUM_ORDER_VALUE)
                    startingCurrency = @portfolio.positions[i.curr()].amount
                    startingAssets = @portfolio.positions[i.asset()].amount

                    ticker = trading.getTicker(i)
                    sellAmount = Math.min(split*.9975, amountRemaining)
                    try
                        trading.sell i, 'market', sellAmount
                    catch error
                        if (/insufficient funds/i.exec(error))
                            currentCurrency = startingCurrency
                            currentAssets = startingAssets
                            break

                    sleep(30000)
                    i.update
                    currentCurrency = @portfolio.positions[i.curr()].amount
                    currentAssets = @portfolio.positions[i.asset()].amount
                    assetDelta = (startingAssets - currentAssets)
                    if (assetDelta != 0)
                        currencyDelta = (currentCurrency - startingCurrency)
                        salePrice = (currencyDelta/assetDelta)
                        warn "Sold #{assetDelta.toFixed(8)} #{i._pair[0].toUpperCase()} at #{salePrice.toFixed(8)} #{i._pair[1].toUpperCase()}"
                    amountRemaining -= assetDelta

                totalSold = (startAssets - currentAssets)
                currencyGain = (currentCurrency - startCurrency)
                salePrice = currencyGain/totalSold
                warn "Sold a total of #{totalSold.toFixed(8)} #{i._pair[0].toUpperCase()} at #{salePrice.toFixed(8)} #{i._pair[1].toUpperCase()}"
                warn "Finished Selling!"
                storage.sold = true
                storage.bought = false
                storage.consecutiveBuySignals = 0
                storage.consecutiveSellSignals = 0
                storage.lastSellPrice = salePrice
                storage.sells++
                if (storage.lastBuyPrice != null)
                    if (salePrice > storage.lastBuyPrice)
                        storage.wins++
                    else
                        storage.losses++
                plotMark
                    sold: salePrice
        else
            storage.consecutiveBuySignals = 0
            storage.consecutiveSellSignals = 0

    storage.lastFisher = fisher

    botPL = ((currentWorth - storage.initialWorth)/storage.initialWorth) * 100
    marketPL = ((currentPrice - storage.initialPrice)/storage.initialPrice) * 100

    info "---------- #{NUMBER_OF_DAYS}-Day Fisher Transform By DiSTANT ----------"
    info "Current Price: #{currentPrice.toFixed(8)} #{i._pair[1].toUpperCase()}"
    info "Exchange Wallet: #{startCurrency.toFixed(8)} #{i._pair[1].toUpperCase()} and #{startAssets.toFixed(8)} #{i._pair[0].toUpperCase()}"
    info "Start Worth: #{storage.initialWorth.toFixed(8)} #{i._pair[1].toUpperCase()} or #{(storage.initialWorth/storage.initialPrice).toFixed(8)} #{i._pair[0].toUpperCase()}"
    info "Current Worth: #{currentWorth.toFixed(8)} #{i._pair[1].toUpperCase()} or #{(currentWorth/currentPrice).toFixed(8)} #{i._pair[0].toUpperCase()}"
    if (botPL >= 0)
        info "Bot P/L: #{botPL.toFixed(2)}%"
    else
        warn "Bot P/L: #{botPL.toFixed(2)}%"

    if (marketPL >= 0)
        info "Buy&Hold P/L: #{marketPL.toFixed(2)}%"
    else
        warn "Buy&Hold P/L: #{marketPL.toFixed(2)}%"

    if (storage.sold)
        info "Currently Sold"
    if (storage.bought)
        info "Currently Bought"

    info "Buys: #{storage.buys} Sells: #{storage.sells} Total Orders: #{storage.buys + storage.sells}"
    info "Wins: #{storage.wins} Losses: #{storage.losses} Total Trades: #{storage.wins + storage.losses}"
    info " "
