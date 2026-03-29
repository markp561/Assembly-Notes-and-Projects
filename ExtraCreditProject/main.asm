; nasm -f elf64 main.asm && gcc -no-pie main.o && ./a.out

default rel                         ; this line ensures that the default address binding is relative address binding instead of absolute address binding which is deprecated 

section     .data
    fmt         db "%d", 10, 0      ; this line declares a string used for formatting the printf function, where "%d" instructs the printf function to print an integer, 10 is ASCII code for a newline character, and 0 is a null terminator which is needed for strings in C

                                    ; declare an array of integers
    arr         dq -10, 3, 1, 6, 9, -2, 2, -4, -18, 100, 59, 1000, -2, -2, 10, 3, 1
    arr_len     equ ($ - arr) / 8   ; get the length of the array

    q           dq 0                ; return value of partition
    i           dq 0                ; used in partition for indexing
    j           dq 0                ; used in partition loop
        
                                    ; element to be searched for in binary search call
    target      dq 1
    
    
section     .text
    global      main                ; use global main at the main function since I'm linking the program with C
    extern      printf              ; indicates to the assembler that printf is an external function 

main:
   
    
    mov rdi, arr                    ; move the base address of arr into rdi
    mov rsi, 1                      ; move 1 into rsi to be used in the main_loop
    mov rdx, arr_len                ; move the length of the array into rdx
    dec rdx

                                    ; this loop checks if the array is already sorted
    main_loop:
    
        cmp rsi, rdx                ; compare rsi, the index, to the array length
        jg main_outer_loop_end      ; if rsi is greater than the array length then exit the loop
        
        mov rax, [rdi + rsi*8]      ; move index i+1, i+2, ..., i+end-1 elemement into rax
        cmp [rdi], rax              ; compare base arr element with following elements to check if the array is already in order
        jge sort                    ; if the base arr element is larger than any element, then the array is out of order

        inc rsi

    main_outer_loop_end:

    sort:
                                    ; sort the array
                                    ; pass arr, start index, end index as arguments through rdi, rsi, rdx, respectively
        mov rdi, arr        
        mov rsi, 0          
        mov rdx, arr_len    
        dec rdx             
        call quicksort


                                    ; print the sorted array
                                    ; pass arr, start index, end index as arguments through rdi, rsi, rdx, respectively
    mov rdi, arr
    mov rsi, 0
    mov rdx, arr_len
    dec rdx
    call print_array


                                    ; search for the target
                                    ; pass arr, start index, end index, mid index, and target through rdi, rsi, rdx, rcx, r8, respectively
    mov rdi, arr        
    mov rsi, 0          
    mov rdx, arr_len    
    dec rdx
    mov rcx, 0          
    mov r8, [target]    
    call binary_search

                                    ; print the result from binary search
    mov rdi, fmt        
    mov rsi, rax
    xor rax, rax
    call printf
    
    xor rax, rax                    ; exit the program
    ret


print_array:

.print_array_begin:
    cmp rsi, rdx                       ; compare rsi, iterator, to the end index
    jg .print_array_end                ; if rsi is greater, then the loop is over and we should exit

    mov rax, [rdi + rsi*8]             ; move current element of arr into rax

                                       ; push rsi, rdi, rdx to stack to preserve.
                                       ; these registers are used for the printf call
                                       ; printf clobbers rdx register so it needs to be saved too
    push rsi                            
    push rdi                    
    push rdx

    mov rdi, fmt
    mov rsi, rax
    xor rax, rax
    call printf

                                       ; here we pop back the three registers that were pushed in order to restore their values
    pop rdx
    pop rdi
    pop rsi
    
    inc rsi                            ; increment the iterator, rsi
    jmp .print_array_begin             ; jump to the top of the loop
    
.print_array_end:
    ret


partition:

    mov [i], rsi                       ; move current value of rsi (start) into i
    dec qword [i]                      ; decrement i
    
    mov [j], rsi                       ; move start into j
    cmp [j], rdx                       ; compare j to end
    jl loop                            ; if j smaller than end enter loop
    jge partition_end                  ; else go to end of loop
   
    loop:   
        mov rcx, [j]                   ; move j into rcx
        mov rax, [rdi + rcx*8]         ; move element of arr at index j into rax
        cmp rax, [rdi + rdx*8]         ; compare element of arr at index j to element of arr at index end
        jg continue                    ; if arr[j] > arr[end] do nothing, go to next iteration
    
        inc qword [i]                  ; else i++ and swap arr[i] with arr[j]
        
    
        push rsi                       ; push rsi so we can use it
        mov rsi, [i]                   ; move i into rsi

                                       ; swap the ith element with the jth element
        mov rax, [rdi + rsi*8]         ; move ith element of arr into rax
                                       ; xor swapping method
        xor rax, [rdi + rcx*8]         ; xor rax with the jth element
        xor [rdi + rcx*8], rax         ; xor the jth element with rax
        xor rax, [rdi + rcx*8]         ; xor rax with the jth element again
    
        mov [rdi + rsi*8], rax         ; move the value of rax into the ith index

        pop rsi                        ; pop rsi to get back its value

        jmp continue            

        continue:
            inc qword [j]              ; increment j to access the next element
            cmp [j], rdx               ; compare j to the end index
            jl loop                    ; if j is smaller than end, jump to start of loop for the next iteration

    partition_end:
        mov rcx, [i]                   ; move i into rcx
        add rcx, 1                     ; add 1 to rcx
        
    
                                       ; swapping i+1 element with end element
        mov rax, [rdi + rcx*8]         ; move element of arr at index i into rax
                                       ; same xor swap as before but with rdx register that contains the end index
        xor rax, [rdi + rdx*8]  
        xor [rdi + rdx*8], rax 
        xor rax, [rdi + rdx*8]

        mov [rdi + rcx*8], rax         ; move rax into i+1 index of arr


        mov rax, [i]                   ; move i into rax
        add rax, 1                     ; add 1 to rax
        ret                            ; return (rax will be returned)

    
                                       ; takes array, low index, high index
quicksort:
    
    cmp rsi, rdx                       ; compare rsi (start) to rdx (end)
    jge .base_case                     ; if start is greater than or equal to then we need to exit
    

    call partition

                                       ; left partition
    push rdx                           ; save rdx (end)
    mov rdx, rax                       ; move the return value from partition call to rdx
    dec rdx                            ; decrement rdx
    
    call quicksort                     ; call quicksort on left partition
    
    pop rdx                            ; pop back rdx to restore value from before recursive call

    push rsi                           ; save rsi by pushing to stack (start)
    mov rsi, rax                       ; move the return value from partition call to rsi
    inc rsi                            ; increment rsi

    call quicksort                     ; call quicksort on right partition

    pop rsi                            ; pop back rsi to restore value from before recursive call

.base_case:                            ; in the base case we just need to exit the function
    ret




binary_search:
    
    begin_loop:
        cmp rsi, rdx                   ; Compare low index to high index
        jg .not_found                  ; If low is greater than high, then exit by jumping to not_found


        mov rax, rsi                   ; move low index to rax
        add rax, rdx                   ; add high to low
        shr rax, 1                     ; shift right by 1 bit to divide by 2
        mov rcx, rax                   ; mov the quotient into rcx

        mov rax, [rdi + rcx*8]         ; Move element at index mid into eax

                                       ; The following three comparisons are made:
        cmp r8, rax           
        jg .greater_than               ; target > arr[mid]                
        jl .less_than                  ; target < arr[mid]
        je .found                      ; target == arr[mid]

    .greater_than:
                                       ; low = mid + 1
        mov rsi, rcx
        inc rsi
        jmp begin_loop                 ; Jump to the beginning of the binary_search section

    .less_than:
                                       ; high = mid - 1
        mov rdx, rcx               
        dec rdx                     
        jmp begin_loop                 ; Jump to the beginning of the binary_search section


    .found:
                                       ; target found
        mov rax, rcx
        ret                            ; target was found so we can exit the function and return the index where it was found
    .not_found:
                                       ; the loop ended and the target was not found
        mov rax, -1 
        ret                            ; since target was not found we can exit the function and return -1 as an indication that the search was unsuccessful


