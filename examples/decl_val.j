.class public examples/decl_val
.super java/lang/Object

.method public static main([Ljava/lang/String;)V
   .limit stack 2
   ; push System.out onto the stack
   getstatic java/lang/System/out Ljava/io/PrintStream;
   ; launch our code and push the int result onto the stack
   invokestatic examples/decl_val/code()I
   ; call the PrintStream.println() method.
   invokevirtual java/io/PrintStream/println(I)V
   ; done
   return
.end method

;;; box : int --> Integer

.method public static box(I)Ljava/lang/Object;
.limit locals 1
.limit stack 3
   new java/lang/Integer
   dup
   iload 0
   invokespecial java/lang/Integer/<init>(I)V
   areturn
.end method

;;; unbox : Integer --> int

.method public static unbox(Ljava/lang/Object;)I
.limit locals 1
.limit stack 1
   aload 0
   checkcast java/lang/Integer
   invokevirtual java/lang/Integer/intValue()I
   ireturn
.end method

;;; the compiled code

.method public static code()I
.limit locals 100
.limit stack 10000
r2:
	iconst_0
	iconst_1
	invokestatic examples/decl_val/box(I)Ljava/lang/Object;
	astore 0
	goto f_body_1
ret1:
	;; return
	invokestatic examples/decl_val/box(I)Ljava/lang/Object;
	astore 0
	aload 0
	invokestatic examples/decl_val/unbox(Ljava/lang/Object;)I
	ireturn
f_body_1:
	aload 0
	invokestatic examples/decl_val/unbox(Ljava/lang/Object;)I
	iconst_1
	iadd
	swap
	goto dispatch
dispatch:
	tableswitch 0
	ret1
	default: _ts_fail_3
_ts_fail_3:
	sipush 10001
	ireturn
.end method
