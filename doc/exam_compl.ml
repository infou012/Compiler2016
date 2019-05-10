type 'a tree =
  | Leaf of 'a
  | Node of 'a tree * 'a tree;;

(* Question 1 *)
let rec toListTail t =
  let rec aux acc = function
    | Leaf v -> v::acc
    | Node (g, d) -> let acc` = toListTail acc g (* pas tail rec puisse qu'on doit faire des calculs après ... *)
                     in
                     toListTail acc` d (* tail rec *)
  in aux [] t ;;

  (* c'est possible de le transformer en 100% tail rec <-> Question 2 *)

  (* Question 2 *)

let rec concatTail l l` = List.(rev_append (rev l) l`)

let rec makeList n acc =
  if n==0 then acc
  else makeList (n-1) (1::acc) ;;

  let big = makeList 500000 [];;
  let _ = List.rev big ;;

  let _ = List.map succ big ;;
    
  let rec rev = function
    | [] -> []
    | x::l -> (rev l) @ [x] ;;
let _ = rev big ;;
    
let rec toList_cps1 t k =
  match t with
    | Leaf v -> k [v]
    | Node (g,d) ->  toList_cps1 g (fun lg ->
                                  toList_cps1 d (fun ld ->
                                               k (lg@ld)))

let rec concatTail l l' k =
  match l with
  | [] -> k l'
  | x::t -> concatTail t l' (fun r ->
                     k (x::r)) 
                         
let rec toList_cps2 t k =
  match t with
    | Leaf v -> k [v]
    | Node (g,d) ->  toList_cps2 g (fun lg ->
                                  toList_cps2 d (fun ld ->
                                              concatTail lg ld k));;


  (* Question 3 Fopix *)

  (**
     on remplace les arbres par les blocks:
      par exemple:
             Leaf v : on aura deux blocks, un pour le tag et un autre pour la valeur v
             Node (g, d) : on aura  trois blocks, un pour le tag, un pour g et un dernier pour d
   *)


  (* Question 4 Kontix et Javix *)


  (**
 
pseudo code caml pour faire simplement kontix:
      t(b) <=> (en kontix) block_get 
      (x, y, z) <=> b = block_create 3 in ... 
      (x::r) <=> (1, x, r)


let rec tolist t e k =
     if t(0) = 0 then 
       k e (cons t(1)::nil)
     else tolist t(1) (t(2), e , k) aux1

and aux1 lg (d, e, k) = 
    tolist d (lg, e, k) aux2

and aux2 ld (lg, e, k)  = 
    concat lg ld e k 

and concat l1 l2 e k =
    if l1(0) = 0 then k e l2
    else concat l1(2) l2 (l1(1), e, k) aux3

and aux3 r (x, e, k) =
    k e (x::r) 

   *)

  (**
    Jakix

tolist:
   if:   ...
   then: ...
         Aload 2
         Unbox
         Goto dispatch
   else: ...
         Iconst k1 (code de const dans tolist)  
         Box
         Astore
         Goto tolist

aux1: ...
      iconst aux2 2 (son code)
      Box
      Astore 2
      Goto tolist

   *)


  (* Exceptions simples *)

exception Zero
  
let mul_tab tab n =
  let rec loop i =
    if (i=0) then 1
    else
      if tab.(i) = 0 then raise Zero
      else loop (i-1) * tab.(i)
  in
  loop n
