; Esta clase genera las operaciones de suma, resta, multiplicacion y division, no maneja numeros negativos, pues
; si realizamos una operacion entre A y B que genere un valor C negativo, esta colocará como valor de la operacion 
; 4294967295 - n que es el maximo valor posible para EAX.
; tambien es la clase encargada de obtener los valores de las instrucciones N N O donde N es un numero y O un operador
;
; fecha de creacion:            2023-04-09
; ultima actualización:         2023-04-09
; creador:                      https://github.com/daniel-baf

%include	'../utils/stdio32.asm'
%include	'errors/errors.asm'

SECTION .data

SECTION .bss

SECTION .text

; ----------------------------------------- ;
;		OBTENCION DE VALORES DE CADENA		;
; ----------------------------------------- ;

ascii_num:
    .backup:					; backup de valores actuales
	    push 	ecx
	    push 	esi
	    push 	ebx
	
    .split:						; divide los valores
        mov 	esi, eax		; ej: eax=5 3 + 2
	    xor		eax, eax		; reinicia los valores
		xor		ecx, ecx		; reinicia los valores
		xor		edi, edi		; reinicia los valores
    ; CONVERSOR
    .loop:
		xor		ebx, ebx				; reinicia los valores
	    mov 	bl, byte[esi+ecx]		; guarda el valor de la dir en memoria de ecx + esi en ebx 
	    cmp 	bl,10 					; ebx == 10?
	    
        je  	.loop_end				; termina el loop
	    cmp 	bl,0					; ebx == 0?
	    je  	.loop_end				; termina el loop
	    cmp 	bl,48 					; ebx == ASCII(0)?
	    jl 		.error					; lanza error
	    cmp 	bl,57					; ebx == ASCII(9)
	    jg 		.error					; lanza error
	    sub 	bl,48					; resta el valor ASCII para hacerlo numero
	    add 	eax, ebx				; eax += ebx
	    mov 	ebx,10 					; ebx = 10
	    mul 	ebx 					; eax *= ebx -> eax:edx
	    inc 	ecx 					; siguiente valor
	    jmp 	.loop					; reinicia el loop
    
    ; fin del loop
    .loop_end:
	    mov 	ebx,10					; ebx = 10
	    div 	ebx						; eax = eax / ebx -> eax:ebx
	    jmp 	.restore				; restauramos el backup
    
    .error:
	    mov 	edi,1						; instruccion invalida
	    jmp 	.restore					; restauramos el backup

    .restore:							; backup y terminamos la funcion 
	    pop 	ebx 
	    pop 	esi
	    pop 	ecx 
    ret

; ----------------------------------------- ;
;			OPERACIONES MATEMATICAS			;
; ----------------------------------------- ;

; obtenemos el valor que esté en la pila
get_num:
    cmp     ecx, 2								; revisamos si el valor es valido
	jl		.is_invalid							; mostramos un error si no viene en el orden <NUM> <NUM> <OPER>
    dec     ecx									; avanamos al anterior valor en pila
    mov     esi, [instructions + ecx * 4]		; esi -> nuevo valor almacenado
    dec     ecx									; avanzamos al anterior valor en pila
    mov     eax, [instructions + ecx * 4]		; eax -> el valor actual de esi
	jmp		.is_valid							; no hubieron errores
	.is_invalid:
	    call    invalid_expression				; ocurre un error y la funcion termina el programa
	.is_valid:
	    ret

; realiza la suma de los ultimos dos valores en pila
op_add:
	call		get_num							; obtenemos el ultimo valor en pila
	add			eax, esi						; le sumamos el ultimo valor en pila a eax
	call		save_results					; guardamos el resultado en el buffer
	ret											; retornamos a la funcion original

; realiza la resta entre dos valores en la pila
op_sub:
	call		get_num							; obtenemos el ultimo valor en pila
	sub			eax, esi						; restamos el ultimo valor en pila a eax
	call		save_results					; guardaos el resultado en el buffer
	ret											; retornamos a la funcion original

; realiza la división entre dos valores en la pila
op_div:
	call		get_num							; obtenemos el ultimo valor en la pila
	cmp			esi, 0							; revisamos si el divisor es 0
	je			.div_error						; si el divisior es 0 es un error aritmetico
	jne			.valid							; si no es cero, operamos la división

	.div_error:
		call		invalid_div					; no se puede dividir por 0

	.valid:
		idiv		esi							; dividimos por el ultimo valor en pila
		call		save_results				; guardamos los resultados en el buffer
	ret											; regresamos a la función original

; realiza una multiplicación entre dos valores en la pila
op_mult:
	call		get_num							; obtenemos el ultimo valor en la pila
	imul		esi								; multiplicamos por el ultimo valor en la pila
	call		save_results					; guardamos el resultado en la pila
	ret											; regresamos a la funcion original