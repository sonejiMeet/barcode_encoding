section   .bss
    image_buffer_ptr resd 1

encoded_data:
    resb 512
encoded_data_length:
    resd 1

section .text
global get_encodings, encoded_data, encoded_data_length, image_buffer_ptr

extern set_c_encoding, input, start_c_encoding, stop_c_encoding, bar_width
extern convert_bits
extern start_x_coordinate, start_y_coordinate, bar_height
 

get_encodings:

    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]
    mov edi, [ebp + 12]
    mov [input], edi
    mov edi, [ebp + 16]
    mov [bar_width], edi
    mov edi, [ebp + 20]
    mov [start_x_coordinate], edi
    mov edi, [ebp + 24]
    mov [start_y_coordinate], edi

    mov [image_buffer_ptr], esi

    mov ebx, [input]
    mov edi, encoded_data

    ; checksum and weight initalizer
    xor eax, eax
    push eax
    mov eax, 1
    push eax

; append start encoding
    push ecx
    mov ecx, 6
    mov esi, start_c_encoding
    call append_bytes
    pop ecx

    mov eax, edi                 
    sub eax, encoded_data       
    mov [encoded_data_length], eax 
; endof

loop_start:

    mov al, [ebx]    ; first digit
    cmp al, 0
    je calculate_checksum

    cmp al, 48
    jl error_non_numeric
    cmp al, 57
    jg error_non_numeric

    sub al, '0'     ; ascii to decimal
    mov ecx, 10    
    mul ecx    ; multiply by 10

    mov dl, [ebx + 1]  ; second digit
    cmp dl, 0           ; check for linefeed
    je error_odd_length_digits
    
    cmp dl, 48
    jl error_non_numeric
    cmp dl, 57
    jg error_non_numeric

    sub dl, '0'   ; ascii to decimal
    add eax, edx    ; concatenate
    push eax    ; need to push it because right after this 

    mov esi, set_c_encoding  ; load base address of table
    mov ecx, 6              
    mul ecx                   
    add esi, eax         ; move this offset to esi because append_bytes will use it

    push ecx
    mov ecx, 6
    call append_bytes
    pop ecx
    

    pop eax     ; current data value 

    pop ecx          ;  weight from before
    pop edx          ; checksum
    
    imul eax, ecx
    add edx, eax    ; update checksum
    push edx     ; and push it back to stack

    inc ecx     ; increment index
    push ecx
    
    mov eax, edi                 
    sub eax, encoded_data       
    mov [encoded_data_length], eax      

    add ebx, 2                ; Move to the next input pair
    jmp loop_start

calculate_checksum:
    pop ecx   ; not needed
    pop edx       ; checksum result before mod
    
    cmp edx, 0   ; kind of an hack for error handling empty data string passed
    je error_empty_data
    
    add edx, 105  ; add it to start_symbol_value
   
    xor eax, eax  
    mov eax, edx
    xor edx, edx              
    push edx
    mov ecx, 103
    div ecx    ; edx = eax % 103

    
    mov eax, edx              
    imul eax, 6
    mov esi, set_c_encoding
    add esi, eax

    push ecx
    mov ecx, 6
    call append_bytes
    pop ecx

    pop edx

stop_bytes:
    ; Append stop encoding
    push ecx
    mov ecx, 7
    mov esi, stop_c_encoding
    call append_bytes
    pop ecx

    mov eax, edi                 
    sub eax, encoded_data       
    mov [encoded_data_length], eax 
    ; endof

    jmp next_funciton_call
    

append_bytes:
    append_loop:
        mov al, [esi]
        mov [edi], al
        inc esi
        inc edi
        loop append_loop
    ret

exit_with_error:
    ; epilogue
    pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    ; endof
    ret 

error_non_numeric:
    pop eax
    pop eax

    mov eax, 1
    jmp exit_with_error

error_empty_data:

    mov eax, 5
    jmp exit_with_error

error_odd_length_digits:
    pop eax
    pop eax

    mov eax, 6
    jmp exit_with_error


next_funciton_call:

    ; epilogue
    pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    ; endof

    jmp convert_bits
