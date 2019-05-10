
/* SOURCE OCAML:
  type 'a tree =
  | Node of 'a tree * 'a tree
  | Leaf of 'a;;

  let rec tolist t = match t with
  | Leaf v -> [v]
  | Node (a, b) -> tolist a @ tolist b;;

  let exemple = List.hd (tolist (Node (Leaf 1, Node (Leaf 2, Leaf 3))));;
*/

def nil () =
  val bk = block_create (1,0) in
  block_set (bk,0,0); /* tag */
  bk end

def cons (x,l) =
  val bk = block_create (3,0) in
  block_set (bk,0,1); /* tag */
  block_set (bk,1,x);
  block_set (bk,2,l);
  bk end

def leaf (a) =
  val bk = block_create (2,0) in
  block_set (bk,0,0); /* tag */
  block_set (bk,1,a);
  bk end

def node (g,d) =
  val bk = block_create (3,0) in
  block_set (bk,0,1); /* tag */
  block_set (bk,1,g);
  block_set (bk,2,d);
  bk end

def concat (l1,l2) =
  if block_get (l1,0) = 0 then l2
  else cons (block_get (l1,1), concat (block_get (l1,2),l2)) end

def tolist (t) =
  if block_get (t,0) = 0 then cons(block_get(t,1),nil())
  else concat (tolist (block_get(t,1)), tolist (block_get(t,2))) end

val ex = block_get (tolist (node (leaf (7), node (leaf (5), leaf (9)))), 1)
/* answer: 7 */