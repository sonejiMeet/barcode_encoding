section .bss

ones_and_zeros_data:
    resb 512
ones_and_zeros_length:
    resd 1

section .text

global convert_bits, ones_and_zeros_data, ones_and_zeros_length

extern encoded_data, encoded_data_length
extern bmp

convert_bits:

    push rbp
    mov rbp, rsp

    push rbx
    push rsi
    push rdi

    lea rsi, [encoded_data]
    xor rdx, rdx
    lea rdx, [ones_and_zeros_data]

    mov rcx, 1  ; for odd or even encoded value


loop_:

    mov al, [rsi]
    cmp al, 0
    jz exit

    and rcx, 1
    cmp rcx, 0   ; if rcx is 0 then index is even so append zeros 
    je zeros    
    jne ones    ; otherwise ones

move_next_byte:
    inc rsi
    inc rcx
    jmp loop_

zeros:
    mov bl, 0
    jmp append_bits
ones:
    mov bl, 1

append_bits:
    cmp al, 0
    je move_next_byte
    mov [rdx], bl
    inc rdx
    dec al
    jmp append_bits

exit:
    mov rax, rdx      ; get the last address of bit stored
    mov rbx, ones_and_zeros_data  
    sub rax, rbx
    
    mov [ones_and_zeros_length], rax
    pop rdi
    pop rsi
    pop rbx

    mov rsp, rbp
    pop rbp

    jmp bmp
    ; ret