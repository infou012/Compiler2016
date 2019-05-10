.class public examples/unk
.super java/lang/Object

.method public static main([Ljava/lang/String;)V
   .limit stack 2
   ; push System.out onto the stack
   getstatic java/lang/System/out Ljava/io/PrintStream;
   ; launch our code and push the int result onto the stack
   invokestatic examples/unk/code()I
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
x4:
	iconst_2
	iconst_5
	invokestatic examples/unk/box(I)Ljava/lang/Object;
	astore 0
	iconst_1
	iconst_2
	if_icmpgt _if_true_2
	iconst_1
	goto _endif_3
_if_true_2:
	iconst_0
_endif_3:
	;; endif
	goto dispatch
ret1:
	;; return
	invokestatic examples/unk/box(I)Ljava/lang/Object;
	astore 0
	aload 0
	invokestatic examples/unk/unbox(Ljava/lang/Object;)I
	ireturn
h_body_3:
	iconst_1
	iconst_1
	if_icmpeq _if_true_11
	iconst_0
	goto _endif_12
_if_true_11:
	aload 0
	invokestatic examples/unk/unbox(Ljava/lang/Object;)I
	bipush 6
	iconst_5
	invokestatic examples/unk/box(I)Ljava/lang/Object;
	astore 0
	iconst_1
	iconst_2
	if_icmplt _if_true_9
	iconst_5
	goto _endif_10
_if_true_9:
	iconst_4
_endif_10:
	;; endif
	goto dispatch
ret8:
	;; return
	swap
	invokestatic examples/unk/box(I)Ljava/lang/Object;
	astore 0
_endif_12:
	;; endif
	swap
	goto dispatch
g_body_2:
	aload 0
	invokestatic examples/unk/unbox(Ljava/lang/Object;)I
	iconst_3
	iadd
	swap
	goto dispatch
f_body_1:
	aload 0
	invokestatic examples/unk/unbox(Ljava/lang/Object;)I
	iconst_0
	if_icmpeq _if_true_5
	aload 0
	invokestatic examples/unk/unbox(Ljava/lang/Object;)I
	aload 0
	invokestatic examples/unk/unbox(Ljava/lang/Object;)I
	iconst_3
	aload 0
	invokestatic examples/unk/unbox(Ljava/lang/Object;)I
	iconst_1
	isub
	invokestatic examples/unk/box(I)Ljava/lang/Object;
	astore 0
	goto f_body_1
ret7:
	;; return
	swap
	invokestatic examples/unk/box(I)Ljava/lang/Object;
	astore 0
	imul
	goto _endif_6
_if_true_5:
	iconst_1
_endif_6:
	;; endif
	swap
	goto dispatch
dispatch:
	tableswitch 0
	f_body_1
	h_body_3
	ret1
	ret7
	f_body_1
	g_body_2
	ret8
	default: _ts_fail_13
_ts_fail_13:
	sipush 10001
	ireturn
.end method
