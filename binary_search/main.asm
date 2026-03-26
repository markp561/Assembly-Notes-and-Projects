; nasm -f elf64 main.asm && gcc -no-pie main.o

default rel

section     .data
    fmt              db "%d", 10, 0

    arr              dd 2, 1, 6, 9, 5, 7, 10, 3, 4, 8 
    arr_len          equ ($ - arr) / 4

    i                dd 0
    j                dd 0

    temp             dd 0
    smallest_index   dd 0
    smallest_element dd 0
    
    target           dd 10
    result           dd -1
    high             dd arr_len - 1
    low              dd 0
    mid              dd 0
    

    
    

section     .text
    global      main
    extern      printf

main:

        outer_loop_begin:
            mov ebx, arr                                ; Move base address of arr into ebx
            
            mov ecx, [i]                                ; Move i, the outer loop index into ecx
            cmp ecx, arr_len                            ; Compare i, stored in ecx, to the length of the array
            jge outer_loop_end                          ; If i is greater than or equal to the length of the array, then we should exit the outer loop by jumping to outer_loop_end

            mov eax, [ebx + ecx*4]
            mov [smallest_element], eax                 ; Update smallest_element to hold the current element
            mov [smallest_index], ecx                   ; Update smallest_index to hold the current value of i, the iterator for the outer loop
            
           

            inner_loop_begin:
                mov ecx, [j]                            ; Move j, the inner loop index into ecx
                cmp ecx, arr_len                        ; Compare j, stored in ecx, to the length of the array
                jge inner_loop_end                      ; If j is greater than or equal to the length of the array, then we should exit the inner loop by jumping to inner_loop_end
     

                mov eax, [ebx + ecx*4]                  ; Move the element of arr at index j into eax
                cmp [smallest_element], eax             ; Compare the smallest element to the current element
                jle continue                            ; If the smallest element is smaller than the current element than continue
                
                mov [smallest_element], eax             ; Otherwise, we need to update the current smallest element and the index of the smallest element
                mov [smallest_index], ecx               

                continue:                           
                    inc dword [j]                       ; Increment the inner loop index, j
                    jmp inner_loop_begin                ; Jump to the start of the inner loop

            inner_loop_end:
                    
                mov ecx, [i]                            ; Move the value of i into ecx
                mov eax, [ebx + ecx*4]                  ; Move the element at index i of arr into eax
                mov [temp], eax                         ; Move the value stored in eax into temp
                mov ecx, [smallest_index]               ; Move the value of smallest_index into ecx
                mov eax, [ebx + ecx*4]                  ; Move the element at index smallest_index of arr into eax

                                                        ; Need to swap the smallest element with the element at index i
                mov ecx, [i]                            ; Move the value of i into ecx
                mov [ebx + ecx*4], eax                  ; Move the value of eax (the element at index smallest_index) into the element of arr at index i

                mov ecx, [smallest_index]               ; Move the value of smallest_index into ecx
                mov eax, [temp]                         ; Move the value of temp into eax
                mov [ebx+ ecx*4], eax                   ; Move the value stored in eax into the element at index smallest_index of arr

                inc dword [i]                           ; Increment the outer loop index, i
                mov eax, [i]                            ; Move the value of i into eax
                add eax, 1                              ; Add one to the value stored in eax, since the inner loop should step through elements after index i
                mov [j], eax                            ; Move the value stored in eax into j since we don't need to scan elements at indexes smaller than i anymore (at this point everything before i is already in the correct order)
                jmp outer_loop_begin                    ; Jump to the start of the outer loop




        outer_loop_end:
            mov [i], 0

            jmp print_array_begin

            print_sorted_array_end:
                jmp binary_search_begin


    binary_search_begin:
    
        mov ebx, arr                ; Move the base address of arr into ebx
        mov ecx, [high]               ; Move high index into ecx
        cmp [low], ecx              ; Compare low index to high index
        jg binary_search_end        ; If low is greater than high, then exit by jumping to binary_search_end


        mov eax, [high]               ; Move high index to eax
        add eax, [low]              ; Add low to high
        cdq                         ; Extend eax to edx:eax to prepare for division

        mov ecx, 2                  ; Move constant value 2 into ecx
        idiv ecx                    ; Divide by 2
        mov [mid], eax              ; Move the quotient into mid index


        mov ecx, [mid]              ; Move mid index into ecx
        mov eax, [ebx + ecx*4]      ; Move element at index mid into eax

                                    ; The following three comparisons are made:
        cmp [target], eax           
        jg greater_than             ; target > arr[mid]                
        jl less_than                ; target < arr[mid]
        je found                    ; target == arr[mid]

        greater_than:
                                    ; low = mid + 1
            inc dword [mid]         ; Increment mid by 1
            mov eax, [mid]          ; Move mid into eax
            mov [low], eax          ; Move value stored in eax into low
            jmp binary_search_begin ; Jump to the beginning of the binary_search section

        less_than:
                                    ; high = mid - 1
            dec dword [mid]         ; Decrement mid by 1
            mov eax, [mid]          ; Move mid into eax
            mov [high], eax         ; Move value stored in eax into high
            jmp binary_search_begin ; Jump to the beginning of the binary_search section


        found:
                                    ; target found
            mov eax, [mid]          ; Move mid into eax
            mov [result], eax       ; Move the value stored in eax into result

                                    ; Instructions needed for using C-language printf function
            mov rdi, fmt            
            mov esi, eax
            xor rax, rax
            call printf

            jmp binary_search_end   ; Jump to the binary_search_end section since the target was found
            
        binary_search_end:
            jmp end                 ; Jump to the end section to exit the program




    print_array_begin:
        
        mov ecx, [i]                ; Move the index, i, into ecx
        cmp ecx, arr_len            ; Compare i to the size of arr
        jge print_array_end         ; If i is greater than or equal to arr_len, then jump to the end and exit
            
        mov ebx, arr                ; Move the base address of arr into ebx
        mov eax, [ebx + ecx * 4]    ; Move the element of arr at index i into eax
        
        mov rdi, fmt
        mov esi, eax
        xor rax, rax

        call printf

        inc dword [i]
        jmp print_array_begin

    print_array_end:
        jmp print_sorted_array_end

end:
    xor rax, rax
    ret 



