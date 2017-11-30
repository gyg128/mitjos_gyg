
boot.out：     文件格式 elf32-i386


Disassembly of section .text:

00007c00 <start>:
.set CR0_PE_ON,      0x1         # protected mode enable flag

.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
    7c00:	fa                   	cli    
  cld                         # String operations increment
    7c01:	fc                   	cld    

  xorw    %ax,%ax             # Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             # initiate Data Segment ax->ds
    7c04:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             # Extra Segment
    7c06:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             # Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

  movw    $0xb800,%ax		#display msg1 directly in read mode
    7c0a:	b8 00 b8 8e c0       	mov    $0xc08eb800,%eax
  movw    %ax,%es
  movw    $msg1,%si			#"in real mode  "
    7c0f:	be 96 7c bf e2       	mov    $0xe2bf7c96,%esi
  movw    $0xbe2,%di
    7c14:	0b b9 04 00 f3 a4    	or     -0x5b0cfffc(%ecx),%edi
  movw    $4,%cx
  rep     movsb

  movw    $hellostring,%si
    7c1a:	be 9e 7c bf 04       	mov    $0x4bf7c9e,%esi
  movw    $0xc04,%di
    7c1f:	0c b9                	or     $0xb9,%al
  movw    $4,%cx
    7c21:	04 00                	add    $0x0,%al
  rep     movsb               # print "hello world" in real mode
    7c23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)

00007c25 <seta20.1>:

seta20.1: # to enable a20
	#read a byte from prort 0x64
  inb     $0x64,%al               # Wait 8042 keyboard for not busy
    7c25:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c27:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    7c29:	75 fa                	jne    7c25 <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    7c2b:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    7c2d:	e6 64                	out    %al,$0x64

00007c2f <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait 8042 keyboard for not busy
    7c2f:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c31:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    7c33:	75 fa                	jne    7c2f <seta20.2>

	#enable a20
  movb    $0xdf,%al               # 0xdf -> port 0x60
    7c35:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    7c37:	e6 60                	out    %al,$0x60

#lgdtload:
  lgdt    gdtdesc
    7c39:	0f 01 16             	lgdtl  (%esi)
    7c3c:	90                   	nop
    7c3d:	7c 0f                	jl     7c4e <protcseg+0x1>
  movl    %cr0, %eax
    7c3f:	20 c0                	and    %al,%al
  orl     $CR0_PE_ON, %eax
    7c41:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    7c45:	0f 22 c0             	mov    %eax,%cr0
 
  ljmp    $PROTECT_MODE_CSEG, $protcseg
    7c48:	ea                   	.byte 0xea
    7c49:	4d                   	dec    %ebp
    7c4a:	7c 08                	jl     7c54 <protcseg+0x7>
	...

00007c4d <protcseg>:

  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROTECT_MODE_DSEG, %ax    
    7c4d:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # initiate Data Segment
    7c51:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # Extra Segment
    7c53:	8e c0                	mov    %eax,%es
  movw    %ax, %fs                # 
    7c55:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # 
    7c57:	8e e8                	mov    %eax,%gs
  movw    %ax, %ss                # Stack Segment
    7c59:	8e d0                	mov    %eax,%ss

  movl    $msg2,%esi
    7c5b:	be 9a 7c 00 00       	mov    $0x7c9a,%esi
  movl    $0xb8d22,%edi
    7c60:	bf 22 8d 0b 00       	mov    $0xb8d22,%edi
  movl    $8,%ecx
    7c65:	b9 08 00 00 00       	mov    $0x8,%ecx
  rep     movsb               #print "hello world" in protected mode
    7c6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)

#Set up the stack pointer and call into C
  movl   $start, %esp
    7c6c:	bc 00 7c 00 00       	mov    $0x7c00,%esp
  call bootmain
    7c71:	e8 d7 00 00 00       	call   7d4d <bootmain>

00007c76 <spin>:
 
#loop forver
spin:
  jmp spin
    7c76:	eb fe                	jmp    7c76 <spin>

00007c78 <gdt>:
	...
    7c80:	ff                   	(bad)  
    7c81:	ff 00                	incl   (%eax)
    7c83:	00 00                	add    %al,(%eax)
    7c85:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c8c:	00                   	.byte 0x0
    7c8d:	92                   	xchg   %eax,%edx
    7c8e:	cf                   	iret   
	...

00007c90 <gdtdesc>:
    7c90:	17                   	pop    %ss
    7c91:	00 78 7c             	add    %bh,0x7c(%eax)
	...

00007c96 <msg1>:
    7c96:	72 07                	jb     7c9f <hellostring+0x1>
    7c98:	3a 07                	cmp    (%edi),%al

00007c9a <msg2>:
    7c9a:	70 07                	jo     7ca3 <waitdisk+0x1>
    7c9c:	3a 07                	cmp    (%edi),%al

00007c9e <hellostring>:
    7c9e:	68                   	.byte 0x68
    7c9f:	0f                   	.byte 0xf
    7ca0:	69                   	.byte 0x69
    7ca1:	0c                   	.byte 0xc

00007ca2 <waitdisk>:
	}
}

void
waitdisk(void)
{
    7ca2:	55                   	push   %ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7ca3:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7ca8:	89 e5                	mov    %esp,%ebp
    7caa:	ec                   	in     (%dx),%al
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
    7cab:	83 e0 c0             	and    $0xffffffc0,%eax
    7cae:	3c 40                	cmp    $0x40,%al
    7cb0:	75 f8                	jne    7caa <waitdisk+0x8>
		/* do nothing */;
}
    7cb2:	5d                   	pop    %ebp
    7cb3:	c3                   	ret    

00007cb4 <readsect>:

void
readsect(void *dst, uint32_t offset)
{
    7cb4:	55                   	push   %ebp
    7cb5:	89 e5                	mov    %esp,%ebp
    7cb7:	57                   	push   %edi
    7cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// wait for disk to be ready
	waitdisk();
    7cbb:	e8 e2 ff ff ff       	call   7ca2 <waitdisk>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7cc0:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7cc5:	b0 01                	mov    $0x1,%al
    7cc7:	ee                   	out    %al,(%dx)
    7cc8:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7ccd:	88 c8                	mov    %cl,%al
    7ccf:	ee                   	out    %al,(%dx)
    7cd0:	89 c8                	mov    %ecx,%eax
    7cd2:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7cd7:	c1 e8 08             	shr    $0x8,%eax
    7cda:	ee                   	out    %al,(%dx)
    7cdb:	89 c8                	mov    %ecx,%eax
    7cdd:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7ce2:	c1 e8 10             	shr    $0x10,%eax
    7ce5:	ee                   	out    %al,(%dx)
    7ce6:	89 c8                	mov    %ecx,%eax
    7ce8:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7ced:	c1 e8 18             	shr    $0x18,%eax
    7cf0:	83 c8 e0             	or     $0xffffffe0,%eax
    7cf3:	ee                   	out    %al,(%dx)
    7cf4:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cf9:	b0 20                	mov    $0x20,%al
    7cfb:	ee                   	out    %al,(%dx)
	outb(0x1F5, offset >> 16);
	outb(0x1F6, (offset >> 24) | 0xE0);
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();
    7cfc:	e8 a1 ff ff ff       	call   7ca2 <waitdisk>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
    7d01:	8b 7d 08             	mov    0x8(%ebp),%edi
    7d04:	b9 80 00 00 00       	mov    $0x80,%ecx
    7d09:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7d0e:	fc                   	cld    
    7d0f:	f2 6d                	repnz insl (%dx),%es:(%edi)

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
    7d11:	5f                   	pop    %edi
    7d12:	5d                   	pop    %ebp
    7d13:	c3                   	ret    

00007d14 <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
    7d14:	55                   	push   %ebp
    7d15:	89 e5                	mov    %esp,%ebp
    7d17:	57                   	push   %edi
    7d18:	56                   	push   %esi

	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7d19:	8b 7d 10             	mov    0x10(%ebp),%edi

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
    7d1c:	53                   	push   %ebx
	uint32_t end_pa;

	end_pa = pa + count;
    7d1d:	8b 75 0c             	mov    0xc(%ebp),%esi

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
    7d20:	8b 5d 08             	mov    0x8(%ebp),%ebx

	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7d23:	c1 ef 09             	shr    $0x9,%edi
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
	uint32_t end_pa;

	end_pa = pa + count;
    7d26:	01 de                	add    %ebx,%esi

	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7d28:	47                   	inc    %edi
	uint32_t end_pa;

	end_pa = pa + count;

	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);
    7d29:	81 e3 00 fe ff ff    	and    $0xfffffe00,%ebx
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
    7d2f:	39 f3                	cmp    %esi,%ebx
    7d31:	73 12                	jae    7d45 <readseg+0x31>
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
    7d33:	57                   	push   %edi
    7d34:	53                   	push   %ebx
		pa += SECTSIZE;
		offset++;
    7d35:	47                   	inc    %edi
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
		pa += SECTSIZE;
    7d36:	81 c3 00 02 00 00    	add    $0x200,%ebx
	while (pa < end_pa) {
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
    7d3c:	e8 73 ff ff ff       	call   7cb4 <readsect>
		pa += SECTSIZE;
		offset++;
    7d41:	58                   	pop    %eax
    7d42:	5a                   	pop    %edx
    7d43:	eb ea                	jmp    7d2f <readseg+0x1b>
	}
}
    7d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d48:	5b                   	pop    %ebx
    7d49:	5e                   	pop    %esi
    7d4a:	5f                   	pop    %edi
    7d4b:	5d                   	pop    %ebp
    7d4c:	c3                   	ret    

00007d4d <bootmain>:

//global data: error :beyond 512 bytes for boot
//char msg3[]={'H',0xc,'i',0xc,' ',0xc,'A',0xc,'l',0xc,'b',0xc,'e',0xc,'r',0xc,'t',0xc,'!',0xc};
void
bootmain(void)
{
    7d4d:	55                   	push   %ebp
    7d4e:	89 e5                	mov    %esp,%ebp
    7d50:	56                   	push   %esi
    7d51:	53                   	push   %ebx
	////msg3 in stack: ok
	char msg3[]={'P',0x7,'2',0x7};
	struct Proghdr *ph, *eph;
	__asm __volatile("movl %0,%%esi\n\tmovl $0xb8d32,%%edi\n\tmovl $4,%%ecx\n\t rep movsb"::"r"(msg3));
    7d52:	8d 45 f4             	lea    -0xc(%ebp),%eax

//global data: error :beyond 512 bytes for boot
//char msg3[]={'H',0xc,'i',0xc,' ',0xc,'A',0xc,'l',0xc,'b',0xc,'e',0xc,'r',0xc,'t',0xc,'!',0xc};
void
bootmain(void)
{
    7d55:	83 ec 10             	sub    $0x10,%esp
	////msg3 in stack: ok
	char msg3[]={'P',0x7,'2',0x7};
    7d58:	c6 45 f4 50          	movb   $0x50,-0xc(%ebp)
    7d5c:	c6 45 f5 07          	movb   $0x7,-0xb(%ebp)
    7d60:	c6 45 f6 32          	movb   $0x32,-0xa(%ebp)
    7d64:	c6 45 f7 07          	movb   $0x7,-0x9(%ebp)
	struct Proghdr *ph, *eph;
	__asm __volatile("movl %0,%%esi\n\tmovl $0xb8d32,%%edi\n\tmovl $4,%%ecx\n\t rep movsb"::"r"(msg3));
    7d68:	89 c6                	mov    %eax,%esi
    7d6a:	bf 32 8d 0b 00       	mov    $0xb8d32,%edi
    7d6f:	b9 04 00 00 00       	mov    $0x4,%ecx
    7d74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)

	// read 1st page off disk
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);
    7d76:	6a 00                	push   $0x0
    7d78:	68 00 10 00 00       	push   $0x1000
    7d7d:	68 00 00 01 00       	push   $0x10000
    7d82:	e8 8d ff ff ff       	call   7d14 <readseg>

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
    7d87:	83 c4 0c             	add    $0xc,%esp
    7d8a:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d91:	45 4c 46 
    7d94:	75 37                	jne    7dcd <bootmain+0x80>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d96:	a1 1c 00 01 00       	mov    0x1001c,%eax
	eph = ph + ELFHDR->e_phnum;
    7d9b:	0f b7 35 2c 00 01 00 	movzwl 0x1002c,%esi
	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7da2:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;
    7da8:	c1 e6 05             	shl    $0x5,%esi
    7dab:	01 de                	add    %ebx,%esi
	for (; ph < eph; ph++)
    7dad:	39 f3                	cmp    %esi,%ebx
    7daf:	73 16                	jae    7dc7 <bootmain+0x7a>
		// p_pa is the load address of this segment (as well
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
    7db1:	ff 73 04             	pushl  0x4(%ebx)
    7db4:	ff 73 14             	pushl  0x14(%ebx)
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
    7db7:	83 c3 20             	add    $0x20,%ebx
		// p_pa is the load address of this segment (as well
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
    7dba:	ff 73 ec             	pushl  -0x14(%ebx)
    7dbd:	e8 52 ff ff ff       	call   7d14 <readseg>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
    7dc2:	83 c4 0c             	add    $0xc,%esp
    7dc5:	eb e6                	jmp    7dad <bootmain+0x60>
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry))();
    7dc7:	ff 15 18 00 01 00    	call   *0x10018
    7dcd:	eb fe                	jmp    7dcd <bootmain+0x80>
