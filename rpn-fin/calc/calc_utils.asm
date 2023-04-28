copy_to_expression:
    pusha

    mov ecx, eax

    .merge:
        push ecx
        push esi

        mov eax, [esi]
        call strLen

        mov esi, [esi]
        mov ecx, eax
        cld
        rep movsb

        pop esi

        add esi, 4
        add edi, ecx

        mov byte [edi], ' '
        add edi, 1

        pop ecx
        loop .merge

        popa
    ret

calculateResults:
    pusha

    mov esi, expressions

owhile:
    mov edi, stack
    .iwhile:
        cmp byte [esi], 10
        je .idone
        cmp byte [esi], 0
        je .odone

        mov eax, 0
        mov ebx, 0
    .readNum:
        mov bl, byte [esi]

        cmp bl, '0'
        jl .ioperators

        cmp bl, '9'
        jg .inext

        sub ebx, 48

        mov ecx, 10
        mul ecx
        add eax, ebx

        cmp byte [esi+1], '0'
        jl .saveNum

        cmp byte [esi+1], '9'
        jg .saveNum

        inc esi
        jmp .readNum

    .saveNum:
        mov dword [myfloat], eax

        fild dword [myfloat]

        fstp dword [edi]
        add edi, 4

        jmp .inext

    .ioperators:

        cmp bl, '+'
        je .addition

        cmp bl, '-'
        je .subtraction

        cmp bl, 'x'
        je .multiplication

        cmp bl, '/'
        je .division

        jmp .inext

    .addition:
        
        sub edi, 8

        fld dword [edi]
        add edi, 4
        fld dword [edi]
        add edi, 4

        sub edi, 8

        faddp st1, st0

        fstp dword [edi]
        add edi, 4

        jmp .inext

    .subtraction:

        sub edi, 8

        fld dword [edi]
        add edi, 4
        fld dword [edi]
        add edi, 4
        
        sub edi, 8

        fsubp st1, st0

        fstp dword [edi]
        add edi, 4

        jmp .inext

    .multiplication:

        sub edi, 8

        fld dword [edi]
        add edi, 4
        fld dword [edi]
        add edi, 4
        
        sub edi, 8

        fmulp st1, st0

        fstp dword [edi]
        add edi, 4

        jmp .inext

    .division:

        sub edi, 8

        fld dword [edi]
        add edi, 4
        fld dword [edi]
        add edi, 4
        
        sub edi, 8

        fdivp st1, st0

        fstp dword [edi]
        add edi, 4

        jmp .inext

    .inext:
        inc esi
        jmp .iwhile

    .idone:
        inc esi

    .odone:
        sub edi, 4

        pusha

        fld dword [edi]
        mov edi, dec_str
        call double2dec

        mov eax,4                   ; Kernel function sys-out
        mov ebx,1                   ; Stdout
        mov ecx, dec_str             ; Pointer to string
        mov edx, edi                ; EDI points to the null-termination of the string
        sub edx, dec_str            ; Length of the string
        int 0x80                    ; Call kernel

        mov edi, edx
        call wirte_file_res

        mov eax,4                   ; Kernel function sys-out
        mov ebx,1                   ; Stdout
        mov ecx, newline
        mov edx, 2
        int 0x80

        popa


    cmp byte [esi], 0
    jne owhile

    popa
    ret