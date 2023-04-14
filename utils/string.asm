; Clase que contiene funciones relacionadas con los strings
; creador: @daniel-baf
; fecha: 19 de marzo del 2023
; ultima actualización: 10 de marzo del 2023

SECTION .data

SECTION .bss
    str_input_1:    resb        125         ; max input entry
    str_input_2:    resb        130         ; max input entry
    str_concat:     resb        255         ; 255 bytes + 1 null

SECTION .text
; ------------------------------------------ ;
;           TO UPPER CASE STRING             ;
; ------------------------------------------ ;
toUpperCase:
    push        eax                     ; backup of input
    push        ebx                     ; backup
    mov         ebx, eax                ; save on ebx the pointer to eax
    toUpperLoop:
        cmp         byte[ebx], 0            ; is null? the byte at ebx
        jz          toUpperLoopEnd          ; end of loop, jump to

        ; check if the actual byte correspond to a a-z char
        cmp         byte[ebx], 97           ; is byte lower than 'a'
        jl          toUpperLoopContinue     ; not a-z, do not change
        cmp         byte[ebx], 122          ; is byte higher than 'z'
        jg          toUpperLoopContinue     ; not a-z, do not change
        ; is into range [a,z]
        mov         al, [ebx]               ; uses al to acces byte[]
        sub         al, 32                  ; a-z -> A-Z ASCII
        mov         byte[ebx], al           ; update value at byte[ebx]
        
        toUpperLoopContinue:
        inc         ebx                     ; ebx ++
        jmp         toUpperLoop             ; continue loop
    
    toUpperLoopEnd:

    ; restore values
    pop ebx
    pop eax
    
    ret

; ------------------------------------------ ;
;           TO LOWER CASE STRING             ;
; ------------------------------------------ ;
; convierte el valor de la cadena que venta en eax a minuscula
toLowerCase:
    push        eax
    push        ebx
    mov         ebx, eax                ; copy

    toLowerLoop:
        cmp         byte[ebx], 0            ; is null?
        jz          toLowerLoopEnd
    
        ; SECCION de codigo que verifica que este en los parametros [A,Z]
        cmp         byte[ebx], 65           ; es menor que 'A'?
        jl          toLowerLoopContinue
        cmp         byte[ebx], 90          ; es mayor que 'Z'?
        jg          toLowerLoopContinue
    
        ; esta en el rango [A,Z]
        mov         al, [ebx]
        add         al, 32
        mov         byte[ebx], al
    
        toLowerLoopContinue:
        inc         ebx                     ; ebx ++
        jmp         toLowerLoop

    toLowerLoopEnd:
    pop ebx
    pop eax
    
    ret

; ------------------------------------------ ;
;               CONCAT STRING                ;
; ------------------------------------------ ;
concat_str:
    ; backup
    push        ecx
    push        esi
    push        edi

    concat_str_copy_data:
        ; copaimos el contenido de eax en str_input_2
        mov         esi, eax            ; esi -> buffer
        mov         edi, str_input_1    ; edi -> str_input_1
        push        eax
        call        strLen; calculamos longitud de texto
        mov         ecx, eax            ; ecx = longitud cadena
        pop         eax 
        cld                             ; asegurarse de que el puntero de origen avance hacia adelante
        rep         movsb

        ; copaimos el contenido de eax en str_input_2
        mov         esi, ebx            ; esi -> buffer
        mov         edi, str_input_2    ; edi -> in_country
        push        eax
        call        strLen; calculamos longitud de texto
        mov         ecx, eax            ; ecx = longitud cadena
        pop         eax 
        cld                             ; asegurarse de que el puntero de origen avance hacia adelante
        rep         movsb

    ; concatenamos
    ; mover la primera cadena a la posicion de la cadena concatenada
    mov         esi, str_input_1            ; esi -> input 1
    mov         edi, str_concat             ; edi -> cadena concatenada
    cld
    ; calculos de offsets input 1
    mov         eax, str_input_1            ; eax -> input 1
    call        strLen                      ; eax = eax.length
    mov         ecx, eax                    ; ecx -> eax.length
    rep         movsb                       ; copia el contenido

    ; calculos de offset input 2
    ; mover la primera cadena a la posicion de la cadena concatenada
    mov         esi, str_input_2            ; esi -> input 2
    ; calculamos offset
    mov         eax, str_input_2            ; eax = input 2
    call        strLen                      ; eax = eax.length
    mov         ecx, str_concat             ; ecx -> str_concat
    add         ecx, eax                    ; ecx += str_input_2.length
    mov         edi, ecx       ; la seguna cadena empieza desde el offset de cadena 1 
    ; calculos de offset de input 2
    mov         eax, str_input_2            ; eax -> input 2
    call        strLen                      ; eax = eax.length
    inc         eax                         ; eax ++ por null
    mov         ecx, eax                    ; ecx -> eax.length = str_input2.length
    rep         movsb
    
    mov         eax, str_concat

    ; restore
    pop         edi
    pop         esi
    pop         ecx
    ret