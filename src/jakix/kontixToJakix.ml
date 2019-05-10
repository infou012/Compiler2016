(** This module implements a compiler from Kontix to Jakix. *)

(**
    This is similar to the FopixToJavix compiler, except that
    the source program is known to be in CPS form, and in particular
    contains only tail-recursive calls. It could hence be compiled
    in a more optimized way. *)

let error pos msg =
  Error.error "compilation" pos msg

(** As in any module that implements {!Compilers.Compiler}, the source
    language and the target language must be specified. *)
module Source = Kontix
module Target = Jakix

module S = Source.AST
module T = Target.AST

(** We will need the following pieces of information to be carrying
    along the translation: *)
type environment = {
  nextvar          : int;
  variables        : (S.identifier * T.var) list;
  function_labels  : (S.function_identifier * T.label) list;
  (** [function_formals] maintains the relation between function identifiers
      and their formal arguments. *)
  function_formals : (S.function_identifier * S.formals) list;
}

(** Initially, the environment is empty. *)
let initial_environment () = {
  nextvar          = 0;
  variables        = [];
  function_labels  = [];
  function_formals = [];
}

(** [lookup_function_label f env] returns the label of [f] in [env]. *)
let lookup_function_label f env =
  List.assoc f env.function_labels

(** [lookup_function_formals f env] returns the formal arguments of
    [f] in [env]. *)
let lookup_function_formals f env =
  List.assoc f env.function_formals

(** [fresh_function_label f] returns a fresh label starting with [f]
    that will be used for the function body instructions. *)
let fresh_function_label =
  let r = ref 0 in
  fun f ->
    incr r;
    T.Label (f ^ "_body_" ^ string_of_int !r)

(** Variables *)

(** [bind_variable env x] associates Kontix variable x to the next
    available Jakix variable, and return this variable and the updated
    environment *)
let bind_variable env x =
  let v = T.Var env.nextvar in
  v,
  { env with
    nextvar = env.nextvar + 1;
    variables = (x,v) :: env.variables }

let clear_all_variables env = {env with variables = []; nextvar = 0}

(** For higher-order functions,
    we encode some labels as numbers. These numbers could then
    be placed in the stack, and will be used in a final tableswitch *)

module Labels :
 sig
   val encode : T.label -> int
   val all_encodings : unit -> (int * T.label) list
 end
=
 struct
   let nextcode = ref 0
   let allcodes = ref ([]:(int * T.label) list)
   let encode lab =
     let n = !nextcode in
     incr nextcode;
     allcodes := (n,lab) :: !allcodes;
     n
   let all_encodings () = !allcodes
 end

let basic_program code =
  { T.classname = "Kontix";
    T.code = code;
    T.varsize = 100;
    T.stacksize = 10000; }

(** [translate p env] turns a Kontix program [p] into a Jakix program
    using [env] to retrieve contextual information. *)
let rec translate p env : T.t * environment =
  failwith "Student! This is your job!"

(** Remarks:
  - When using this compiler from kontix to jakix, flap will
    produce some .k files (with the same syntax as .j files).
    + Compile them to .class via: jasmin Foobar.k
    + Run them with: java -noverify Foobar

  - Final answer:
    The initial continuation function (named _return_) should
    be compiled with a final [Ireturn]. The starting point is
    the code of the unique DefineValue in the program (supposed
    to be an Integer).
*)
