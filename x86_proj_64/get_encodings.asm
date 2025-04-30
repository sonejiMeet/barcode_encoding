section   .bss
    image_buffer_ptr resq 1

encoded_data:
    resb 512
encoded_data_length:
    resq 1

section .text
global get_encodings, encoded_data, encoded_data_length, image_buffer_ptr

extern set_c_encoding, input, start_c_encoding, stop_c_encoding, bar_width
extern convert_bits
extern start_x_coordinate, start_y_coordinate ,bar_height
 

get_encodings:

    push rbp
    mov rbp, rsp

    push rbx
    push rsi
    push rdi
    
    mov [image_buffer_ptr], rdi
    mov [input], rsi
    mov [bar_width], rdx
    mov [start_x_coordinate], rcx
    mov [start_y_coordinate], r8


    mov rbx, [input]
    mov rdi, encoded_data

    ; checksum and weight initalizer
    xor rax, rax
    push rax
    mov rax, 1
    push rax

; append start encoding
    push rcx
    mov rcx, 6
    mov rsi, start_c_encoding
    call append_bytes
    pop rcx

    mov rax, rdi                 
    sub rax, encoded_data       
    mov [encoded_data_length], rax 
; endof

loop_start:

    mov al, [rbx]    ; first digit
    cmp al, 0
    je calculate_checksum

    cmp al, 48
    jl error_non_numeric
    cmp al, 57
    jg error_non_numeric

    sub al, '0'     ; ascii to decimal
    mov rcx, 10    
    mul rcx    ; multiply by 10

    mov dl, [rbx + 1]  ; second digit
    cmp dl, 0           ; check for linefeed
    je error_odd_length_digits
    
    cmp dl, 48
    jl error_non_numeric
    cmp dl, 57
    jg error_non_numeric

    sub dl, '0'   ; ascii to decimal
    add rax, rdx    ; concatenate
    push rax    ; need to push it because right after this 

    mov rsi, set_c_encoding  ; load base address of table
    mov rcx, 6              
    mul rcx                   
    add rsi, rax         ; move this offset to rsi because append_bytes will use it

    push rcx
    mov rcx, 6
    call append_bytes
    pop rcx
    

    pop rax     ; current data value 

    pop rcx          ;  weight from before
    pop rdx          ; checksum
    
    imul rax, rcx
    add rdx, rax    ; update checksum
    push rdx     ; and push it back to stack

    inc rcx     ; increment index
    push rcx
    
    mov rax, rdi                 
    sub rax, encoded_data       
    mov [encoded_data_length], rax      

    add rbx, 2                ; Move to the next input pair
    jmp loop_start

calculate_checksum:
    pop rcx   ; not needed
    pop rdx       ; checksum result before mod
    
    cmp rdx, 0   ; kind of an hack for error handling empty data string passed
    je error_empty_data
    
    add rdx, 105  ; add it to start_symbol_value
   
    xor rax, rax  
    mov rax, rdx
    xor rdx, rdx              
    push rdx
    mov rcx, 103
    div rcx    ; rdx = rax % 103

    
    mov rax, rdx              
    imul rax, 6
    mov rsi, set_c_encoding
    add rsi, rax

    push rcx
    mov rcx, 6
    call append_bytes
    pop rcx

    pop rdx

stop_bytes:
    ; Append stop encoding
    push rcx
    mov rcx, 7
    mov rsi, stop_c_encoding
    call append_bytes
    pop rcx

    mov rax, rdi                 
    sub rax, encoded_data       
    mov [encoded_data_length], rax 
    ; endof

    jmp next_funciton_call

append_bytes:
    append_loop:
        mov al, [rsi]
        mov [rdi], al
        inc rsi
        inc rdi
        loop append_loop
    ret

exit_with_error:
    ; epilogue
    pop rdi
    pop rsi
    pop rbx

    mov rsp, rbp
    pop rbp
    ; endof
     
    ret 

error_non_numeric:
    pop rax
    pop rax

    mov eax, 1
    jmp exit_with_error

error_empty_data:

    mov eax, 5
    jmp exit_with_error

error_odd_length_digits:
    pop rax
    pop rax

    mov eax, 6
    jmp exit_with_error


next_funciton_call:

    ; epilogue
    pop rdi
    pop rsi
    pop rbx

    mov rsp, rbp
    pop rbp
    ; endof

    jmp convert_bits
