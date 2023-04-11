; Clase que se encarga de manejar errores en la aplicacion, si ocurre un error no continua con las operaciones y termina
; el programa, maneja 3 tipos de errores, lexico, sintactico y aritmetico
;
; tambien es la clase encargada de obtener los valores de las instrucciones N N O donde N es un numero y O un operador
; fecha de creacion:            2023-04-09
; ultima actualización:         2023-04-09
; creador:                      https://github.com/daniel-baf


SECTION .data
    syntactical_error     db      "Hay un error en tu sintaxis, revisa que uses los símbolos (+, -, x, /) | [0-9] y que tengas n numeros y n - 1 operandos", 0H
    lexical_error         db      "Hay un error lexico, los simbolos validos son [+, -, x, /] ", 0H
    arith_error           db      "Haz generado un valor divergente al intentar dividir por 0", 0H

SECTION .bss

SECTION .text

; ----------------------------------------- ;
;			  SECCION DE ERRORES			;
; ----------------------------------------- ;
; guia: https://www.cfd-online.com/Tools/rpncalc.html

; imprime un error cuando la expresion es invalida lexica o sintacticamente
invalid_expression:
    mov         eax, 0
    call        print_error
	ret

; genera un error cuando no hay numeros para leer
no_number:
	mov			eax, 1
    call        print_error
	ret

; genera un error cuando queremos dividir entre 0
invalid_div:
    mov         eax, 2
    call        print_error
    ret

; iprime el error segun el numero que venta en eax
print_error:
    cmp     eax, 0
    je      .print_0
    cmp     eax, 1
    je      .print_1
    cmp     eax, 2
    je      .print_2

    .print_0:
        mov     eax, syntactical_error
        jmp     .done
    .print_1:
        mov     eax, lexical_error
        jmp     .done
    .print_2:
        mov     eax, arith_error
        jmp     .done

    .done:
        call    println
        call    sys_exit
    ret