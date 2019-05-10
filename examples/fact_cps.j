.class public examples/fact_cps
.super java/lang/Object

.method public static main([Ljava/lang/String;)V
   .limit stack 2
   ; push System.out onto the stack
   getstatic java/lang/System/out Ljava/io/PrintStream;
   ; launch our code and push the int result onto the stack
   invokestatic examples/fact_cps/code()I
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
res6:
	iconst_4
	bipush 10
	iconst_3
	iconst_0
	iconst_0
	anewarray java/lang/Object
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 2
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 1
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 0
	goto fact_body_1
ret5:
	;; return
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 0
	aload 0
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	ireturn
init_body_3:
	aload 1
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	swap
	goto dispatch
aux_body_2:
	aload 0
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	iconst_0
	aaload
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 2
	aload 0
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	iconst_1
	aaload
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 3
	aload 0
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	iconst_2
	aaload
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 4
	aload 4
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	aload 3
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	aload 2
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	aload 1
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	aload 0
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	iconst_2
	aload 4
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	aload 1
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	aload 2
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	imul
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 1
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 0
	aload 3
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	goto dispatch
ret4:
	;; return
	swap
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 0
	swap
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 1
	swap
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 2
	swap
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 3
	swap
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 4
	swap
	goto dispatch
fact_body_1:
	aload 0
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	iconst_0
	if_icmpeq _if_true_2
	aload 0
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	iconst_1
	isub
	iconst_1
	iconst_0
	iconst_3
	anewarray java/lang/Object
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 3
	aload 3
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	iconst_0
	aload 0
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	aastore
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 4
	aload 3
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	iconst_1
	aload 1
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	aastore
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 5
	aload 3
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	iconst_2
	aload 2
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	aastore
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 6
	aload 3
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 2
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 1
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 0
	goto fact_body_1
	goto _endif_3
_if_true_2:
	aload 2
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	aload 1
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	aload 0
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	iconst_0
	aload 2
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	iconst_1
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 1
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 0
	aload 1
	invokestatic examples/fact_cps/unbox(Ljava/lang/Object;)I
	goto dispatch
ret1:
	;; return
	swap
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 0
	swap
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 1
	swap
	invokestatic examples/fact_cps/box(I)Ljava/lang/Object;
	astore 2
_endif_3:
	;; endif
	swap
	goto dispatch
dispatch:
	tableswitch 0
	ret1
	aux_body_2
	ret4
	init_body_3
	ret5
	default: _ts_fail_7
_ts_fail_7:
	sipush 10001
	ireturn
.end method
