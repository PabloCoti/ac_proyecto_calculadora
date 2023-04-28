%include    'calc/calc_utils.asm'

read_file_inp:

    pusha
    ; open the file

    mov edi, esi

    mov eax, 5
    mov ebx, edi
    mov ecx, 0
    int 80H

    ; save the file descriptor in esi

    mov esi, eax

    ; read a line from the file

    mov eax, 3
    mov ebx, esi
    mov ecx, expressions
    mov edx, 256
    int 80H

    ; close the file

    mov eax, 6
    mov ebx, esi
    int 80H

    popa
    ret


save_content_file:

    pusha
    ; open the file

    mov eax, 5
    mov ebx, resultfile
    mov ecx, 0
    int 80H

    ; save the file descriptor in esi

    mov esi, eax

    ; read a line from the file

    mov eax, 3
    mov ebx, esi
    mov ecx, content
    mov edx, 256
    int 80H

    ; close the file

    mov eax, 6
    mov ebx, esi
    int 80H

    popa
    ret

create_file_new:
    pusha

    mov eax, 8
    mov ebx, resultfile
    mov ecx, 0755o
    int 80H

    mov esi, eax

    mov eax, 6
    mov ebx, esi
    int 80H

    popa
    ret    

wirte_file_res:
    pusha

    call save_content_file

    mov eax, 8
    mov ebx, resultfile
    mov ecx, 0777
    int 80H

    mov esi, eax

    mov eax, content
    call strLen

    mov edx, eax

    mov eax, 4
    mov ebx, esi
    mov ecx, content
    mov edx, edx
    int 80H

    cmp edx, 0
    je .skip_new_line

    mov eax, 4
    mov ebx, esi
    mov ecx, newline
    mov edx, 1
    int 80H

    .skip_new_line:
        mov eax, 4
        mov ebx, esi
        mov ecx, dec_str
        mov edx, edi
        int 80H

        mov eax, 6
        mov ebx, esi
        int 80H

        popa
    ret