###
Absolute Strength Indicator Oscillator
by aspiramedia (from Lazybear: https://www.tradingview.com/script/E6xccTf1-Absolute-Strength-Index-Oscillator-LazyBear/)
1GGZU5mAUSLxVDegdxjakTLqZy7zizRH74
###

###
//
// @author LazyBear 
// 
// List of my public indicators: http://bit.ly/1LQaPK8 
// List of my app-store indicators: http://blog.tradingview.com/?p=970 
//
study("Absolute Strength Index Oscillator [LazyBear]", shorttitle="ABSSIO_LB")
sh=input(false, title="Show as Histo")
ebc=input(false, title="Enable Bar Colors")
lma=input(21, title="EMA Length")
ld=input(34, title="Signal Length")
osl=10 
calc_abssio( ) =>
    A=iff(close>close[1], nz(A[1])+(close/close[1])-1,nz(A[1]))
    M=iff(close==close[1], nz(M[1])+1.0/osl,nz(M[1]))
    D=iff(close<close[1], nz(D[1])+(close[1]/close)-1,nz(D[1]))
    iff (D+M/2==0, 1, 1-1/(1+(A+M/2)/(D+M/2)))

abssi=calc_abssio()
abssio = (abssi - ema(abssi,lma))
alp=2.0/(ld+1)
mt=alp*abssio+(1-alp)*nz(mt[1])
ut=alp*mt+(1-alp)*nz(ut[1])
s=((2-alp)*mt-ut)/(1-alp)
d=abssio-s
hline(0, title="ZeroLine")
plot(not sh ? abssio : na, color=(abssio > 0 ? abssio >= s ? green : orange : abssio <=s ? red :orange), title="ABSSIO", style=histogram, linewidth=2)
plot(not sh ? abssio : na, color=black, style=line,title="ABSSIO_Points", linewidth=2)
plot(not sh ? s : na, color=gray, title="MA")
plot(sh ? d : na, style=columns, color=d>0?green:red)
barcolor(ebc?(abssio > 0 ? abssio >= s ? lime : orange : abssio <=s ? red :orange):na)
###

class ASIO
    constructor: () ->

        @count = 0
        @A = []
        @M = []
        @D = []
        @abssi = []
        @mt = []
        @ut = []

        # INITIALIZE ARRAYS
        for [@A.length..5]
            @A.push 0
        for [@M.length..5]
            @M.push 0
        for [@D.length..5]
            @D.push 0
        for [@mt.length..5]
            @mt.push 0
        for [@ut.length..5]
            @ut.push 0
        
    calculate: (instrument) ->        

        close = instrument.close[instrument.close.length-1]
        closeprev = instrument.close[instrument.close.length-2]
        lma = 21
        ld = 34
        osl = 10 

        # REMOVE OLD DATA
        @A.pop()
        @M.pop()
        @D.pop()
        @mt.pop()
        @ut.pop()

        # ADD NEW DATA
        @A.unshift(0)
        @M.unshift(0)
        @D.unshift(0)
        @mt.unshift(0)
        @ut.unshift(0)

        # CALCULATE
        if close > closeprev
            @A[0] = @A[1] + (close / closeprev) - 1
        else
            @A[0] = @A[1]

        if close == closeprev
            @M[0] = @M[1] + 1 / osl
        else
            @M[0] = @M[1]

        if close < closeprev
            @D[0] = @D[1] + (closeprev / close) - 1
        else
            @D[0] = @D[1]
  
 

        if @D[0] + @M[0] / 2 == 0
            abssi = 1
        else
            abssi = 1 - 1 / (1 + (@A[0] + @M[0] / 2) / (@D[0] + @M[0] / 2))

        for [@abssi.length..lma]
            @abssi.push abssi
        if @abssi.length > lma
            @abssi.shift()

        abssioema = talib.EMA
            inReal: @abssi
            startIdx: 0
            endIdx: @abssi.length-1
            optInTimePeriod: lma
        abssioema = abssioema[abssioema.length-1]

        abssio = abssi - abssioema

        alp = 2 / (ld + 1)

        @mt[0] = alp * abssio + (1 - alp) * @mt[1]
        @ut[0] = alp * @mt[0] + (1 - alp) * @ut[1]

        s = ((2 - alp) * @mt[0] - @ut[0]) / (1 - alp)
        
        d = abssio - s



        
        # TEMP DEBUG
        plot
            d: abssi
        setPlotOptions
            d:
                secondary: true
            

        

        # RETURN DATA

      

init: (context)->
    
    context.asio = new ASIO()

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
    asio = context.asio.calculate(instrument)
    
    # TRADING

    
    # PLOTTING / DEBUG
    plot



    
finalize: (contex, data)-> 

    # DISPLAY FINALISE STATS
    if context.balance_curr > 10
        info "Final BTC Equiv: " + context.balance_curr/context.price
    if context.balance_btc > 0.05
        info "Final BTC Value: " + context.balance_btc