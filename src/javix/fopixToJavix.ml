(** This module implements a compiler from Fopix to Javix. *)
  
(** Remarks:
  - When using this compiler from fopix to javix, flap will
    produce some .j files.
    + Compile them to .class via: jasmin Foobar.j
    + Run them with: java -noverify Foobar

  - Feel free to reuse here any useful code from fopixToStackix

  - Final answer:
    your code should contain a final [Ireturn] that should
    return the value of the last DefineValue (supposed to be
    an Integer).

  - Function Call Convention:
    + The n arguments should be in jvm's variables 0,1,...(n-1).
    + At least the variables that are reused after this call
      should have their contents saved in stack before the call
      and restored afterwards.
    + Just before the function call, the return address should
      be placed on the stack (via the encoding as number of this
      return label, see Labels.encode).
    + When the function returns, the result should be on the top
      of the stack.

  - Boxing:
    The stack could contain both unboxed elements (Java int)
    or boxed elements (Java objects such as Integer or java arrays).
    We place into variables or in array cells only boxed values.
    The arithmetical operations (iadd, if_icmpeq, ...) only works
    on unboxed numbers.
    Conversion between int and Integer is possible via the
    Box and Unboxed pseudo-instructions (translated into correct
    calls to some ad-hoc methods we provide). You may try to
    do some obvious optimisations such as removing [Box;Unbox] or
    [Unbox;Box].

  - Tail-recursive calls : if the body of f ends with a call to
    another function g (which may be f itself in case of recursion),
    no need to save any variables, nor to push a new return address:
    just reuse the return address of the current call to f when
    jumping to g !

  - Variable size and stack size
    Your code should determine the number of variables used by the
    produced code. You might also try to compute the maximum
    stack size when the code is non-recursive or 100% tail-recursive.

*)

let error pos msg =
  Error.error "compilation" pos msg

(** As in any module that implements {!Compilers.Compiler}, the source
    language and the target language must be specified. *)
module Source = Fopix
module Target = Javix

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

(** [lookup_variable_label f env] returns the label of [f] in [env]. *)
let lookup_variable_label v env =
  List.assoc v env.variables
			       
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

(** [bind_variable env x] associates Fopix variable x to the next
    available Javix variable, and return this variable and the updated
    environment *)
let bind_variable env x =
  let v = T.Var env.nextvar in
  v,
  { env with
    nextvar = env.nextvar + 1;
    variables = (x,v) :: env.variables }
    
and bind_formals env f xs =
  { env with function_formals = (f, xs)::env.function_formals }

and bind_labels env f ls =
  { env with function_labels = (f,ls)::env.function_labels}

let clear_all_variables env = {env with variables = []; nextvar = 0}

(** For return addresses (or later higher-order functions),
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


   (** The code of a declaration can be located...*)
type declaration_location =
  (** ... either before exit (because it must be executed). *)
  | BeforeExit of T.label
  (** ... or after exit (because it is executed only on demand). *)
  | AfterExit of T.label

let basic_program code =
  { T.classname = "Fopix";
    T.code = code;
    T.varsize = 100;
    T.stacksize = 10000; }

let get_function_name fid_loc =
  let fid = Position.value fid_loc in
  match fid with
  |S.FunId id -> id
		  
(** [translate p env] turns a Fopix program [p] into a Javix program
    using [env] to retrieve contextual information. *)
    
let rec translate p env : T.t * environment =

  (** First, get the functions labels and formals parameters within
 the program and store them in our environment *)
  let bind_labels_formals env p =
    let get_flabels env dcl  = match dcl with
      |S.DefineValue _ -> env
      |S.DefineFunction (fid_loc, xs, _) ->
	let fid = get_function_name fid_loc in
	let env = bind_labels env (Position.value fid_loc)
			      (fresh_function_label fid) in
	bind_formals env (Position.value fid_loc) xs in
    List.fold_left get_flabels env p in
  
  (** A Fopix program is a list of declaration, so we iterate over
    that list, evaluate the definition within while continuousily updating 
    our environment *)

  let rec iter env after_exit = function
    (** When the iteration is finished, we get the result of the last
     DefineValue, unbox it end then call Ireturn to finish *)
    |[] ->
      let lablist = List.rev_append
		      (List.map snd (Labels.all_encodings ())) [] in
	let labdefault, fail_block =
	  labelled_block "_ts_fail_" (
			   single_instruction (T.Bipush 10001)
			   @ single_instruction (T.Ireturn))
	in
	let table_switch =
	  labelled_instruction
	    "dispatch"
	    (T.Tableswitch (0, lablist, labdefault))
	in
      single_instruction (T.Aload (T.Var (env.nextvar - 1)))
      @ single_instruction (T.Unbox)
      @ single_instruction (T.Ireturn)
      @ after_exit
      @ table_switch
      @ fail_block, env

    |d::ds ->
      let env, location, block = declaration env d in
      match location with
      |BeforeExit _ -> let blocks, env = iter env after_exit ds in
		       block @ blocks, env
      |AfterExit _ -> iter env (block @ after_exit) ds
  in
  let env = bind_labels_formals env p in
  let code, env = iter env [] p
  in
  basic_program code, env
			
and declaration env = function
  |S.DefineValue (x, e) ->
    let (S.Id i) as x = Position.value x in
    (** The variable is inserted in the environment. *)
    let v, env' = bind_variable env x in
    (** 1. Insert the compiled code for the expression [e]. *)
    let instructions =
      expression' env e	false	  
    (** 2. Insert an instruction to ask the machine to define the
          variable [x]. *)
    @ single_instruction (T.Box)
    @ single_instruction (T.(Astore v))
    in
    (** 3. We insert a label at the beginning of the block. *)
    let l, block = labelled_block i instructions in
    (env', BeforeExit l, block)

  |S.DefineFunction (f, xs, e) ->
    let f_lab = lookup_function_label (Position.value f) env in 
    let f_env =
      List.fold_left (fun env x -> snd (bind_variable env x))
		     (clear_all_variables env) xs
    in
    let instructions =
      expression' f_env e true
      @ single_instruction (T.Swap)
      @ single_instruction (T.Goto (T.Label "dispatch")) in
    let f_block = label_block f_lab instructions in
    (env, AfterExit f_lab, f_block)
		    
	    
(** [expression pos env e] compiles [e] into a block of Stackix
    instructions that *does not* start with a label. *)
and expression pos env tail = function
  | S.Literal l ->
     let b =  match l with
       |S.LInt i -> single_instruction (T.Bipush i)
       |S.LFun fid ->
	 single_instruction
	   (T.Bipush (Labels.encode (lookup_function_label fid env)))
     in b

  | S.Variable (S.Id x as id) ->
     let xlab = lookup_variable_label id env
     in (single_instruction T.(Aload xlab)
	@ single_instruction T.Unbox)

  |S.Define (xid, e1, e2) ->
    let (S.Id i) as x = Position.value xid in
    let v, env' = bind_variable env x in
    expression' env e1 false
    @ single_instruction (T.Box)
    @ single_instruction (T.(Astore v))
    @ expression' env' e2 tail

  |S.IfThenElse (c, t, f) ->
    let tl, trueBlock =
      labelled_block "_if_true_" (expression' env t tail) in
    let el,endblock =
      labelled_block "_endif_"
		     (single_instruction (T.Comment "endif")) in
    let opds, op = eval_condition env c false in
    opds
    @ single_instruction (T.If_icmp (op, tl))
    @ (expression' env f tail)
    @ single_instruction (T.Goto el)
    @ trueBlock
    @ endblock

  |S.FunCall (S.FunId fid, [e1;e2]) when is_binop fid ->
    let op = binop fid in
    expression' env e1 false
    @ expression' env e2 false
    @ single_instruction (T.Binop op)

  |S.FunCall (S.FunId "block_create", [size; init]) ->
    expression' env init false
    @ expression' env size false
    @ single_instruction (T.Anewarray)
    
  |S.FunCall (S.FunId "block_get", [location; index]) ->
    let location = expression' env location false in
    let index = expression' env index false in
    location
    @ index
    @ single_instruction(T.AAload)
    @ single_instruction(T.Unbox)

  |S.FunCall (S.FunId "block_set", [location; index; e]) ->
     let location = expression' env location false in
     let index = expression' env index false in
     let value = expression' env e false in
     location
     @ index
     @ value
     @ single_instruction(T.Box)
     @ single_instruction(T.AAstore)

  |S.FunCall (fid, actuals) ->
    (* Save current environment and return adress, then bind 
    each formals parameters with their corresponding actual
    parameter, make the call and finally restore the caller
    environment.
       Tail recursion transformation here using a boolean guard tail
     *)
    if ( tail ) then
      let eval, set = set_args env actuals in
      eval
      @ set
      @ single_instruction (T.Goto (lookup_function_label fid env))
    else
      let n = env.nextvar in
      let lab_ret, block_ret =
	labelled_block "ret"
		       (single_instruction(T.Comment "return")) in
      let eval, set = set_args env actuals in
      save_locals n (*old constant pool ???*)
      @ single_instruction (T.Bipush (Labels.encode lab_ret))
      @ eval
      @ set
      @ single_instruction (T.Goto (lookup_function_label fid env))
      @ block_ret
      @ restore_locals n

  |S.UnknownFunCall (e, actuals) ->
    let n = env.nextvar in
    let lab_ret, block_ret =
      labelled_block "ret"
		     (single_instruction(T.Comment "return")) in
    let f = expression' env e false in
    let eval, set = set_args env actuals in
    save_locals n (*old constant pool ???*)
    @ single_instruction (T.Bipush (Labels.encode lab_ret))
    @ eval
    @ set
    @ f
    @ single_instruction (T.Goto (T.Label "dispatch"))
    @ block_ret
    @ restore_locals n
		     
and save_locals n =
  let rec aux acc i =
    if i = n then acc
    else aux ((single_instruction(T.Aload (T.Var i))
	       @single_instruction T.Unbox)@acc) (i+1)
  in aux [] 0
	 
and restore_locals n =
  let rec aux acc i =
    if i = n then acc
    else aux (acc
	      @ single_instruction (T.Swap)
              @ (single_instruction T.Box
	      @ single_instruction (T.Astore (T.Var i))))
	     (i+1)
  in aux [] 0
	 
and set_args env xs =
  let rec aux eval set i = function
    |[] -> (eval, set)
    |e::args ->
      aux (eval@ (expression' env e false))
          ((single_instruction T.Box
		   @ single_instruction (T.Astore (T.Var i)))@set) (i+1) args
  in
  aux [] [] 0 xs
	 
and eval_condition env c tail =
  match Position.value c with
  | S.FunCall (S.FunId fid, [e1;e2])
       when is_cmpop fid ->
     let opd1 = expression' env e1 tail in
     let opd2 = expression' env e2 tail in
     let op = cmpop fid in
     (opd1@opd2, op)
  | e -> 
     (single_instruction (T.Bipush 0)      
       @ expression' env c tail, T.NE)

      
and expression' env e tail =
  expression (Position.position e) env tail (Position.value e)

and is_cmpop = function
  |"=" | "!=" | "<" | "<=" | ">" | ">=" -> true
  | _ -> false

and cmpop = function
  | "="  -> T.EQ
  | "!=" -> T.NE
  | "<"  -> T.LT
  | "<=" -> T.LE
  | ">"  -> T.GT
  | ">=" -> T.GE
  | _    -> assert false (* Absurd by [is_cmpop]. *)

and is_binop = function
  |"+" | "/" | "*" | "-" -> true
  | _ -> false

and binop = function
  | "+"  -> T.Add
  | "/ " -> T.Div
  | "*"  -> T.Mul
  | "-" -> T.Sub
  | _    -> assert false (* Absurd by [is_binop]. *)
	
and label_of_block = function
  | (l, _) :: _ -> l
  | _ -> None

and label_block l =
  fun instructions ->
    match instructions with
    | [] -> assert false (* By previous precondition. *)
    | (Some l, _) :: _ -> assert false (* By precondition. *)
    | (None, i) :: is -> (Some l, i) :: is

and labelled_block =
  let c = ref 0 in
  fun prefix instructions ->
    match label_of_block instructions with
    | None ->
      let l = incr c; T.Label (prefix ^ string_of_int !c) in
      (l, label_block l instructions)
    | Some l ->
      (l, instructions)

and make_basic_block =
  fun prefix instructions ->
  assert (instructions <> []);
  labelled_block
    prefix
    (List.map (fun i -> (None, located_instruction i)) instructions)

and labelled_instruction l i =
  [(Some (T.Label l), located_instruction i)]
      
and single_instruction i =
  [(None, located_instruction i)]
    
and located_instruction i =
  Position.unknown_pos i


