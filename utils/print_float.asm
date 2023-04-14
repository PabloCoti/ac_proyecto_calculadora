; Funcion que se encarga de imprimir numeros double a decimales
; las funciones fueron inpiradas por varias fuentes de stackoverflow
; y la teoria de https://en.wikibooks.org/wiki/X86_Assembly/Floating_Point
; creador: https://github.com/daniel-baf
; fecha: 13 de abril del 2023
; ultima actualización: 13 abril del 2023


global _start

section .bss
    dec_str: resb 512

section .text

double2dec:                     ; Args: ST(0): FPU-register to convert, EDI: pointer to string
%define CONTROL_WORD    word [ebp-2]
%define TEN             word [ebp-4]
%define TEMP            word [ebp-4]
%define INTEGER         qword [ebp-12]

    push        ebp
    mov         ebp, esp
    sub         esp, 12

    ; modifying rounding mode
    fstcw       CONTROL_WORD
    mov ax,     CONTROL_WORD
    or          ah, 0b00001100          ; Set RC=11: truncating rounding mode
    mov         TEMP, ax
    fldcw       TEMP                    ; Load new rounding mode

    ; Separate integer and fractional part & convert integer part into ASCII
    fst
    frndint                             ; ST(0) to integer
    fsub        st1, st0                ; Integral part in ST(0), fractional part in ST(1)
    call        fpu2bcd2dec
    fabs                                ; Make fractional positive (not guaranteed by fsub)

    mov         byte [edi], '.'         ; Decimal point
    add         edi, 1

    ; Move 10 to st(1)
    mov         TEN, 10
    fild        TEN
    fxch

    ; isolate digits of fractional part and store ASCII
    .get_fractional:
        fmul        st0, st1                       ; Multiply by 10 (shift one decimal digit into integer part)
        fist        word TEMP                      ; Store digit
        fisub       word TEMP                      ; Clear integer part
        mov         al, byte TEMP                  ; Load digit
        or          al, 0x30                       ; Convert digit to ASCII
        mov         byte [edi], al                 ; Append it to string
        add         edi, 1                         ; Increment pointer to string

        fxam                                       ; ST0 == 0.0?
        fstsw       ax
        sahf
        jnz         .get_fractional                ; No: once more
        mov         byte [edi], 0                  ; Null-termination for ASCIIZ

        ; clean up FPU
        ffree       st0                            ; Empty ST(0)
        ffree       st1                            ; Empty ST(1)
        fldcw       CONTROL_WORD                   ; Restore old rounding mode

        leave
    ret                                 ; Return: EDI points to the null-termination of the string

fpu2bcd2dec:                            ; Args: ST(0): FPU-register to convert, EDI: target string

    push        ebp
    mov         ebp, esp
    sub         esp, 10                 ; 10 bytes for local tbyte variable

    fbstp       [ebp-10]

    mov         ecx, 10                 ; Loop counter
    lea         esi, [ebp - 1]          ; bcd + 9 (last byte)
    xor         bl, bl                  ; Checker for leading zeros

    ; Handle sign
    btr         word [ebp-2], 15        ; Move sign bit into carry flag and clear it
    jnc         .L1                     ; Negative?
    mov         byte [edi], '-'         ; Yes: store a minus character
    add         edi, 1

    .L1:
        mov     al, byte [esi]
        mov     ah, al
        shr     ah, 4               ; Isolate left nibble
        or      bl, ah              ; Check for leading zero
        jz      .1
        or      ah, 30h             ; Convert digit to ASCII
        mov     [edi], ah
        add     edi, 1

        .1:
            and al, 0Fh             ; Isolate right nibble
            or bl, al               ; Check for leading zero
            jz .2
            or al, 30h              ; Convert digit to ASCII
            mov [edi], al
            add edi, 1
        .2:
            sub esi, 1
        loop .L1

    test        bl, bl                 ; BL remains 0 if all digits were 0
    jnz         .R1                    ; Skip next line if integral part > 0
    mov         byte [edi], '0'
    add         edi, 1

    .R1:
        mov byte [edi], 0           ; Null-termination for ASCIIZ
        leave
    ret                         ; Return: EDI points to the null-termination of the string