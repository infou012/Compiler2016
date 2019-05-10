.class public examples/block_create
.super java/lang/Object

.method public static main([Ljava/lang/String;)V
   .limit stack 2
   ; push System.out onto the stack
   getstatic java/lang/System/out Ljava/io/PrintStream;
   ; launch our code and push the int result onto the stack
   invokestatic examples/block_create/code()I
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
x1:
	iconst_0
	iconst_2
	anewarray java/lang/Object
	invokestatic examples/block_create/box(I)Ljava/lang/Object;
	astore 0
z2:
	aload 0
	invokestatic examples/block_create/unbox(Ljava/lang/Object;)I
	iconst_0
	iconst_3
	invokestatic examples/block_create/box(I)Ljava/lang/Object;
	aastore
	invokestatic examples/block_create/box(I)Ljava/lang/Object;
	astore 1
o3:
	aload 0
	invokestatic examples/block_create/unbox(Ljava/lang/Object;)I
	iconst_0
	aaload
	invokestatic examples/block_create/unbox(Ljava/lang/Object;)I
	invokestatic examples/block_create/box(I)Ljava/lang/Object;
	astore 2
	aload 2
	invokestatic examples/block_create/unbox(Ljava/lang/Object;)I
	ireturn
dispatch:
	tableswitch 0
	
	default: _ts_fail_4
_ts_fail_4:
	sipush 10001
	ireturn
.end method
