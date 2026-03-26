; nasm -f elf64 main.asm && gcc -no-pie main.o

default rel

section     .data
    fmt     db "%d", 10, 0
    arr:    dd 1, 2, 3, 4, 5
    arr_len equ ($ - arr) / 4
    i       dd 0
    

section     .text
    global main
    extern printf


main:
    
    mov ecx, [i]                ; Move the index, i, into ecx
    cmp ecx, arr_len            ; Compare i to the size of arr
    jge end                     ; If i is greater than or equal to arr_len, then jump to the end and exit
        
    mov ebx, arr                ; Move the base address of arr into ebx
    mov eax, [ebx + ecx * 4]    ; Move the element of arr at index i into eax

    imul eax, [ebx + ecx * 4]
    
    mov rdi, fmt
    mov esi, eax
    xor rax, rax

    call printf

    inc dword [i]
    jmp main

end:
    xor rax, rax
    ret

    
