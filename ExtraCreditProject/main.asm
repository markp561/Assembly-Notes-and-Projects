; nasm -f elf32 main.asm && ld -m elf_i386 main.o

section     .data
    msg1            db "Enter the array size: "
    msg1_len        equ ($ - msg1)

    msg2            db "Enter the contents of the array: ", 0x0A
    msg2_len        equ ($ - msg2)

    msg3            db "Enter the search target: "
    msg3_len        equ ($ - msg3)

    success_msg     db "The search target was found at index: "
    success_msg_len equ ($ - success_msg)

    failure_msg     db "The search target was not found", 0x0A
    failure_msg_len equ ($ - failure_msg)
    
    exit_msg        db "Program Ended", 0x0A
    exit_msg_len    equ ($ - exit_msg)

    newline         db 0x0A

    arr             dd 33, -44, 11, 55, -2
    arr_len         dd 0


section     .bss
    buffer      resb 16

section     .text
    global      _start


_start:
    ; print msg1
    mov ecx, msg1
    mov eax, 4
    mov ebx, 1
    mov edx, msg1_len
    int 0x80

    ; take user input for array length
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80

    ; move user input into array length
    xor eax, eax,
    mov edi, buffer
    call atoi

    mov [arr_len], eax
    
    ; print_array function takes three arguments: a pointer to base address of the array, length of the array, and pointer to the buffer
    mov edi, arr
    mov esi, [arr_len]
    mov edx, buffer
   
    call print_array
                                
    ; the quicksort function takes three arguments: a pointer to the base address of the array, and low and a high indices
    mov edi, arr
    mov esi, 0
    mov edx, [arr_len]
    dec edx

    call quicksort

    
    ; print a newline
    mov ecx, newline
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 0x80
    

    ; print the sorted array
    mov edi, arr
    mov esi, [arr_len]
    mov edx, buffer

    call print_array

    ; print a newline
    mov ecx, newline
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 0x80
    
    ; print msg3, prompting user to enter search target
    mov ecx, msg3
    mov eax, 4
    mov ebx, 1
    mov edx, msg3_len
    int 0x80
    
    ; take user input for search target
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80

    ; convert user input from ascii to integer
    xor eax, eax
    mov edi, buffer
    call atoi

    ; the binary_search function takes three arguments: pointer to base address of array, the length of the array, and a pointer to the target
    mov edi, arr
    mov esi, [arr_len]
    dec esi
    mov ebx, eax
    call binary_search
    
    ; if the result is greater than -1 then the target was found and we print the respective success message
    ; if the result is -1 then the target wasn't found and we print the respective failure message
    cmp eax, -1
    jg success
    je failure

    

success:
    ; convert the result of binary search to ascii to be printed
    mov edi, buffer
    call itoa

    push eax                    ; preserve the result of binary search
    push edx                    ; preserve the length of the result

    ; print "The search target was found at index: "
    mov ecx, success_msg
    mov eax, 4
    mov ebx, 1
    mov edx, success_msg_len
    int 0x80

    pop edx                     ; restore edx so we can use the length of the result
    pop eax                     ; restore eax so we can use the result of binary search

    ; print the result
    mov ecx, eax
    mov eax, 4
    mov ebx, 1
    int 0x80

    jmp exit
failure:
    ; print the message corresponding to the search target not being found in the array
    mov ecx, failure_msg
    mov eax, 4
    mov ebx, 1
    mov edx, failure_msg_len
    int 0x80

    jmp exit
exit:
    ; print the message "Program Ended"
    mov ecx, exit_msg
    mov eax, 4
    mov ebx, 1
    mov edx, exit_msg_len
    int 0x80

    ; exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80




; parameters: array, start index, array length, buffer
print_array:
    mov ecx, esi
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
    ret




atoi:
    xor eax, eax
    xor ebx, ebx

    mov dl, [edi]
    cmp dl, '-'
    jne .loop

    mov bl, 1
    inc edi
    jmp .loop

.loop:
    movzx edx, byte [edi]
    cmp dl, 0x0A
    je .end

    imul eax, 10
    sub edx, '0'
    add eax, edx

    inc edi
    jmp .loop
.end:
    cmp bl, 1
    jne .done
    neg eax
.done:
    ret




itoa:
    mov ecx, 10                 ; divisor
    xor esi, esi                ; clear esi
    
    mov ebx, eax
    cmp eax, 0
    jge .loop1
    
    neg eax

.loop1:
    cdq
    idiv ecx                    ; divide edx:eax by ecx
    push edx                    ; push the remainder onto the stack
    inc esi                     ; increment the remainder counter
    test eax, eax               ; check if eax is zero
    jne .loop1                  ; if not then jump to next iteration. if it is then go to loop2

    mov eax, edi                ; this will be returned. it is the base address of the buffer

    cmp ebx, 0
    jge .loop2
    
    mov byte [edi], '-'
    inc edi

.loop2:
    pop edx                     ; pop a remainder from the stack
    add dl, '0'                 ; append a '0' to convert it to ascii
    mov [edi], dl               ; mov it into the buffer
    inc edi                     ; increment the buffer so we can append the next digit
    dec esi                     ; decrement the remainder counter
    jnz .loop2                  ; if esi is not zero then jump to next iteration. if it is then the loop is done

    mov byte [edi], 0x0A        ; append a newline character to the buffer
    inc edi                     ; increment the buffer

    mov edx, edi                ; move the address of the buffer into edx
    sub edx, eax                ; calculate length of the buffer by subtracting the current address with the base address that was previously stored in eax

    ret




partition:
    mov ecx, esi                       ; move start index to j
    mov ebx, esi                       ; move start index to i
    dec ebx

    cmp ecx, edx                       ; compare j to end index
    jl .loop                           ; if j smaller than end, enter loop
    jge .end                           ; else go to end of loop
   
.loop:   
    mov eax, [edi + ecx*4]             ; move element of arr at index j into eax
    cmp eax, [edi + edx*4]             ; compare element of arr at index j to element of arr at index end
    jg .continue                       ; if arr[j] > arr[end] do nothing, go to next iteration

    inc ebx                            ; else i++ and swap arr[i] with arr[j]
    
    push esi                           ; push esi to save current value and free it for use
    mov esi, ebx                       ; move i into esi

    push ebx                           ; push ebx to save current value and free it for use

    ; swap ith element with jth element
    mov eax, [edi + esi*4]             ; ith element
    mov ebx, [edi + ecx*4]             ; jth element
    mov [edi + ecx*4], eax             ; move ith element into jth index
    mov [edi + esi*4], ebx             ; move jth element into ith index
     
    pop ebx                            ; pop ebx to restore its value
    pop esi                            ; pop esi to restore its value 

    jmp .continue                      

.continue:
        inc ecx                        ; increment j to access the next element
        cmp ecx, edx                   ; compare j to the end index
        jl .loop                       ; if j is smaller than end, jump to start of loop for the next iteration

.end:
        mov ecx, ebx                   ; move i into ecx
        add ecx, 1                     ; add 1 to ecx
        
        push ebx                       ; push ebx to save its current value and free it for use

        ; swap i+1 element with end element 
        mov eax, [edi + ecx*4]
        mov ebx, [edi + edx*4]
        mov [edi + ecx*4], ebx
        mov [edi + edx*4], eax

        pop ebx                         ; pop ebx to restore its value

        mov eax, ebx                   ; move i into eax
        add eax, 1                     ; add 1 to eax
        ret                            ; return (eax will be returned)




quicksort:
    cmp esi, edx                       ; compare esi (start) to edx (end)
    jge .base_case                     ; if start is greater than or equal to then we need to exit

    call partition

                                       ; left partition
    push edx                           ; save edx (end)
    mov edx, eax                       ; move the return value from partition call to edx
    dec edx                            ; decrement edx
    
    call quicksort                     ; call quicksort on left partition

    pop edx                            ; pop back edx to restore value from before recuesive call

    push esi                           ; save esi by pushing to stack (start)
    mov esi, eax                       ; move the return value from partition call to esi
    inc esi                            ; increment esi

    call quicksort                     ; call quicksort on right partition

    pop esi                            ; pop back esi to restore value from before recursive call
.base_case:                            ; in the base case we just need to exit the function
    ret


binary_search:
    mov edx, esi                        ; array length

    xor esi, esi                        ; esi used to hold low index
    xor ecx, ecx                        ; ecx used to hold mid index
.loop:
    cmp esi, edx                   ; Compare low index to high index
    jg .not_found                  ; If low is greater than high, then exit by jumping to not_found

    mov eax, esi                   ; move low index to rax
    add eax, edx                   ; add high to low
    shr eax, 1                     ; shift right by 1 bit to divide by 2
    mov ecx, eax                   ; mov the quotient into rcx

    mov eax, [edi + ecx*4]         ; Move element at index mid into eax

                                   ; The following three comparisons are made:
    cmp ebx, eax           
    jg .greater_than               ; target > arr[mid]                
    jl .less_than                  ; target < arr[mid]
    je .found                      ; target == arr[mid]

.greater_than:                     ; target is greater than arr[mid] so we update low to be mid+1
    mov esi, ecx
    inc esi
    jmp .loop                      ; Jump to the beginning of the binary_search section

.less_than:                        ; target is less than arr[mid] so we update high to be mid - 1
    mov edx, ecx               
    dec edx                     
    jmp .loop                      ; Jump to the beginning of the binary_search section

.found:                           
    mov eax, ecx                   ; move the index into eax to be returned
    ret                            ; target was found so we can exit the function and return the index where it was found

.not_found:                        ; the loop ended and the target was not found
    mov eax, -1
    ret                            ; since target was not found we can exit the function and return -1 as an indication that the search was unsuccessful

