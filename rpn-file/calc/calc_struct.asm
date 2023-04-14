; BIBLIO
; - https://www.nasm.us/xdoc/2.16.01/html/nasmdoc1.html
; - https://stackoverflow.com/questions/tagged/nasm
; - https://chat.openai.com/

%include        'calc/calc_utils.asm'

section .bss
    expressions     resb    256
    stack           resd    25
    content         resb    256

    fd_out          resb 1
    fd_in           resb 1

SECTION .text
; ------------------------------------------ ;
;           ACTIONS FOR CALCULATOR           ;
; ------------------------------------------ ;

exec_calc:
    pusha

    mov         esi, expressions            ; read sorted expressions

    .owhile:                                ; while loop
        mov         edi, stack              ; edi -> variables stack
        .iwhile:                            ; while into while
            cmp         byte [esi], 10      ; ASCII(LF) -> end of line
            je          .idone
            cmp         byte [esi], 0H      ; null?
            je          .odone

            mov         eax, 0H             ; eax = null
            mov         ebx, 0H             ; eax = null
    .read_num:
        mov         bl, byte [esi]          ; save data on esi on ebx

        ; check if actual value is a number
        cmp         bl, '0'                 
        jl          .ioperators             ; < ASCII(0) -> number or invalid
        cmp         bl, '9'                 ; > ASCII(9) -> ignore value
        jg          .inext                  ; TODO display error

        sub         ebx, 48                 ; ASCII(number) -> number

        mov         ecx, 10                 ; global decimal divisor
        mul         ecx                     ; eax = eax * ebx
        add         eax, ebx                ; eax = eax + ebx

        cmp         byte [esi+1], '0'       ; check if number
        jl          .save_num               ; save number if lower to ASCII(0)

        cmp         byte [esi+1], '9'       ; check if number
        jg          .save_num               ; save number if higher than ASCII(9)

        inc         esi                     ; next arg
        jmp         .read_num               ; loop.next

    .save_num:                              ; save int.valueOf(ASCII(number))
        mov         dword [myfloat], eax    ; tmp save of value on myfloat
        ; flaoting point to integer
        fild        dword [myfloat]         ; FPU function https://github.com/netwide-assembler/nasm
        ; store floating point and pop
        fstp        dword [edi]             ; save float and pop
        add         edi, 4                  ; stack.next
        jmp         .inext                  ; loop.next

    .ioperators:                            ; check operations
        cmp         bl, '+'
        je          .addition
        cmp         bl, '-'
        je          .subtraction
        cmp         bl, '*'
        je          .multiplication
        cmp         bl, '/'
        je          .division
        jmp         .inext                  ; default

    .addition:
        call        op_add
        jmp         .inext
    .subtraction:
        call        op_sub
        jmp         .inext
    .multiplication:
        call        op_mul
        jmp         .inext
    .division:
        call        op_div
        jmp         .inext
    .inext:
        inc         esi
        jmp         .iwhile
    .idone:
        inc         esi
    .odone:
        sub         edi, 4

        pusha

        fld         dword [edi]
        mov         edi, dec_str            ; edi -> decimal string
        call        double2dec              ; double to decimal

        mov         eax,4                   ; Kernel function sys-out
        mov         ebx,1                   ; Stdout
        mov         ecx, dec_str            ; Pointer to string
        mov         edx, edi                ; EDI points to the null-termination of the string
        sub         edx, dec_str            ; Length of the string
        int         0x80                    ; Call kernel

        ; write file and print jumpline
        mov         edi, edx
        call        writeFile
        mov         eax, newline
        call        print

        popa


    cmp             byte [esi], 0           ; no more values on stack
    jne             .owhile

    popa
    ret

writeFile:
    pusha

    call        save_file_content_c_str ; save current data of result file
    call        append_file_str         ; update data of result file
    mov         esi, eax                ; esi -> descriptor
    mov         eax, content            ; eax -> file content
    call        strLen                  ; eax = eax.length
    mov         edx, eax                ; edx -> eax

    mov         eax, 4
    mov         ebx, esi
    mov         ecx, content
    mov         edx, edx
    int         80H

    cmp         edx, 0
    je          skipnewline

    mov         eax, 4
    mov         ebx, esi
    mov         ecx, newline
    mov         edx, 1
    int         80H

skipnewline:

    mov         eax, 4
    mov         ebx, esi
    mov         ecx, dec_str
    mov         edx, edi
    int         80H

    mov         eax, 6
    mov         ebx, esi
    int         80H

    popa
    ret