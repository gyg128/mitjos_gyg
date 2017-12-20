# protectedkernelconsole
#
#display a string in two modes:
#in real mode
#in protected mode

cmd:
make clean
make
make run

make:
gcc -pipe  -nostdinc -m32 -Os -fno-builtin -I. -fno-tree-ch -fno-stack-protector -gstabs  -Wall -Wno-unused -Werror -Wno-format  -c -o boot.o boot.S
gcc -pipe  -nostdinc -m32 -Os -fno-builtin -I. -fno-tree-ch -fno-stack-protector -gstabs  -Wall -Wno-unused -Werror -Wno-format  -c -o main.o main.c
ld -m elf_i386 -N -e start -Ttext 0x7C00 -o boot.out boot.o main.o
objdump -S boot.out >boot.asm
objcopy -S -O binary -j .text boot.out boot
#objcopy -S -O binary -j .text -j .data boot.out boot
perl sign.pl boot
boot block is 463 bytes (max 510)
gcc -pipe  -nostdinc -m32 -Os -fno-builtin -I. -fno-tree-ch -fno-stack-protector -gstabs  -Wall -Wno-unused -Werror -Wno-format  -c -o kern/entry.o kern/entry.S
gcc -pipe  -nostdinc -m32 -Os -fno-builtin -I. -fno-tree-ch -fno-stack-protector -gstabs  -Wall -Wno-unused -Werror -Wno-format  -c -o kern/entrypgdir.o kern/entrypgdir.c
gcc -pipe  -nostdinc -m32 -Os -fno-builtin -I. -fno-tree-ch -fno-stack-protector -gstabs  -Wall -Wno-unused -Werror -Wno-format  -c -o kern/init.o kern/init.c
ld -o kern/kernel -m elf_i386 -T kern/kernel.ld -nostdlib kern/entry.o kern/entrypgdir.o kern/init.o /usr/lib/gcc/i686-linux-gnu/5/libgcc.a -b binary 
dd if=/dev/zero of=./.bochs.img~ count=10000 2>/dev/null
dd if=./boot of=./.bochs.img~ conv=notrunc 2>/dev/null
dd if=./kern/kernel of=./.bochs.img~ seek=1 conv=notrunc 2>/dev/null
mv ./.bochs.img~ ./bochs.img

