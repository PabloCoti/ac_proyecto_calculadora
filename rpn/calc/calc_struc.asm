; Clase auxiliar para la calculadora, esta clase muestra el resultado final, genera
; las operacioes de suma, resta, multiplicacion y division haciendo llamada a subrutinas de otra clase
; y sirve como mensajera, pues en esta clase se colocaran todos los mensajes que se quieran mostrar en la aplicación
;
; fecha de creacion:            2023-04-09
; ultima actualización:         2023-04-09
; creador:                      https://github.com/daniel-baf

%include        'calc/calc_utils.asm'

SECTION .data
    msg_result          db      "El resultado es: ", 0H
    msg_introduction    db      "La aplicacion no maneja numeros negativos, el valor puede diferir con el correcto", 0H

SECTION .bss
	instructions: resb 100 ; reserva 100 bytes

SECTION .text

; ----------------------------------------- ;
;			OPERACIONES MATEMATICAS			;
; ----------------------------------------- ;
; estas funciones hacen llamadas a subrutinas, la subrutina luego hace un salto a la funcion madre
; funciona como un switch
g_add:                   ;g_add
    call        op_add
g_sub:                   ;g_sub
    call        op_sub
g_div:                   ;g_div
    call        op_div
g_mult:                   ;g_mult
    call        op_mult


; ----------------------------------------- ;
;			IMPRIME EL RESULTADO			;
; ----------------------------------------- ;
; imprime el resultado almacenado en la pila y el buffer, todo fue exitoso, se guardara 1 en ecx antes de llamar a esta subrutina
display_result:
	cmp         ecx,1                   ; revisa si hubo un error durante las operacions
    jne         .error                  ; ecx != 1 -> error durante la ejecucion
    .no_error:                                      ; no hubieron errores
        dec         ecx                             ; regresamos un valor en el buffer
    	mov         eax, [instructions +ecx*4]      ; guardamos en eax el ultimo valor almacenado, dir en memoria inst + ecx * 4
        push        eax                             ; backup del resultado
        mov         eax, msg_result                 ; eax -> *mensaje
        call        print                           ; imprime eax
        pop         eax                             ; recupera el resultado
    	call        iPrintLn                        ; imprime el valor
        jmp         .done                           ; termina la calculadora
    .error:
        call        invalid_expression
    .done:
        call        sys_exit

; muestra un mensaje explicando que la calculadora no opera con valores
introduction_msg:
    mov         eax, msg_introduction
    call        println
    ret