/* fact in Kontix (after translation to continuation-passing-style) */
def fact(x,k,e) = if x = 0 then ?(k)(e,1) else
 fact(x-1,&aux,
  val bk = block_create(3,0) in
  block_set(bk,0,x);
  block_set(bk,1,k);
  block_set(bk,2,e);
  bk end) end
def aux(bk,r) =
 val n = block_get(bk,0) in
 val k = block_get(bk,1) in
 val e = block_get(bk,2) in
 ?(k)(e,r*n) end end end
def init(e,r) = r
val res = fact(10,&init,block_create(0,0))
/* answer: 3628800 */