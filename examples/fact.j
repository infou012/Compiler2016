.class public examples/fact
.super java/lang/Object

.method public static main([Ljava/lang/String;)V
   .limit stack 2
   ; push System.out onto the stack
   getstatic java/lang/System/out Ljava/io/PrintStream;
   ; launch our code and push the int result onto the stack
   invokestatic examples/fact/code()I
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
res5:
	iconst_1
	bipush 10
	invokestatic examples/fact/box(I)Ljava/lang/Object;
	astore 0
	goto fact_body_1
ret4:
	;; return
	invokestatic examples/fact/box(I)Ljava/lang/Object;
	astore 0
	aload 0
	invokestatic examples/fact/unbox(Ljava/lang/Object;)I
	ireturn
fact_body_1:
	aload 0
	invokestatic examples/fact/unbox(Ljava/lang/Object;)I
	iconst_0
	if_icmpeq _if_true_1
	aload 0
	invokestatic examples/fact/unbox(Ljava/lang/Object;)I
	aload 0
	invokestatic examples/fact/unbox(Ljava/lang/Object;)I
	iconst_0
	aload 0
	invokestatic examples/fact/unbox(Ljava/lang/Object;)I
	iconst_1
	isub
	invokestatic examples/fact/box(I)Ljava/lang/Object;
	astore 0
	goto fact_body_1
ret3:
	;; return
	swap
	invokestatic examples/fact/box(I)Ljava/lang/Object;
	astore 0
	imul
	goto _endif_2
_if_true_1:
	iconst_1
_endif_2:
	;; endif
	swap
	goto dispatch
dispatch:
	tableswitch 0
	ret3
	ret4
	default: _ts_fail_6
_ts_fail_6:
	sipush 10001
	ireturn
.end method
