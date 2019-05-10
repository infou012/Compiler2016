(** This module implements a compiler from Fopix to Stackix. *)

let error pos msg =
  Error.error "compilation" pos msg

(** As in any module that implements {!Compilers.Compiler}, the source
    language and the target language must be specified. *)
module Source = Fopix
module Target = Stackix

(** We will need the following pieces of information to be carrying
    along the translation: *)
type environment = {
  (** [variables] is the list of variables that are defined at the point
      of the Fopix program we are. The variables are stored in reverse order
      of their definitions. (The latest variable goes first.) *)
  variables        : Source.AST.identifier list;

  (** [function_labels] maintains the relation between function identifiers and
      their entry point label. *)
  function_labels  : (Source.AST.function_identifier * Target.AST.label) list;

  (** [function_formals] maintains the relation between function identifiers and
      their formal arguments. *)
  function_formals : (Source.AST.function_identifier * Source.AST.formals) list;

  (** [context] is the list of all previously compiled definitions. *)
  context          : Target.AST.t list;
}

(** Initially, the environment is empty. *)
let initial_environment () = {
  variables        = [];
  function_labels  = [];
  function_formals = [];
  context          = [];
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
    Target.AST.Label (f ^ "_body_" ^ string_of_int !r)

(** [push_context after_exit context] push a new set of instructions
    on top of the context. *)
let push_context code context =
  code @ context
	   
(** Variables *)

(** [bind_variable env x] associates Fopix variable x to the next
    available a Stackix variable, and return this variable and the updated
    environment *)
    
 
(** The code of a declaration can be located...*)
type declaration_location =
  (** ... either before exit (because it must be executed). *)
  | BeforeExit of Target.AST.label
  (** ... or after exit (because it is executed only on demand). *)
  | AfterExit of Target.AST.label

let get_fname fid_loc =
  let fid = Position.value fid_loc
  in let fname = match fid with
       |Source.AST.FunId id -> id
     in fname
		   
(** [translate p env] turns a Fopix program [p] into a Stackix program
    using [env] to retrieve contextual information. *)
let rec translate p env =

  (** We prepare our environnement by binding functions declarations first.
   In Fopix and others first order langages, the functions set is fixed and won't
   change during the execution
   **)
  let bind_labels_formals env p =
    let aux env dcl= match dcl with
      |Source.AST.DefineValue _ -> env
      |Source.AST.DefineFunction (fid_loc, formals, _) ->
	let env = bind_labels env (Position.value fid_loc)
			      (fresh_function_label (get_fname fid_loc))
	in bind_formals env (Position.value fid_loc) formals
    in List.fold_left aux env p
  in
					
  (**
     We iterate over the program declarations, we extend the
     environment with the new variables we cross, and we accumulate
     the code that must be put [after_exit].

     [iter] returns a triple consisting in a label pointing to the
     entry of the compiled code, the compiled code and a new
     environment.
  *)
  let rec iter env after_exit = function
    | [] ->
      (** When the iteration is finished, we insert a basic block that
          exits the program. *)
      let l, block = make_basic_block "_exit_" [Target.AST.Exit] in

      (** The context is appended at the end of the program. It
          contains the previously compiled code as well as the body of
          the functions of the current program. *)
      let env = { env with context = push_context after_exit env.context } in
      l, [block] @ env.context, env

    | d :: ds ->
      (** Process a declaration, get a block, a new environment and
          a location to put the block. *)
      let env, location, block = declaration env d in
      match location with
        | BeforeExit l ->
          (** The block must be put right now. So, we compute the compiled
              code for the remaining declarations. *)
          let l', blocks, env = iter env after_exit ds in
          (** Then, we connect the block with the compiled code for the
              remaining declarations. *)
          let blocks =
            (block @ single_instruction (Target.AST.Jump l'))
            :: blocks
          in
          (l, blocks, env)

        | AfterExit l ->
          (** The block must be put after the exit program point. We
              simply accumulate it in [after_exit]. *)
          let after_exit = block :: after_exit in
          iter env after_exit ds
  in
  let env = bind_labels_formals env p in
  let _, blocks, env = iter env [] p in
  (List.flatten blocks, env)

and bind_variable env x =
  { env with variables = x :: env.variables }
    
and bind_formals env f xs =
  { env with function_formals = (f, xs)::env.function_formals }
    
and bind_labels env f ls =
  { env with function_labels = (f,ls)::env.function_labels}
    
    
and zip_formals_and_actuals env actual formal =
  match formal with
  | (Source.AST.Id i) ->
    expression' env actual
    @ single_instruction (Target.AST.Define (Target.AST.Id i))

and declaration env = function
  | Source.AST.DefineValue (x, e) -> Target.AST.(
    (** To compile a value definition, we: *)
    let (Source.AST.Id i) as x = Position.value x in

    let instructions =
      (** 1. Insert the compiled code for the expression [e]. *)
      expression' env e
      (** 2. Insert an instruction to ask the machine to define the
          variable [x]. *)
      @ (single_instruction (Define (Id i)))
    in
    (** 3. We insert a label at the beginning of the block. *)
    let l, block = labelled_block i instructions in
    (** The variable is inserted in the environment. *)
    let env = bind_variable env x in
    (env, BeforeExit l, block)
  )

  | Source.AST.DefineFunction (f, xs, e) ->
    let f_lab = lookup_function_label (Position.value f) env
     in 
     let f_env = List.fold_left bind_variable env xs in
     let instructions = 
      labelled_instruction f_lab (Target.AST.Comment "function body")
      @ expression' f_env e
      @ List.flatten
	  (List.map (fun _ -> single_instruction(Target.AST.Undefine)) xs)
      @ single_instruction(Target.AST.Swap)
      @ single_instruction(Target.AST.UJump) 
    in
    (env, AfterExit f_lab, instructions)
			
    

(** [expression pos env e] compiles [e] into a block of Stackix
    instructions that *does not* start with a label. *)
and expression pos env = function
  | Source.AST.Literal l ->
    single_instruction (literal env l)

  | Source.AST.Variable (Source.AST.Id x as i) ->
    let idx = ExtStd.List.index_of (( = ) i) env.variables in
    single_instruction (Target.AST.GetVariable idx)

  | Source.AST.Define (x, e1, e2) ->
    let Source.AST.Id x as i = Position.value x in
    expression' env e1
    @ single_instruction (Target.AST.(Define (Id x)))
    @ expression' (bind_variable env i) e2
    @ single_instruction Target.AST.Undefine

  | Source.AST.IfThenElse (c, t, f) -> 
    let condition = expression' env c 
    and tl, trueBlock = labelled_block "_if_then_" (expression' env t) 
    and fl, falseBlock = labelled_block "_else_" (expression' env f)
    and el, endBlock = labelled_block "_end_if_" (single_instruction
    (Target.AST.Comment "end_if"))
    in 
    condition
    @ single_instruction (Target.AST.(ConditionalJump (tl, fl)))
    @ trueBlock
    @ single_instruction (Target.AST.Jump(el))
    @ falseBlock
    @ endBlock
   
  | Source.AST.FunCall (Source.AST.FunId f, [e1; e2])
      when is_binop f
    ->
      expression' env e2
    @ expression' env e1
    @ (single_instruction (Target.AST.Binop (binop f)))

  |Source.AST.FunCall (Source.AST.FunId "block_create", [size; init]) ->
    let s = expression' env size in 
    let i = expression' env init in
    s 
    @i
    @ single_instruction(Target.AST.BlockCreate)

  |Source.AST.FunCall (Source.AST.FunId "block_get", [location; index]) ->
    let loc = expression' env location in
    let ind = expression' env index in
    loc
    @ind
    @ single_instruction(Target.AST.BlockGet)

  |Source.AST.FunCall (Source.AST.FunId "block_set", [location; index; e]) ->
    let loc = expression' env location in 
    let ind = expression' env index in 
    let exp = expression' env e in
    loc@ind@exp@single_instruction(Target.AST.BlockSet)

  | Source.AST.FunCall (f, actuals) ->
    let f_label = lookup_function_label f env in
    let formals = lookup_function_formals f env in
    let ret, block_comment = labelled_block "ret" (single_instruction
    (Target.AST.Comment "retour de fonction")) in
    try
      (List.(flatten (map2 (zip_formals_and_actuals env) actuals formals)))
      @ single_instruction (Target.AST.RememberLabel ret)
      @ single_instruction (Target.AST.Jump f_label)
      @ block_comment
    with
      Invalid_argument ("List.map2") ->
	failwith "invalid number of arguments"

and literal env = function
  | Source.AST.LInt x -> Target.AST.Remember x

and expression' env e =
  expression (Position.position e) env (Position.value e)

and is_binop = function
  | "+" | "-" | "*" | "/" | "<" | ">" | "=" | "<=" | ">=" -> true
  | _ -> false

and binop = function
  | "+" -> Target.AST.Add
  | "-" -> Target.AST.Sub
  | "*" -> Target.AST.Mul
  | "/" -> Target.AST.Div
  | "<" -> Target.AST.LT
  | ">" -> Target.AST.GT
  | "<=" -> Target.AST.LTE
  | ">=" -> Target.AST.GTE
  | "=" -> Target.AST.EQ
  | _ -> assert false (* Absurd by [is_binop]. *)

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
        let l = incr c; Target.AST.Label (prefix ^ string_of_int !c) in
        (l, label_block l instructions)
      | Some l ->
        (l, instructions)

and single_instruction i =
  [(None, located_instruction i)]

and labelled_instruction l i =
  [(Some l, located_instruction i)]
    
and make_basic_block =
  fun prefix instructions ->
    assert (instructions <> []);
    labelled_block prefix (
      List.map (fun i -> (None, located_instruction i)) instructions
    )

and located_instruction i =
  Position.unknown_pos i
