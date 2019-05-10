
# Exercices pour Compilation Avancée (Master 2016)

## Passage non-trivial en récursif terminal

Ceci est une reprise d'un exercice de Programmation Fonctionnelle Avancée.
Le code suivant transforme un arbre en liste:

```
  type 'a tree =
  | Node of 'a tree * 'a tree
  | Leaf of 'a;;

  let rec tolist t = match t with
  | Leaf v -> [v]
  | Node (a, b) -> tolist a @ tolist b;;

  let exemple = List.hd (tolist (Node (Leaf 1, Node (Leaf 2, Leaf 3))));;
```

1. Peut-on réécrire simplement la fonction `tolist` en récursif terminal ?
2. Utiliser l'algorithme de mise en CPS vu en cours, tout d'abord en OCaml.
3. Au fait, comment peut-on représenter ces arbres et listes en Fopix ?
   Que devient le `match` ci-dessus ? Et le `@` ?
4. Donner le code Kontix puis Jakix obtenu.


## Exceptions simples

Ecrire une fonction qui reçoit un tableau d'entiers `t` et sa longueur `n`,
et retourne la multiplication des entiers dans le tableau, en un seul passage
et en évitant de faire la moindre multiplication si 0 est dans le tableau.
Donner d'abord une version par exception, puis une version CPS.

## Exceptions multiples

Comment compiler le code suivant:

```
exception Skip
exception Stop

let f = function 0 -> raise Stop | 13 -> raise Skip | x -> 2*x

let rec loop t n i =
  if i >= n then ()
  else try
          t.(i) <- f (t.(i));
          loop t n (i+1)
       with Skip -> loop t n (i+2)

let res =
 let t = [|1;13;0;4;0|] in
 try loop t 5 0; t.(4) with Stop -> 22
```


## Trampoline

Prendre une fonction récursive terminale, par exemple `List.rev_map` et en
écrire une version par trampoline, afin que le coeur de la récursion devienne
une boucle while. Ecrire le code obtenu en OCaml puis C.
