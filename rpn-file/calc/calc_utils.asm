; operaciones matematicas, esta es una clase, la tengo aparte como si fuera
; una hoja de PHP, solo para que sea mas comodo de leer y no este todo amontonado
; en un unico archivo

op_add:
   sub         edi, 8
   fld         dword [edi]
   add         edi, 4
   fld         dword [edi]
   add         edi, 4
   sub         edi, 8
   faddp       st1, st0
   fstp        dword [edi]
   add         edi, 4
   ret
op_sub:
   sub         edi, 8
   fld         dword [edi]
   add         edi, 4
   fld         dword [edi]
   add         edi, 4
   
   sub         edi, 8
   fsubp       st1, st0
   fstp        dword [edi]
   add         edi, 4
   ret
op_mul:
   sub         edi, 8
   fld         dword [edi]
   add         edi, 4
   fld         dword [edi]
   add         edi, 4
   
   sub         edi, 8
   fmulp       st1, st0
   fstp        dword [edi]
   add         edi, 4
   ret
op_div:
   sub         edi, 8
   fld         dword [edi]
   add         edi, 4
   fld         dword [edi]
   add         edi, 4
   
   sub         edi, 8
   fdivp       st1, st0
   fstp        dword [edi]
   add         edi, 4
   ret


; ------------------------------------------ ;
;             ACTIONS FOR RESULTS            ;
; ------------------------------------------ ;

; save the content onto file and return descriptor on eax
save_file_content_c_str:
   .backup:
      push     ebx
    ; open the file

    mov     eax, content    ; eax -> content
    mov     ebx, resultfile ; eax -> result file
    call    save_to_content      ; write ebx onto eax file

   .restore:
      pop      ebx
    ret

; create a file and return descriptor on eax
create_file_c_str:
    mov     eax, resultfile
    call    create_file
    ret

; append data and return descriptor on eax
append_file_str:
   mov      eax, resultfile
   call     append_file
   ret

; read the file onto eax and return the data on eax
read_file_c_str:
    pusha

    mov     eax, expressions
    call    read_file

    popa
    ret

; escribe la informacion de eax en el archivo ebx
; eax = content
; ebx = file name
; return descriptor en eax
save_to_content:
    .backup:
        push    edx
        push    ecx
        push    ebx

    ; open file
    mov         ecx, 0       ; flag READ_ONLY
    mov         ebx, ebx     ; ebx = filename
    mov         eax, 5       ; SYS_OPEN
    int         80H          ; kernel

    mov         esi, eax     ; esi -> descriptor

    ; TODO      calc length
    ; overwrite file
    mov         edx, 256     ; max_lenght to write
    mov         ecx, content ; ecx = content to write
    mov         ebx, esi     ; ebx -> descriptor
    mov         eax, 3       ; SYS_READ
    int         80H          ; kernel

    ; close the file
    mov         ebx, esi     ; ebx -> descriptor
    mov         eax, 6       ; SYS_CLOSE
    int         80H

    .restore:
        pop     ebx
        pop     ecx
        pop     edx
    ret