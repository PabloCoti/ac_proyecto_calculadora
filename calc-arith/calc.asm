; Calculadora aritmetica de 2 parametros, NUM OP NUM y retorna su valor
;
; fecha de creacion:            2023-04-09
; ultima actualización:         2023-04-09
; creador:                      https://github.com/daniel-baf

%include        '../utils/stdio32.asm'
%include        'errors.asm'

SECTION .data
    result_msg      db          "El resultado es: ", 0H    

SECTION .bss
    oper_1:     resb    4       ; guardamos 4 bytes para el primer valor
    oper_2:     resb    4       ; guardamos 4 bytes para el segundo valor
    operator:   resb    4       ; guardamos 4 bytes para el operador

SECTION .text
    global      _start

; funcion principal
; ./calc 10 + 2     -> ./calc | 10 | + | 2 |  4
_start:
    ; recorrer los parametros enviados
    pop         ecx     ; agarramos el primer parametro
    
    .args_loop:
        cmp         ecx, 0H             ; ya no existe algo en la pila?
        jz          .args_loop_end      ; salimos del loop
        pop         eax                 ; guardo el siguiente valor en eax
        call        exec_calc
        dec         ecx                 ; ecx --
        jmp         .args_loop          ; continuamos el loop
    .args_loop_end:
        call        print_tmp
        call        sys_exit

; verifica el valor en eax y ejeucta acciones segun el operador
exec_calc:
    cmp         ecx, 5
    je          .error          ; vinieron mas de 4 argumentos
    cmp         ecx, 3          ; igrnoamos el valor ./calc
    jle         .math           ; calculamos los valores
    .invalid:                   ; ignora ./calc
        ret
    .math:                      ; ejecuta las operaciones
        cmp     ecx, 3          ; el parametro 3 debe traer un numero
        je      .is_num_1       ; guardamos el numero 1
        cmp     ecx, 1          ; el parametro 1 debe traer un numero
        je      .is_num_2       ; guardamos el operador
        cmp     ecx, 2          ; el parametro 2 debe el operador
        je      .save_oper      ; guardamos el operador
        ; operaciones aritmeticas
        ; TODO error
        ret
        .is_num_1:
            call    str_to_int               ; castea el string a int
            mov     ebx, oper_1              ; ebx -> a el espacio en memoria reservado
            mov     dword [ebx], eax         ; hacemos un push de dw en oper_1
            ret                              ; termina la funcion
        .is_num_2:
            call    str_to_int               ; castea el string a int
            mov     ebx, oper_2              ; ebx -> a el espacio en memoria reservado
            mov     dword [ebx], eax         ; hacemos un push de dw en oper_1
            ret                              ; termina la funcion
        .save_oper:
            mov         esi, eax             ; esi -> buffer
            mov         edi, operator        ; edi -> in_name

            push        eax                  ; backup
            call        strLen               ; calculamos longitud de texto
            mov         ecx, eax             ; ecx = longitud cadena
            pop         eax                  ; recuperamos la cadena

            cld                              ; asegurarse de que el puntero de origen avance hacia adelante
            rep         movsb                ; copia el contenido del string

            mov         ecx, 2               ; recupera el valor de ecx
            ret
    .error:
        call        disp_param_err           ; mostramos el error de los parametros

print_tmp:
    mov     eax, [oper_1]                   ; obtenemos el valor del numero 1
    mov     ebx, [oper_2]                   ; obtenemos el valor del numero 2

    mov     edx, operator                   ; obtenemos el valor del operador
    cmp     byte[edx], 43                   ; es suma?
    je      .add                            ; sumamos
    cmp     byte[edx], 45                   ; es resta?
    je      .sub                            ; restamos
    cmp     byte[edx], 47                   ; es division?
    je      .div                            ; divide
    cmp     byte[edx], 120                  ; es multiplicación?
    je      .mul                            ; multiplica
    ; default -> error
    call        disp_lex_err                ; si no es ninguno, es eror lexico
    call        disp_synt_err               ; tambien genera un error sintactico 

    .add:
        add     eax, ebx                    ; genera la suma
        jmp     .res                        ; muestra el resultado
    .sub:                                   
        sub     eax, ebx                    ; genera la resta
        jmp     .res                        ; muestra el resultado
    .mul:
        imul     eax, ebx                   ; genera la multiplicacion
        jmp     .res                        ; muestra el resultado
    .div:
        ; revisamos divisiones por 0
        cmp     ebx, 0                      ; el divisor es 0?
        je      .div_error                  ; muestra el error
        ; continuar la
        .div_ok:                            ; divison valida
            xor     edx, edx                ; reinicia el valor de edx
            idiv     ebx                    ; genera la división
            jmp     .res                    ; muestra el resultado
        .div_error:
            call    disp_arith_err          ; error en la división
    .res:                                   ; muestra el resultado
        push        eax
        mov         eax, result_msg
        call        print
        pop         eax
        call        iPrintLn                    ; imprime el resultado
    ret