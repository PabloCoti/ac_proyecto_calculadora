; creador

SECTION .data

SECTION .bss

SECTION .text


; create a file with the name on eax -> return descriptor en eax
create_file:
    .backup:                ; data backup
        push        ebx
        push        ecx
        push        esi
    ; create file
    mov     ecx, 0755o      ; rw permisions
    mov     ebx, eax        ; ebx = filename
    mov     eax, 8          ; SYS_CREATE
    int     80h             ; kernel

    mov esi, eax            ; esi -> descriptor

    mov ebx, esi            ; ebx -> esi
    mov eax, 6              ; SYS_CLOSE
    int 80H                 ; kernel

    .restore:               ; data restore
        pop         ebx
        pop         ecx
        pop         esi

    ret

; open a file, send on eax where to save the result
; return descriptor en eax
read_file:
    .backup:
        push    edx
        push    ecx
        push    ebx
        push    edi
        push    esi
        push    eax
    
    ; open file
    mov     edi, esi        ; end stack -> stack begin

    mov     ecx, 0          ; flag READ ONLY
    mov     ebx, edi        ; ebx -> end of stack
    mov     eax, 5          ; SYS_OPEN
    int     80H

    ; save descriptor on esi
    mov     esi, eax         ; eax -> descriptor

    ; TODO calc edx dynamically
    ; read a line from the file
    mov     edx, 256         ; max length = 256
    pop     eax
    mov     ecx, eax         ; ecx -> expression buffer
    mov     ebx, esi         ; ebx = file path on esi
    mov     eax, 3           ; SYS_READ
    int     80H              ; kernel

    ; close file
    mov     ebx, esi         ; ebx = esi
    mov     eax, 6           ; SYS_CLOSE
    int     80H

    .restore:
        pop     esi
        pop     edi
        pop     ebx
        pop     ecx
        pop     edx
    ret

; eax = filepath -> return eax : descriptor
append_file:
    .backup:
        push    ecx
        push    ebx
    
    mov     ecx, 0777       ; W permision
    mov     ebx, eax        ; ebx = filename
    mov     eax, 8          ; SYS_CREATE
    int     80H

    .restore:
        pop     ebx
        pop     ecx
    ret