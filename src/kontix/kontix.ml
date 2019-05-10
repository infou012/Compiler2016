(** The kontix programming language :
    fopix with only tail calls *)

(** We reuse the same AST as Fopix, and printer, parser, etc *)
module KontixAST = FopixAST
module KontixPrettyPrinter = FopixPrettyPrinter
module KontixLexer = FopixLexer
module KontixParser = FopixParser
module KontixInterpreter = FopixInterpreter
module KontixTypechecker = FopixTypechecker

module AST = KontixAST

type ast = KontixAST.t

let parse lexer_init input =
  SyntacticAnalysis.process
    ~lexer_init
    ~lexer_fun:KontixLexer.token
    ~parser_fun:KontixParser.program
    ~input

let parse_filename filename =
  parse Lexing.from_channel (open_in filename)

let extension =
  ".kontix"

let parse_string =
  parse Lexing.from_string

let print_ast ast =
  KontixPrettyPrinter.(to_string program ast)

include KontixInterpreter
include KontixTypechecker
