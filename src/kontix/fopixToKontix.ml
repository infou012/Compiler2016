(** This module implements a compiler from Fopix to Kontix. *)

(** As in any module that implements {!Compilers.Compiler}, the source
    language and the target language must be specified. *)
module Source = Fopix
module S = Source.AST
module Target = Kontix
module T = Target.AST

type environment = {
  variables : (S.identifier * S.literal) list;
}

let initial_environment () = {
  variables = [];
}


let fresh_function_id =
  let r = ref 0 in
  incr r;
  fun s -> T.FunId (s ^ "_cont_" ^ string_of_int !r)
					
let lookup_variable v env =
  List.assoc v env.variables

(** The following translation should convert the Fopix program p
    into an equivalent program with only tail-recursive calls, by
    using a cps (continuation-passing-style) conversion.

    Note that the ASTs of Fopix and Kontix are the same, it's your
    responsability to be sure that non-tail-calls have disappeared.

    The produced Kontix program should contain the following function:
    def _return_(e,r) = r
    and use it as initial continuation.

    If there are many DefineValue in the program, you might regroup
    them into one, or simply reject these cases in a first time.
*)

let translate (p : S.t) env = failwith "TODO"
  (* 
   * let init = 
     let rec cps p env k = match p with
     in
  let p, env = cps p env init
  in p, env *)
