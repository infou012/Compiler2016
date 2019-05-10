.class public examples/test
.super java/lang/Object

.method public static main([Ljava/lang/String;)V
   .limit stack 2
   ; push System.out onto the stack
   getstatic java/lang/System/out Ljava/io/PrintStream;
   ; launch our code and push the int result onto the stack
   invokestatic examples/test/code()I
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
	iconst_0
	iconst_3
	iconst_1
	invokestatic examples/test/box(I)Ljava/lang/Object;
	astore 1
	invokestatic examples/test/box(I)Ljava/lang/Object;
	astore 0
	goto f_body_1
ret3:
	;; return
	invokestatic examples/test/box(I)Ljava/lang/Object;
	astore 0
	aload 0
	invokestatic examples/test/unbox(Ljava/lang/Object;)I
	ireturn
f_body_1:
	aload 0
	invokestatic examples/test/unbox(Ljava/lang/Object;)I
	iconst_0
	if_icmpeq _if_true_1
	aload 0
	invokestatic examples/test/unbox(Ljava/lang/Object;)I
	iconst_1
	isub
	aload 1
	invokestatic examples/test/unbox(Ljava/lang/Object;)I
	aload 0
	invokestatic examples/test/unbox(Ljava/lang/Object;)I
	imul
	invokestatic examples/test/box(I)Ljava/lang/Object;
	astore 1
	invokestatic examples/test/box(I)Ljava/lang/Object;
	astore 0
	goto f_body_1
	goto _endif_2
_if_true_1:
	aload 1
	invokestatic examples/test/unbox(Ljava/lang/Object;)I
_endif_2:
	;; endif
	swap
	goto dispatch
dispatch:
	tableswitch 0
	ret3
	default: _ts_fail_5
_ts_fail_5:
	sipush 10001
	ireturn
.end method
