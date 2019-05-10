type 'a tree =
  | Node of 'a tree * 'a tree
  | Leaf of 'a;;

let rec tolist t = match t with
  | Leaf v -> [v]
  | Node (a, b) -> tolist a @ tolist b;;

let exemple = List.hd (tolist (Node (Leaf 1, Node (Leaf 2, Leaf 3))));;
(*
let to_list_tr t =
  let rec aux acc t = match t with
    |Leaf v -> v::acc
    |Node (a, b) -> aux acc a @ aux acc b  
  in
  aux [] t
 *)

let rec to_list acc t =
  match t with
  |Leaf v -> v::acc
  |Node (a, b) -> let acc' = to_list acc b in
		  to_list acc' a

let concat l l' = List.rev_append (List.rev l) l'

let rec concat l l' k =
  match l with
  |[] -> k l'
  |h::t -> concat l l' (fun r ->
			k (h::r))
				  
let rec to_list t k =
  match t with
  |Leaf x -> k [x]
  |Node (a, b) ->
    to_list a (fun lg ->
	       to_list b (fun ld ->
			  k (concat_tail_rec lg ld)))
let exemple = List.hd (tolist (Node (Leaf 1, Node (Leaf 2, Leaf 3))));;

exception Zero
	    
let rec multiply t n =
  
    
    
  
 
       
