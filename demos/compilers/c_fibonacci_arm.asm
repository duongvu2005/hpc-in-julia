
c_fibonacci:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000100003eb4 <_fibonacci>:
100003eb4: d100c3ff    	sub	sp, sp, #0x30
100003eb8: b9000fe0    	str	w0, [sp, #0xc]
100003ebc: f90017ff    	str	xzr, [sp, #0x28]
100003ec0: d2800020    	mov	x0, #0x1                ; =1
100003ec4: f90013e0    	str	x0, [sp, #0x20]
100003ec8: 1400000c    	b	0x100003ef8 <_fibonacci+0x44>
100003ecc: f94017e1    	ldr	x1, [sp, #0x28]
100003ed0: f94013e0    	ldr	x0, [sp, #0x20]
100003ed4: 8b000020    	add	x0, x1, x0
100003ed8: f9000fe0    	str	x0, [sp, #0x18]
100003edc: f94013e0    	ldr	x0, [sp, #0x20]
100003ee0: f90017e0    	str	x0, [sp, #0x28]
100003ee4: f9400fe0    	ldr	x0, [sp, #0x18]
100003ee8: f90013e0    	str	x0, [sp, #0x20]
100003eec: b9400fe0    	ldr	w0, [sp, #0xc]
100003ef0: 51000400    	sub	w0, w0, #0x1
100003ef4: b9000fe0    	str	w0, [sp, #0xc]
100003ef8: b9400fe0    	ldr	w0, [sp, #0xc]
100003efc: 7100001f    	cmp	w0, #0x0
100003f00: 54fffe6c    	b.gt	0x100003ecc <_fibonacci+0x18>
100003f04: f94017e0    	ldr	x0, [sp, #0x28]
100003f08: 9100c3ff    	add	sp, sp, #0x30
100003f0c: d65f03c0    	ret

0000000100003f10 <_main>:
100003f10: d10103ff    	sub	sp, sp, #0x40
100003f14: a9017bfd    	stp	x29, x30, [sp, #0x10]
100003f18: 910043fd    	add	x29, sp, #0x10
100003f1c: b9001fa0    	str	w0, [x29, #0x1c]
100003f20: f9000ba1    	str	x1, [x29, #0x10]
100003f24: f9400ba0    	ldr	x0, [x29, #0x10]
100003f28: 91002000    	add	x0, x0, #0x8
100003f2c: f9400000    	ldr	x0, [x0]
100003f30: 9400000c    	bl	0x100003f60 <_printf+0x100003f60>
100003f34: b9002fa0    	str	w0, [x29, #0x2c]
100003f38: b9402fa0    	ldr	w0, [x29, #0x2c]
100003f3c: 97ffffde    	bl	0x100003eb4 <_fibonacci>
100003f40: f90003e0    	str	x0, [sp]
100003f44: 90000000    	adrp	x0, 0x100003000 <_printf+0x100003000>
100003f48: 913de000    	add	x0, x0, #0xf78
100003f4c: 94000008    	bl	0x100003f6c <_printf+0x100003f6c>
100003f50: 52800000    	mov	w0, #0x0                ; =0
100003f54: a9417bfd    	ldp	x29, x30, [sp, #0x10]
100003f58: 910103ff    	add	sp, sp, #0x40
100003f5c: d65f03c0    	ret

Disassembly of section __TEXT,__stubs:

0000000100003f60 <__stubs>:
100003f60: b0000010    	adrp	x16, 0x100004000 <_printf+0x100004000>
100003f64: f9400210    	ldr	x16, [x16]
100003f68: d61f0200    	br	x16
100003f6c: b0000010    	adrp	x16, 0x100004000 <_printf+0x100004000>
100003f70: f9400610    	ldr	x16, [x16, #0x8]
100003f74: d61f0200    	br	x16
