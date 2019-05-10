def tree (tag) = 
   val b = if tag == 0 then {
       	 b = block_create
       	 b.set_tag (tag) // A implementer dans l'interpreteur
       	 }
       	 else {
       	 b = block_create
       	 b.set_tag (tag)
       	 }
	 in b
	 
       