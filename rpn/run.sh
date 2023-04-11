echo "COMPILANDO .ASM"
nasm -f elf rpn.asm
echo "CREANDO OBJETO"
ld -m elf_i386 rpn.o -o rpn
echo "EJECUTA LA APP CON ./rpn <INSTRUC>"
./rpn 12 5 3 1 0 - + / x