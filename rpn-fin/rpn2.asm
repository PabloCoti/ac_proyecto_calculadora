%include    '../utils/stdio32.asm'
%include    '../utils/string.asm'
%include    '../utils/print_float.asm'
%include    'calc/calc_struct.asm'

section .data

errMsg      db  10, "No se ha pogramado esto :c no le se a ensambador", 10, 0
rmsg        db  10, 'Resultado/os: ', 0
newline     db  10, 0
myfloat     dd  0
entryfile   db  'entry.txt', 0
resultfile  db  'result.txt', 0

section .bss
expressions resb  256
stack       resd  25
content     resb  256

fd_out      resb 1
fd_in       resb 1

section .text
    global _start

_start:
    pop eax
    cmp eax, 1
    je  .invalid
    cmp eax, 2
    jne set_file

    mov esi, dword [esp + 4]
    jmp go
    .invalid:
        mov     eax, errMsg
        call    println
    .exit:
        call    sys_exit

set_file:
    mov esi, esp
    add esi, 4
    mov edi, expressions
    dec eax
    call copy_to_expression
        
    jmp skip_file

go:
    call read_file_inp
    call create_file_new

skip_file:

    mov eax, rmsg
    call println

    call calculateResults

    jmp  _start.exit

