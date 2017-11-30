	.file	"RHUtils.c"
	.globl	clk_freq
	.data
	.align 8
	.type	clk_freq, @object
	.size	clk_freq, 8
clk_freq:
	.quad	-1
	.text
	.globl	clock_overhead
	.type	clock_overhead, @function
clock_overhead:
.LFB23:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$112, %rsp
	movl	%edi, -100(%rbp)
	movq	$0, -16(%rbp)
	movq	$0, -8(%rbp)
	jmp	.L2
.L3:
	movl	-100(%rbp), %eax
	movl	%eax, -88(%rbp)
	movl	-88(%rbp), %eax
	leaq	-96(%rbp), %rdx
	addq	$16, %rdx
	movq	%rdx, %rsi
	movl	%eax, %edi
	call	clock_gettime
	movl	-88(%rbp), %eax
	leaq	-96(%rbp), %rdx
	addq	$32, %rdx
	movq	%rdx, %rsi
	movl	%eax, %edi
	call	clock_gettime
	movq	-64(%rbp), %rdx
	movq	-80(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	imulq	$1000000000, %rax, %rax
	movq	-56(%rbp), %rcx
	movq	-72(%rbp), %rdx
	subq	%rdx, %rcx
	movq	%rcx, %rdx
	addq	%rdx, %rax
	movq	%rax, -96(%rbp)
	movq	-96(%rbp), %rax
	addq	%rax, -16(%rbp)
	addq	$1, -8(%rbp)
.L2:
	cmpq	$9, -8(%rbp)
	jbe	.L3
	movq	$0, -16(%rbp)
	movq	$0, -8(%rbp)
	jmp	.L4
.L5:
	movl	-100(%rbp), %eax
	movl	%eax, -88(%rbp)
	movl	-88(%rbp), %eax
	leaq	-96(%rbp), %rdx
	addq	$16, %rdx
	movq	%rdx, %rsi
	movl	%eax, %edi
	call	clock_gettime
	movl	-88(%rbp), %eax
	leaq	-96(%rbp), %rdx
	addq	$32, %rdx
	movq	%rdx, %rsi
	movl	%eax, %edi
	call	clock_gettime
	movq	-64(%rbp), %rdx
	movq	-80(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	imulq	$1000000000, %rax, %rax
	movq	-56(%rbp), %rcx
	movq	-72(%rbp), %rdx
	subq	%rdx, %rcx
	movq	%rcx, %rdx
	addq	%rdx, %rax
	movq	%rax, -96(%rbp)
	movq	-96(%rbp), %rax
	addq	%rax, -16(%rbp)
	addq	$1, -8(%rbp)
.L4:
	cmpq	$99, -8(%rbp)
	jbe	.L5
	movq	-16(%rbp), %rax
	shrq	$2, %rax
	movabsq	$2951479051793528259, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$2, %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE23:
	.size	clock_overhead, .-clock_overhead
	.globl	tsc_overhead
	.type	tsc_overhead, @function
tsc_overhead:
.LFB24:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	.cfi_offset 3, -24
	movq	$0, -24(%rbp)
	movq	$0, -16(%rbp)
	jmp	.L8
.L9:
#APP
# 90 "timing.h" 1
	cpuid 
    rdtsc 
    shlq $32, %rdx 
    orq %rdx, %rax
# 0 "" 2
#NO_APP
	movq	%rax, -48(%rbp)
#APP
# 91 "timing.h" 1
	rdtscp 
    shlq $32, %rdx 
    orq %rdx, %rax 
    movq %rax, %rsi 
    cpuid
# 0 "" 2
#NO_APP
	movq	%rsi, -40(%rbp)
	movq	-40(%rbp), %rdx
	movq	-48(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	movq	%rax, -56(%rbp)
	movq	-56(%rbp), %rax
	addq	%rax, -24(%rbp)
	addq	$1, -16(%rbp)
.L8:
	cmpq	$9, -16(%rbp)
	jbe	.L9
	movq	$0, -24(%rbp)
	movq	$0, -16(%rbp)
	jmp	.L10
.L12:
#APP
# 98 "timing.h" 1
	cpuid 
    rdtsc 
    shlq $32, %rdx 
    orq %rdx, %rax
# 0 "" 2
#NO_APP
	movq	%rax, -48(%rbp)
#APP
# 99 "timing.h" 1
	rdtscp 
    shlq $32, %rdx 
    orq %rdx, %rax 
    movq %rax, %rsi 
    cpuid
# 0 "" 2
#NO_APP
	movq	%rsi, -40(%rbp)
	movq	-40(%rbp), %rdx
	movq	-48(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	movq	%rax, -56(%rbp)
	movq	-56(%rbp), %rax
	cmpq	$99, %rax
	ja	.L11
	movq	-56(%rbp), %rax
	addq	%rax, -24(%rbp)
.L11:
	addq	$1, -16(%rbp)
.L10:
	cmpq	$999, -16(%rbp)
	jbe	.L12
	movq	-24(%rbp), %rax
	shrq	$3, %rax
	movabsq	$2361183241434822607, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$4, %rax
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE24:
	.size	tsc_overhead, .-tsc_overhead
	.globl	tsc_measure_freq
	.type	tsc_measure_freq, @function
tsc_measure_freq:
.LFB25:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$88, %rsp
	.cfi_offset 3, -24
#APP
# 110 "timing.h" 1
	cpuid 
    rdtsc 
    shlq $32, %rdx 
    orq %rdx, %rax
# 0 "" 2
#NO_APP
	movq	%rax, -40(%rbp)
	movl	$1000000, %edi
	call	usleep
#APP
# 112 "timing.h" 1
	rdtscp 
    shlq $32, %rdx 
    orq %rdx, %rax 
    movq %rax, %rsi 
    cpuid
# 0 "" 2
#NO_APP
	movq	%rsi, -32(%rbp)
	movq	-32(%rbp), %rdx
	movq	-40(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	movq	%rax, -48(%rbp)
	movq	-48(%rbp), %rax
	addq	$88, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE25:
	.size	tsc_measure_freq, .-tsc_measure_freq
	.globl	tsc_to_ns
	.type	tsc_to_ns, @function
tsc_to_ns:
.LFB26:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	imulq	$1000000000, %rax, %rax
	movq	clk_freq(%rip), %rcx
	movl	$0, %edx
	divq	%rcx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE26:
	.size	tsc_to_ns, .-tsc_to_ns
	.globl	hammer_loop
	.type	hammer_loop, @function
hammer_loop:
.LFB27:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r12
	pushq	%rbx
	.cfi_offset 12, -24
	.cfi_offset 3, -32
	movq	%rdi, -104(%rbp)
	movq	%rsi, -112(%rbp)
	movl	%edx, -116(%rbp)
	movl	%ecx, -120(%rbp)
	movl	-116(%rbp), %r12d
#APP
# 36 "hammer.h" 1
	cpuid 
    rdtsc 
    shlq $32, %rdx 
    orq %rdx, %rax
# 0 "" 2
#NO_APP
	movq	%rax, -40(%rbp)
	jmp	.L19
.L21:
	movl	-120(%rbp), %ebx
	movq	-104(%rbp), %rdx
	movq	-112(%rbp), %rcx
#APP
# 39 "hammer.h" 1
	movq (%rdx), %rax 
	movq (%rcx), %rax 
	clflush (%rdx) 
	clflush (%rcx) 
	
# 0 "" 2
#NO_APP
	nop
.L20:
	movl	%ebx, %eax
	leal	-1(%rax), %ebx
	testl	%eax, %eax
	jg	.L20
.L19:
	movl	%r12d, %eax
	leal	-1(%rax), %r12d
	testl	%eax, %eax
	jne	.L21
#APP
# 42 "hammer.h" 1
	rdtscp 
    shlq $32, %rdx 
    orq %rdx, %rax 
    movq %rax, %rsi 
    cpuid
# 0 "" 2
#NO_APP
	movq	%rsi, -32(%rbp)
	movq	-32(%rbp), %rdx
	movq	-40(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	movq	%rax, -48(%rbp)
	movq	-48(%rbp), %rax
	popq	%rbx
	popq	%r12
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE27:
	.size	hammer_loop, .-hammer_loop
	.globl	hammer_loop_fence
	.type	hammer_loop_fence, @function
hammer_loop_fence:
.LFB28:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r12
	pushq	%rbx
	.cfi_offset 12, -24
	.cfi_offset 3, -32
	movq	%rdi, -104(%rbp)
	movq	%rsi, -112(%rbp)
	movl	%edx, -116(%rbp)
	movl	%ecx, -120(%rbp)
	movl	-116(%rbp), %r12d
#APP
# 53 "hammer.h" 1
	cpuid 
    rdtsc 
    shlq $32, %rdx 
    orq %rdx, %rax
# 0 "" 2
#NO_APP
	movq	%rax, -40(%rbp)
	jmp	.L24
.L26:
	movl	-120(%rbp), %ebx
	movq	-104(%rbp), %rdx
	movq	-112(%rbp), %rcx
#APP
# 56 "hammer.h" 1
	movq (%rdx), %rax 
	movq (%rcx), %rax 
	clflush (%rdx) 
	clflush (%rcx) 
	mfence
# 0 "" 2
#NO_APP
	nop
.L25:
	movl	%ebx, %eax
	leal	-1(%rax), %ebx
	testl	%eax, %eax
	jg	.L25
.L24:
	movl	%r12d, %eax
	leal	-1(%rax), %r12d
	testl	%eax, %eax
	jne	.L26
#APP
# 59 "hammer.h" 1
	rdtscp 
    shlq $32, %rdx 
    orq %rdx, %rax 
    movq %rax, %rsi 
    cpuid
# 0 "" 2
#NO_APP
	movq	%rsi, -32(%rbp)
	movq	-32(%rbp), %rdx
	movq	-40(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	movq	%rax, -48(%rbp)
	movq	-48(%rbp), %rax
	popq	%rbx
	popq	%r12
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE28:
	.size	hammer_loop_fence, .-hammer_loop_fence
	.globl	fd_pagemap
	.data
	.align 4
	.type	fd_pagemap, @object
	.size	fd_pagemap, 4
fd_pagemap:
	.long	-1
	.section	.rodata
.LC0:
	.string	"/proc/self/pagemap"
	.align 8
.LC1:
	.string	"ASSERT error: (fd_pagemap = open(\"/proc/self/pagemap\", O_RDONLY)) > 0"
	.align 8
.LC2:
	.string	"ASSERT error: lseek(fd_pagemap, pfn_item_offset, SEEK_SET) != -1"
	.align 8
.LC3:
	.string	"ASSERT error: read(fd_pagemap, &pfn_item, sizeof(uint64_t)) == sizeof(uint64_t)"
	.text
	.globl	v2p
	.type	v2p, @function
v2p:
.LFB29:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	movq	%rdi, -56(%rbp)
	movl	fd_pagemap(%rip), %eax
	testl	%eax, %eax
	jns	.L29
	movl	$0, %esi
	movl	$.LC0, %edi
	movl	$0, %eax
	call	open
	movl	%eax, fd_pagemap(%rip)
	movl	fd_pagemap(%rip), %eax
	testl	%eax, %eax
	jg	.L29
	movl	$.LC1, %edi
	call	rb_sys_fail
.L29:
	movq	-56(%rbp), %rax
	shrq	$12, %rax
	movq	%rax, -8(%rbp)
	movq	-56(%rbp), %rax
	andl	$4095, %eax
	movq	%rax, -16(%rbp)
	movq	-8(%rbp), %rax
	salq	$3, %rax
	movq	%rax, -24(%rbp)
	movq	-24(%rbp), %rcx
	movl	fd_pagemap(%rip), %eax
	movl	$0, %edx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	lseek
	cmpq	$-1, %rax
	jne	.L30
	movl	$.LC2, %edi
	call	rb_sys_fail
.L30:
	movl	fd_pagemap(%rip), %eax
	leaq	-40(%rbp), %rcx
	movl	$8, %edx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	read
	cmpq	$8, %rax
	je	.L31
	movl	$.LC3, %edi
	call	rb_sys_fail
.L31:
	movq	-40(%rbp), %rdx
	movabsq	$36028797018963967, %rax
	andq	%rdx, %rax
	movq	%rax, -32(%rbp)
	movq	-32(%rbp), %rax
	salq	$12, %rax
	movq	%rax, %rdx
	movq	-16(%rbp), %rax
	addq	%rdx, %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE29:
	.size	v2p, .-v2p
	.local	module
	.comm	module,8,8
	.local	page_class
	.comm	page_class,8,8
	.section	.rodata
.LC4:
	.string	"@v"
.LC5:
	.string	"@p"
	.text
	.type	initialize, @function
initialize:
.LFB30:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movl	$1, %edx
	movl	$.LC4, %esi
	movq	%rax, %rdi
	call	rb_iv_set
	movq	-8(%rbp), %rax
	movl	$1, %edx
	movl	$.LC5, %esi
	movq	%rax, %rdi
	call	rb_iv_set
	movq	-8(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE30:
	.size	initialize, .-initialize
	.section	.rodata
	.align 8
.LC6:
	.string	"ASSERT error: (v = (char *)mmap(0, ALLOC_SIZE, PROT_READ | PROT_WRITE, ALLOC_FLAG, -1, 0)) != MAP_FAILED"
	.text
	.type	acquire, @function
acquire:
.LFB31:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movl	$0, %r9d
	movl	$-1, %r8d
	movl	$34, %ecx
	movl	$3, %edx
	movl	$4096, %esi
	movl	$0, %edi
	call	mmap
	movq	%rax, -8(%rbp)
	cmpq	$-1, -8(%rbp)
	jne	.L36
	movl	$.LC6, %edi
	call	rb_sys_fail
.L36:
	movq	-8(%rbp), %rax
	movl	$4096, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	memset
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	v2p
	movq	%rax, -16(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	rb_ull2inum
	movq	%rax, %rdx
	movq	-24(%rbp), %rax
	movl	$.LC4, %esi
	movq	%rax, %rdi
	call	rb_iv_set
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	rb_ull2inum
	movq	%rax, %rdx
	movq	-24(%rbp), %rax
	movl	$.LC5, %esi
	movq	%rax, %rdi
	call	rb_iv_set
	movq	-24(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE31:
	.size	acquire, .-acquire
	.type	release, @function
release:
.LFB32:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	-24(%rbp), %rax
	movl	$.LC4, %esi
	movq	%rax, %rdi
	call	rb_iv_get
	movq	%rax, %rdi
	call	rb_num2ull
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	je	.L39
	movq	-8(%rbp), %rax
	movl	$4096, %esi
	movq	%rax, %rdi
	call	munmap
.L39:
	movq	-24(%rbp), %rax
	movl	$1, %edx
	movl	$.LC4, %esi
	movq	%rax, %rdi
	call	rb_iv_set
	movq	-24(%rbp), %rax
	movl	$1, %edx
	movl	$.LC5, %esi
	movq	%rax, %rdi
	call	rb_iv_set
	movq	-24(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE32:
	.size	release, .-release
	.type	fill_impl, @function
fill_impl:
.LFB33:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	-24(%rbp), %rax
	movl	$.LC4, %esi
	movq	%rax, %rdi
	call	rb_iv_get
	movq	%rax, %rdi
	call	rb_num2ull
	movq	%rax, -8(%rbp)
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	rb_fix2int
	movb	%al, -9(%rbp)
	movzbl	-9(%rbp), %ecx
	movq	-8(%rbp), %rax
	movl	$4096, %edx
	movl	%ecx, %esi
	movq	%rax, %rdi
	call	memset
	movq	-24(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE33:
	.size	fill_impl, .-fill_impl
	.type	check_impl, @function
check_impl:
.LFB34:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	movq	%rsi, -48(%rbp)
	movq	-40(%rbp), %rax
	movl	$.LC4, %esi
	movq	%rax, %rdi
	call	rb_iv_get
	movq	%rax, %rdi
	call	rb_num2ull
	movq	%rax, -16(%rbp)
	movq	-48(%rbp), %rax
	movq	%rax, %rdi
	call	rb_fix2int
	movb	%al, -17(%rbp)
	call	rb_ary_new
	movq	%rax, -32(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L44
.L46:
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	-16(%rbp), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	cmpb	-17(%rbp), %al
	je	.L45
	movl	-4(%rbp), %eax
	cltq
	addq	%rax, %rax
	orq	$1, %rax
	movq	%rax, %rdx
	movq	-32(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	rb_ary_push
.L45:
	addl	$1, -4(%rbp)
.L44:
	cmpl	$4095, -4(%rbp)
	jle	.L46
	movq	-32(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE34:
	.size	check_impl, .-check_impl
	.type	get, @function
get:
.LFB35:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	-24(%rbp), %rax
	movl	$.LC4, %esi
	movq	%rax, %rdi
	call	rb_iv_get
	movq	%rax, %rdi
	call	rb_num2ull
	movq	%rax, -8(%rbp)
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	rb_fix2int
	movl	%eax, -12(%rbp)
	movl	-12(%rbp), %eax
	movslq	%eax, %rdx
	movq	-8(%rbp), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	movzbl	%al, %eax
	addq	%rax, %rax
	orq	$1, %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE35:
	.size	get, .-get
	.type	set, @function
set:
.LFB36:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$56, %rsp
	.cfi_offset 3, -24
	movq	%rdi, -40(%rbp)
	movq	%rsi, -48(%rbp)
	movq	%rdx, -56(%rbp)
	movq	-40(%rbp), %rax
	movl	$.LC4, %esi
	movq	%rax, %rdi
	call	rb_iv_get
	movq	%rax, %rdi
	call	rb_num2ull
	movq	%rax, -24(%rbp)
	movq	-48(%rbp), %rax
	movq	%rax, %rdi
	call	rb_fix2int
	movl	%eax, -28(%rbp)
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	-24(%rbp), %rax
	leaq	(%rdx,%rax), %rbx
	movq	-56(%rbp), %rax
	movq	%rax, %rdi
	call	rb_fix2int
	movb	%al, (%rbx)
	movq	-40(%rbp), %rax
	addq	$56, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE36:
	.size	set, .-set
	.type	rb_hammer, @function
rb_hammer:
.LFB37:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$80, %rsp
	movq	%rdi, -40(%rbp)
	movq	%rsi, -48(%rbp)
	movq	%rdx, -56(%rbp)
	movq	%rcx, -64(%rbp)
	movq	%r8, -72(%rbp)
	movq	-48(%rbp), %rax
	movq	%rax, %rdi
	call	rb_num2ull
	movq	%rax, -8(%rbp)
	movq	-56(%rbp), %rax
	movq	%rax, %rdi
	call	rb_num2ull
	movq	%rax, -16(%rbp)
	movq	-64(%rbp), %rax
	movq	%rax, %rdi
	call	rb_fix2int
	movl	%eax, -20(%rbp)
	movq	-72(%rbp), %rax
	movq	%rax, %rdi
	call	rb_fix2int
	movl	%eax, -24(%rbp)
	movl	-24(%rbp), %ecx
	movl	-20(%rbp), %edx
	movq	-16(%rbp), %rsi
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	hammer_loop
	movq	%rax, %rdi
	call	rb_ull2inum
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE37:
	.size	rb_hammer, .-rb_hammer
	.type	rb_access_time, @function
rb_access_time:
.LFB38:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	movq	%rdi, -40(%rbp)
	movq	%rsi, -48(%rbp)
	movq	%rdx, -56(%rbp)
	movq	-48(%rbp), %rax
	movq	%rax, %rdi
	call	rb_num2ull
	movq	%rax, -16(%rbp)
	movq	-56(%rbp), %rax
	movq	%rax, %rdi
	call	rb_num2ull
	movq	%rax, -24(%rbp)
	movl	$999, -4(%rbp)
	jmp	.L55
.L56:
	movq	-24(%rbp), %rsi
	movq	-16(%rbp), %rax
	movl	$0, %ecx
	movl	$100, %edx
	movq	%rax, %rdi
	call	hammer_loop_fence
	shrq	$3, %rax
	movabsq	$2951479051793528259, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$2, %rax
	movl	%eax, -28(%rbp)
	movl	-28(%rbp), %eax
	cmpl	-4(%rbp), %eax
	jge	.L55
	movl	-28(%rbp), %eax
	movl	%eax, -4(%rbp)
.L55:
	cmpl	$400, -4(%rbp)
	jg	.L56
	movl	-4(%rbp), %eax
	cltq
	addq	%rax, %rax
	orq	$1, %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE38:
	.size	rb_access_time, .-rb_access_time
	.type	bit_ffs, @function
bit_ffs:
.LFB39:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	rb_num2ull
	movq	$-1, %rdx
	bsfq	%rax, %rax
	cmove	%rdx, %rax
	addq	$1, %rax
	cltq
	addq	%rax, %rax
	orq	$1, %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE39:
	.size	bit_ffs, .-bit_ffs
	.type	bit_clz, @function
bit_clz:
.LFB40:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	rb_num2ull
	bsrq	%rax, %rax
	xorq	$63, %rax
	cltq
	addq	%rax, %rax
	orq	$1, %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE40:
	.size	bit_clz, .-bit_clz
	.type	rb_mem_size, @function
rb_mem_size:
.LFB41:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	addq	$-128, %rsp
	movq	%rdi, -120(%rbp)
	leaq	-112(%rbp), %rax
	movq	%rax, %rdi
	call	sysinfo
	movq	-80(%rbp), %rax
	movl	-8(%rbp), %edx
	movl	%edx, %edx
	imulq	%rdx, %rax
	movq	%rax, %rdi
	call	rb_ull2inum
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE41:
	.size	rb_mem_size, .-rb_mem_size
	.type	rb_get_cpu_freq, @function
rb_get_cpu_freq:
.LFB42:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	call	tsc_measure_freq
	movq	%rax, %rdi
	call	rb_ull2inum
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE42:
	.size	rb_get_cpu_freq, .-rb_get_cpu_freq
	.section	.rodata
.LC7:
	.string	"RHUtils"
.LC8:
	.string	"Page"
.LC9:
	.string	"v"
.LC10:
	.string	"p"
.LC11:
	.string	"initialize"
.LC12:
	.string	"acquire"
.LC13:
	.string	"release"
.LC14:
	.string	"c_check"
.LC15:
	.string	"c_fill"
.LC16:
	.string	"get"
.LC17:
	.string	"set"
.LC18:
	.string	"c_hammer"
.LC19:
	.string	"access_time"
.LC20:
	.string	"bit_ffs"
.LC21:
	.string	"bit_clz"
.LC22:
	.string	"physmem_size"
.LC23:
	.string	"get_cpu_freq"
	.text
	.globl	Init_RHUtils
	.type	Init_RHUtils, @function
Init_RHUtils:
.LFB43:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$.LC7, %edi
	call	rb_define_module
	movq	%rax, module(%rip)
	movq	rb_cObject(%rip), %rdx
	movq	module(%rip), %rax
	movl	$.LC8, %esi
	movq	%rax, %rdi
	call	rb_define_class_under
	movq	%rax, page_class(%rip)
	movq	page_class(%rip), %rax
	movl	$0, %ecx
	movl	$1, %edx
	movl	$.LC9, %esi
	movq	%rax, %rdi
	call	rb_define_attr
	movq	page_class(%rip), %rax
	movl	$0, %ecx
	movl	$1, %edx
	movl	$.LC10, %esi
	movq	%rax, %rdi
	call	rb_define_attr
	movq	page_class(%rip), %rax
	movl	$0, %ecx
	movl	$initialize, %edx
	movl	$.LC11, %esi
	movq	%rax, %rdi
	call	rb_define_method
	movq	page_class(%rip), %rax
	movl	$0, %ecx
	movl	$acquire, %edx
	movl	$.LC12, %esi
	movq	%rax, %rdi
	call	rb_define_method
	movq	page_class(%rip), %rax
	movl	$0, %ecx
	movl	$release, %edx
	movl	$.LC13, %esi
	movq	%rax, %rdi
	call	rb_define_method
	movq	page_class(%rip), %rax
	movl	$1, %ecx
	movl	$check_impl, %edx
	movl	$.LC14, %esi
	movq	%rax, %rdi
	call	rb_define_method
	movq	page_class(%rip), %rax
	movl	$1, %ecx
	movl	$fill_impl, %edx
	movl	$.LC15, %esi
	movq	%rax, %rdi
	call	rb_define_method
	movq	page_class(%rip), %rax
	movl	$1, %ecx
	movl	$get, %edx
	movl	$.LC16, %esi
	movq	%rax, %rdi
	call	rb_define_method
	movq	page_class(%rip), %rax
	movl	$2, %ecx
	movl	$set, %edx
	movl	$.LC17, %esi
	movq	%rax, %rdi
	call	rb_define_method
	movq	module(%rip), %rax
	movl	$4, %ecx
	movl	$rb_hammer, %edx
	movl	$.LC18, %esi
	movq	%rax, %rdi
	call	rb_define_module_function
	movq	module(%rip), %rax
	movl	$2, %ecx
	movl	$rb_access_time, %edx
	movl	$.LC19, %esi
	movq	%rax, %rdi
	call	rb_define_module_function
	movq	module(%rip), %rax
	movl	$1, %ecx
	movl	$bit_ffs, %edx
	movl	$.LC20, %esi
	movq	%rax, %rdi
	call	rb_define_module_function
	movq	module(%rip), %rax
	movl	$1, %ecx
	movl	$bit_clz, %edx
	movl	$.LC21, %esi
	movq	%rax, %rdi
	call	rb_define_module_function
	movq	module(%rip), %rax
	movl	$0, %ecx
	movl	$rb_mem_size, %edx
	movl	$.LC22, %esi
	movq	%rax, %rdi
	call	rb_define_module_function
	movq	module(%rip), %rax
	movl	$0, %ecx
	movl	$rb_get_cpu_freq, %edx
	movl	$.LC23, %esi
	movq	%rax, %rdi
	call	rb_define_module_function
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE43:
	.size	Init_RHUtils, .-Init_RHUtils
	.ident	"GCC: (GNU) 5.1.1 20150618 (Red Hat 5.1.1-4)"
	.section	.note.GNU-stack,"",@progbits
