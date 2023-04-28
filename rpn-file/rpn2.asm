; la aplicacion maneja numeros negativos, sin embargo, al enviar numeros
; negativos como parametros, tiende a buguearse JAJAJ, asi que si mandamos
; 1 2 - 3 + funcina bien, pero al enviar 1 -2 - 3 + geenra errores con el -2, a veces lo maneja como 2
; usa las llamada de este link: https://faculty.nps.edu/cseagle/assembly/sys_call.html

%include    '../utils/stdio32.asm'
%include    '../utils/string.asm'
%include    '../utils/print_float.asm'
%include    '../utils/filetdio.asm'
%include    'calc/calc_struct.asm'

section .data
    emsg            db      10, 'Contenido en el archivo fuente: ', 10, 0
    rmsg            db      10, 'Contenido escrito en el archivo de resultados: ', 10, 0
    newline         db      10, 0
    myfloat         dd      0
    entryfile       db      'files/entry.txt', 0
    resultfile      db      'result.txt', 0

section .bss

section .text
    global          _start

_start:
    ; section to get parametres and execute
    pop         eax
    cmp         eax, 2
    jne         setfile

    mov esi,    dword [esp + 4]
    jmp         go

setfile:
    mov         esi, entryfile

go:
    call        read_file_c_str

    mov         eax, emsg               
    call        println             

    call        create_file_c_str

    mov         eax, expressions
    call        println

    mov         eax, rmsg
    call        println

    call        exec_calc

    call        sys_exit
