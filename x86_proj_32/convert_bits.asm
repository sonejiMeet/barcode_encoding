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

    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edi

    lea esi, [encoded_data]
    xor edx, edx
    lea edx, [ones_and_zeros_data]

    mov ecx, 1  ; for odd or even encoded value


loop_:

    mov al, [esi]
    cmp al, 0
    jz exit

    and ecx, 1
    cmp ecx, 0   ; if ecx is 0 then index is even so append zeros
    je zeros
    jne ones    ; otherwise ones

move_next_byte:
    inc esi
    inc ecx
    jmp loop_

zeros:
    mov bl, 0
    jmp append_bits
ones:
    mov bl, 1

append_bits:
    cmp al, 0
    je move_next_byte
    mov [edx], bl
    inc edx
    dec al
    jmp append_bits

exit:
    mov eax, edx      ; get the last address of bit stored
    mov ebx, ones_and_zeros_data
    sub eax, ebx

    mov [ones_and_zeros_length], eax
    pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp

    jmp bmp
