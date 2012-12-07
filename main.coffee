console.log("main.coffee entry point")

g = canvas.getContext("2d")

fib = (n) ->
        if n <= 1
          n
        else
          fib(n-1) + fib(n-2)

x = [0..20]
y = x.map fib

#g.moveTo(10, 10)
g.lineTo(x[i], y[i]) for i in [0..20]
g.stroke()