	.section	__TEXT,__text,regular,pure_instructions
	ldr	x8, [x20, #16]
	ldr	x8, [x8, #16]
	ldr	xzr, [x8]
	cmp	x0, #1
	b.lt	L56
	mov	x9, #0                          ; =0x0
	mov	w10, #1                         ; =0x1
L28:
	mov	x8, x10
	add	x10, x9, x10
	mov	x9, x8
	subs	x0, x0, #1
	b.ne	L28
	mov	x0, x8
	ret
L56:
	mov	x0, #0                          ; =0x0
	ret
