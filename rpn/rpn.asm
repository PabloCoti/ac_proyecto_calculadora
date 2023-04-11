; Calculadora RPN que utiliza lso valores enviados como argumentos al invocar el programa para realizar las operaciones
; el programa detecta 3 tipos de errores
; 1. ERROR LEXICO
; 2. ERROR SINTACTICO
; 3. ERROR ALGEBRAICO, division entre 0
;
; fecha de creacion:            2023-04-09
; ultima actualización:         2023-04-09
; creador:                      https://github.com/daniel-baf

%include 'calc/calc_struc.asm'
SECTION .data

SECTION .bss

SECTION .text
    global _start

; inicio de la calculadora
_start:
    ; mostramos advertencia
    call    introduction_msg

    .config:                        ; apunta el inicio de la pila al final de la pila para ir eliminando operaciones
	    mov 		ebp,esp 		; inicio pila -> fin de la pila
	    xor 		ecx,ecx			; reinicia ecx
	    mov 		ebx,2

    .calc_start:                    ; inicia la calculadora
	    mov eax,[ebp+ebx*4]         ; eax -> ulitmo valor en pila
	    cmp byte[eax+1],0           ; revisamos si es null
	    jnz .cast_number            ; convertimos el valor ingresado a numero
    
        .operations:                    ; verifica las operaciones disponibles
    	    cmp byte[eax],43            ; ASCII(+)
    	    je g_add                    ; sumar
    	    cmp byte [eax],45           ; ASCII(-)
    	    je g_sub                    ; resta
    	    cmp byte [eax],47           ; ASCII(/)
    	    je g_div                    ; divide
    	    cmp byte[eax],120           ; ASCII(x)
    	    je g_mult                   ; multiplica

    .cast_number:                   ; convierte el valor a numero
	    xor 		edi,edi                  ; edi es reiniciado
	    call 		ascii_num                ; obtiene los valores de lo ingresado
	    cmp			edi,1                    ; revisamos si ascii_num devolvió error (1=
	    je 			.error                   ; si ascii_num devuleve 1, hay un error
        .no_error: 			                 ; no hay errores si devuelve otro valor
            mov 		[instructions +ecx * 4],eax   	; actualizamos el valor en dir momoria de [] con el valor de eax
        	inc 		ecx                          	; pasamos al siguiente valor
	        jmp 		.calc_end                    	; continuamos con las operaciones en pila
        .error:
            call        no_number
    
    .calc_end:                      ; terminamos con los valores de la calculadora
	    inc 		ebx                     ; pasamos al ultimo argumento
	    cmp 		ebx,[ebp]               ; revisamos si aun hay argumentos
	    jle 		.calc_start             ; repetimos las instrucciones solo si es menor o igual
	    call 		display_result         ; mostramos el resultado final

    ; finalizamos el programa
	
    call        sys_exit			; salimos del programa
    ret

; GUARDA EL RESULTADO EN MEMORIA
save_results:
	mov 		[instructions + ecx * 4],eax		; actualiza la dir en memoria [inst + ecx*4] con el valor en eax
	inc 		ecx									; aumentamos en ecx
	jmp 		_start.calc_end						; regreamos al fin de la calculadora