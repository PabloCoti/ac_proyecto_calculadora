; recopilacion de funciones para el programa usando la entrada y salida
; estandar de la computadora
; creador: @daniel-baf
; fecha: 10 de marzo del 2023
; ultima actualización: 24 de marzo del 2023

SECTION .data
    ; variables usadas para goto_xy
    clear_str		db	    1Bh, '[2J', 1Bh, '[3J', 0h
	goto_xy_str	    db	    1Bh, '[01;01H', 0h
    ; variables usadas para imprimir con colores en ensamblador
    print_color_str_open    db      1BH, "[\x1b[31m", 0H ; cambia color
    print_color_str_close   db      1BH,"\x1b[0m", 0H  ; reinicia el de color
    ; variables usadasa para castear de int a string
    numb_div_base           dd      10
    msg_not_number          db      "El valor no contiene valores validos para numero", 0H

SECTION .bss
    buffer:         resb        255

SECTION .text
; ------------------------------------------ ;
;           TERMINA EL PROGRAMA              ;
; ------------------------------------------ ;
sys_exit:
    mov         ebx, 0      ; RETURN 0
    mov         eax, 1      ; SYS_EXIT
    int         80h         ; llamada a kernel
    ret

; ------------------------------------------ ;
;       CALCULO DE LONGITUD DE CADENA        ;
; ------------------------------------------ ;

; STRLEN = eax=<CADENA> eax.length -> <LONGITUD>
strLen:
    push        ebx             ; guardamos su valor en pila
    mov         ebx, eax        ; eax = ebx | ebx = dir en memoria de eax

    .next_char:
        cmp         byte[eax], 0            ; msg[eax] == 0 ?
        jz          .next_char_end          ; GOTO .next_char_end cuando no hayan mas chars
        inc         eax                     ; eax++ para loop
        jmp         .next_char              ; continua el loop

    .next_char_end:
    sub         eax, ebx                    ; longitud de la cadena = eax - ebx
    pop         ebx                         ; recupera el valor de ebx
    ret                                     ; fin de funcion

; ------------------------------------------ ;
;           IMPRESION EN PANTALLA            ;
; ------------------------------------------ ;

; imprime un string sin salto de linea
print:
    ; backup de los valores de los registros
    push        eax             ; recuperamos el valor al final
    push        edx
    push        ecx
    push        ebx
    push        eax             ; strLen modifica eax

    call        strLen          ; calculamos la longitud de la cadena
    mov         edx, eax        ; edx = eax, eax actualmente es la longitud
    pop         eax             ; recuperamos el valor a imprimir

    mov         ecx, eax        ; ecx -> apunta a dir de eax
    mov         ebx, 1          ; 1 = SALIDA EN PANTALLA
    mov         eax, 4          ; SYS_WRITE
    int         80h             ; llamada a interrupcion de sistema

    ; restauramos los valores
    pop         ebx
    pop         ecx
    pop         edx
    pop         eax             ; recuperamos el valor
    ret

; imprime una cadena con salto de linea
; void print(String toPrint)
println:
    call        print           ; imprime la cadena

    push        eax             ; backup
    mov         eax, 0AH        ; eax = \n
    push        eax             ; \n en pila
    mov         eax, esp        ; eax -> puntero de pila
    call        print           ; imprime \n

    pop         eax             ; borra \n
    pop         eax             ; recupera eax
    ret

; ------------------------------------------ ;
;       INGRESO DE VALOR POR CONSOLA         ;
; ------------------------------------------ ;

; lee un valor por consola hasta donde le den enter
readline:
    ; copia de seguridad
    push        edx
    push        ecx
    push        ebx

    ; Lee la entrada del usuario
    ; https://faculty.nps.edu/cseagle/assembly/sys_call.html
    mov         eax, 3          ; eax = no. de instruccion
    mov         ebx, 0          ; ebx = unsigned int
    mov         ecx, buffer     ; ecx = el buffer
    mov         edx, 255        ; edx = tamaño del buffer
    int         80H             ; llamada al sistema

    ; Busca el salto de línea en el buffer
    push        edi
    mov         edi, ecx            ; edi = dirección del buffer
    mov         ecx, eax            ; ecx = número de caracteres leídos
    xor         eax, eax            ; eax = contador de caracteres
    cld                             ; Dirección ascendente para repne scasb
    repne       scasb               ; Busca el salto de línea
    je          .replace_jumpline  ; Si se encontró el salto de línea, reemplaza con null byte

    ; Si no se encuentra el salto de línea, agrega un valor nulo al final de la entrada del usuario
    mov         byte [edi + ecx], 0H

    .replace_jumpline:
        mov         byte [edi + eax - 1], 0H     ; Reemplaza el salto de línea con null byte

    ; retornamos los vlores originales
    pop         edi
    pop         ebx
    pop         ecx
    pop         edx

    mov         eax, buffer                     ; devolvemos el valor en el buffer
    ret


; ------------------------------------------ ;
;       Impresion de numeros                 ;
; ------------------------------------------ ;

iPrintLn:
    call        iPrint      ; imprimimos el numero
    ; imprimimos el salto de linea
    push        eax

    mov         eax, 0AH    ;
    push        eax
    mov         eax, esp
    call        print
    pop         eax

    pop         eax
    ret                     ; regresamos a la funcion origen

; imprime un numero entero que este en eax
iPrint:
    ; backup de los registros
    push        eax
    push        ecx
    push        edx
    push        esi

    mov         ecx, 0      ; iniciamos el contador en 0
    .div_loop:
        inc         ecx         ; conteo de digitos
        mov         edx, 0      ; limpiar hsb de la division
        mov         esi, 10     ; esi [divisor] = 10
        idiv        esi         ; <edx:eax>/ esi
        add         edx, 48     ; + 0 int incial
        push        edx         ; residuo -> stack
        cmp         eax, 0      
        jnz         .div_loop

    ; fin .div_loop
    .print_loop:
        dec         ecx         ; decrementamos en la pila
        mov         eax, esp    ;
        call        print
        pop         eax         ; residuo ecx = eax
        cmp         ecx, 0      ; aun hay datos
        jnz         .print_loop ; saltamos

    ; restauramos valores
    pop         esi
    pop         edx
    pop         ecx
    pop         eax         ; 
    ret                     ; regresamos


; ------------------------------------------ ;
;               FUNCION GOTO                 ;
; ------------------------------------------ ;
; system.clear()
; print(cls)
clear_screen:
	mov	        eax, clear_str
	call	    print
	ret

; ah = x, al = y
goto_xy:
    mov	eax, goto_xy_str
	mov	ebx, eax
    .goto_xy_loop:
        cmp	byte [ebx], 0       ; revisamos si es null
    	jz	.goto_xy_loop_end
    	cmp	byte [ebx], '['
    	je	.goto_xy_set_x
    	cmp	byte [ebx], ';'
    	je	.goto_xy_set_y
    	inc	ebx
    	jmp	.goto_xy_loop
    .goto_xy_set_y:
	    add	ebx, 2
	    mov	byte [ebx], dl
	    jmp	.goto_xy_loop
    .goto_xy_set_x:
	    add	ebx, 2
	    mov 	byte [ebx], dh
	    jmp 	.goto_xy_loop
    .goto_xy_loop_end:
	    call	print
	    int	80h
    ret

; ------------------------------------------ ;
;               IMPRIMIR CON COLORES         ;
; ------------------------------------------ ;
; imprime de color el valor que venga en eax
print_color:
    push        eax     ; recuperado al final
    push        eax     ; usado en funcicon
    mov         eax, print_color_str_open
    call        print
    pop         eax
    call        print
    mov         eax, print_color_str_close
    call        println
    pop         eax
    ret

; ------------------------------------------ ;
;                   CASTEOS                  ;
; ------------------------------------------ ;

; eax = number as string
str_to_int:
    .backup:
        push        edx
        push        ecx
        push        ebx
        push        esi

    mov         ebx,0               ; acumulador
    mov         esi, eax            ; esi -> *eax, cadena

    .loop:
        movzx   edx, byte[esi]      ; cargar en edx el siguiente byte del string en cl
        cmp     dl, 0               ; fin de caneda?
        je      .done
        cmp     dl, 48              ; es menor a 0?
        jl      .invalid
        cmp     dl, 57              ; es mayor a 9?
        jg      .invalid

    
        sub     dl, 48              ; cl -= ASCII('0')
        imul    ebx, 10             ; multiplica el acumulador por 10
        add     ebx, edx            ; sumamos el valur numerico al acumulador

        inc     esi                 ; continuamos el loop
        jmp     .loop

    .invalid:
        push        eax
        mov         eax, msg_not_number
        call        println
        pop         eax

    .done:
        mov     eax, ebx
    
    .restore:
        pop     esi
        pop     ebx
        pop     ecx
        pop     edx
    ret

; eax = number as number -> eax as string
int_to_str:
    .backup:
        push        edx
        push        ecx
        push        ebx
        push        esi
    .start:
        mov         esi, buffer     ; guardamos los valores en el buffer
        xor         ecx, ecx        ; reiniciamos el contador
        
        .loop:
            cmp         eax, 0          ; numeros terminados
            jle         .invert         ; termina bucle

            xor         edx, edx        ; borramos el valor de la division

            mov         ebx, [numb_div_base]
            div         ebx

            .positionate:
                add         dl, 48
                mov         byte[esi], dl
                inc         esi

            jmp         .loop
        .invert:
            push        esi
            .calclen:   ; calculamos la longitud de la cadena
                mov         eax, buffer
                call        strLen
                mov         edi, eax            ; edx = longitud de cadena

            mov         esi, buffer         ; -> apunta al inicio de la cadena
            lea         edi, [esi+edi-1]    ; apunta al final de la cadena
            
            .loopi:
                mov         al, [esi]       ; carga el primer caracter
                xchg        al, [edi]       ; intercambia el primer y ultimo valor
                mov         [esi], al       ; guarda el caracter en el ulitmo lugar
                inc         esi
                dec         edi
                cmp         esi, edi
                jl          .loopi
                

        .end:
            pop         esi
            mov         byte[esi], 0H       ; la cadena termina en null
            mov         eax, buffer         ; eax -> buffer

    .restore:
        pop         esi
        pop         ebx
        pop         ecx
        pop         edx
    ret

; ------------------------------------------ ;
;                   EXTRAS                   ;
; ------------------------------------------ ;
