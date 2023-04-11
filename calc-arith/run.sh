echo "COMPILANDO .ASM"
nasm -f elf calc.asm
echo "CREANDO OBJETO"
ld -m elf_i386 calc.o -o calc.e
echo "EJECUTA LA APP CON ./calc NUM OP NUM"
./calc.e 12 / 8
