; nasm -f elf32 main.asm && ld -m elf_i386 main.o

section     .data
    arr         dd 12, 34, 56, 78, 9
    arr_len     equ ($ - arr) / 4

section     .bss
    buffer      resb 16

section     .text
    global      _start


_start:
                                ; the print array function takes three arguments, a pointer to the base address of the array, the length of the array, and a pointer to the buffer
    push buffer                 ; third argument
    push arr_len                ; second argument
    push arr                    ; first argument
    
    call print_array
    add esp, 12

                                ; exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80


; parameters: array, start index, array length, buffer
print_array:
    push ebp
    mov ebp, esp

    mov edi, [ebp+8]            ; array
    mov ecx, [ebp+12]           ; array length
    mov edx, [ebp+16]           ; buffer

    xor esi, esi
.loop:
    cmp esi, ecx
    jge .end
    mov eax, [edi + esi*4]

    push esi                    ; preserve the counter
    push ecx                    ; preserve the array length
    push edi                    ; preserve the array
    
    mov edi, edx
    push edx
    call itoa
        
    mov ecx, eax
    mov eax, 4
    mov ebx, 1
    int 0x80
    
    pop edx
    pop edi                     ; restore the array
    pop ecx                     ; restore the array length
    pop esi                     ; restore the counter
    
    inc esi                     ; increment the counter
    jmp .loop                   ; jump to the next iteration

.end:
    pop ebp                     
    ret




itoa:
    mov ecx, 10                 ; divisor
    xor esi, esi                ; clear esi
  
.loop1:
    xor edx, edx                ; clear edx
    idiv ecx                    ; divide edx:eax by ecx
    push edx                    ; push the remainder onto the stack
    inc esi                     ; increment the remainder counter
    test eax, eax               ; check if eax is zero
    jne .loop1                  ; if not then jump to next iteration. if it is then go to loop2

    mov eax, edi                ; this will be returned. it is the base address of the buffer

.loop2:
    pop edx                     ; pop a remainder from the stack
    add dl, '0'                 ; append a '0' to convert it to ascii
    mov [edi], dl               ; mov it into the buffer
    inc edi                     ; increment the buffer so we can append the next digit
    dec esi                     ; decrement the remainder counter
    jnz .loop2                  ; if esi is not zero then jump to next iteration. if it is then the loop is done

    mov [edi], 0x0A             ; append a newline character to the buffer
    inc edi                     ; increment the buffer

    mov edx, edi                ; move the address of the buffer into edx
    sub edx, eax                ; calculate length of the buffer by subtracting the current address with the base address that was previously stored in eax

    ret
