let initialize () =
  Compilers.register "kontix" "kontix"
    (module Compilers.Identity (Kontix) : Compilers.Compiler);
  Compilers.register "fopix" "kontix"
    (module FopixToKontix : Compilers.Compiler)
