echo "DELETE FILES"
rm rpn2.exe rpn2.o result.txt
echo "COMPILING rpn2.ASM.."
nasm -f elf rpn2.asm
echo "CREATING OBJECT..."
ld -m elf_i386 rpn2.o -o rpn2.e
echo "EXECUING... ./rpn2.exe entry.txt"
./rpn2.e files/entry.txt
#echo "EXECUING... ./rpn2.exe math.txt"
#./rpn2.exe files/math.txt
