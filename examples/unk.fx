val x = ?(if 1 > 2 then &f else &h end) (5)
def f(x) =  if x = 0 then 1 else x * f(x-1) end
def g(x) = x + 3
def h(x) = if 1 = 1 then ?(if 1 < 2 then &f else &g end) (5) else 0 end 