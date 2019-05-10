def f(n, acc) = if n = 0 then acc else f((n-1), acc*n) end
val x = f(3, 1)
