def fact(x) = if x = 0 then 1 else x * fact(x-1) end
val res = fact(10)
/* answer: 2 */
