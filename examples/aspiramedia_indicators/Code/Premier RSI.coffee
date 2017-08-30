###
Premier RSI
by aspiramedia (by LazyBear: https://www.tradingview.com/script/nExsfauf-Premier-RSI-Oscillator-LazyBear/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

###
//
// @author LazyBear 
// 
// List of my public indicators: http://bit.ly/1LQaPK8 
// List of my app-store indicators: http://blog.tradingview.com/?p=970 
//
study("Premier RSI Oscillator [LazyBear]", shorttitle="PRO_LB")
src=input(close, title="Source")
lrsi=input(14, title="RSI Length")
stochlen = input(8, title="Stoch length")
smoothlen = input(25, title="Smooth length")
r=rsi(src, lrsi)
sk=stoch(r, r, r, stochlen)
len = round(sqrt( smoothlen ))
nsk = 0.1 * ( sk - 50 )
ss = ema( ema( nsk, len ), len )
expss = exp( ss )
pro = ( expss - 1 )/( expss + 1 )
plot( pro, title="Premier RSI Stoch", color=black, linewidth=2 )
plot( pro, color=iff( pro < 0, red, green ), style=histogram , title="PROHisto")
plot(0, color=gray, title="ZeroLine")
plot( 0.2, color=gray, style=3 , title="Level2+")
plot( 0.9, color=gray, title="Level9+")
plot( -0.2, color=gray, style=3, title="Level2-")
plot( -0.9, color=gray, title="Level9-")
ebc=input(false, title="Enable bar colors")
bc=ebc?(pro<0? (pro<pro[1]?red:orange) : (pro>pro[1]?lime:green)) : na
barcolor(bc)
###

class RSI
    constructor: () ->

        @count = 0
        @output = []

        # INITIALIZE ARRAYS
        for [@output.length..5]
            @output.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        high = instrument.high[instrument.high.length-1]
        low = instrument.low[instrument.low.length-1]

        # REMOVE OLD DATA
        @output.pop()

        # ADD NEW DATA
        @output.unshift(0)

        # CALCULATE
        @output[0] = close
        
        
        
        # TEMP DEBUG
        plot
            output: @output[0]

        

        # RETURN DATA
        result =
            output: @output[0]

        return result 
      

init: (context)->
    
    context.rsi = new RSI()

    # FOR FINALISE STATS
    context.balance_curr = 0
    context.balance_btc = 0
    context.price = 0


handle: (context, data)->

    instrument = data.instruments[0]
    price = instrument.close[instrument.close.length - 1]

    # FOR FINALISE STATS
    context.price = instrument.close[instrument.close.length - 1]
    context.balance_curr = portfolio.positions[instrument.curr()].amount
    context.balance_btc = portfolio.positions[instrument.asset()].amount

    # CALLING INDICATORS
    rsi = context.rsi.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc