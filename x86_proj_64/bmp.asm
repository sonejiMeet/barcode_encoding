section .bss
    img_width  resq 1
    img_height resq 1
    pixel_offset resq  1

    bar_width resb 1
    bar_height resb 1

    start_x_coordinate resw 1
    start_y_coordinate resb 1

section .data
    BMP_FILE_SIZE equ 90122
    BYTES_PER_ROW equ 1800

    fname db "output.bmp", 0

    bar_printed_length dq  1
    width_drawn  db 1

    bar_height_iterator db 1
    
    quite_zone_bar_counter db 1
    quite_zone_bar_length db 1

    is_first_quite_zone_done db 1
section .text
    global bmp, save_bmp, bar_width
    global start_x_coordinate, start_y_coordinate, bar_height

    extern input, image_buffer_ptr, ones_and_zeros_data, ones_and_zeros_length


bmp:
    push rbp
    mov rbp, rsp

    push rbx
    push rsi
    push rdi

    call read_bmp

    mov byte [bar_height], 20

    mov qword [bar_printed_length], 0

    xor rax, rax
    mov al, byte [start_y_coordinate]
    mov byte [bar_height_iterator], al
    
    mov byte [width_drawn], 0

    mov byte [quite_zone_bar_counter], 0
    mov byte [quite_zone_bar_length], 10

    mov byte [is_first_quite_zone_done], 0    
    
    xor rcx, rcx
    
    jmp checker
    
print_pixels:
    
    mov byte [quite_zone_bar_counter], 0
    mov byte [is_first_quite_zone_done], 1

    mov ax, [ones_and_zeros_length]    
    mov cx, [bar_printed_length]
    cmp ax, cx
    je quite_zone
    
    mov rdx, ones_and_zeros_data   ; load base address
    movzx rax, cx               ; length of bar printed so far
    add rdx, rax               ; offset

    mov al, [rdx]               ; load it from edx 
    cmp al, 0                  ; if its 0 then white otherwise black
    je white_pixel

black_pixel:
    call init_pixel
    mov ecx, 0x0
    jmp pixel

white_pixel:
    call init_pixel
    mov ecx, 0x00FFFFFF
    jmp pixel

init_pixel:
    movzx rax, word [start_x_coordinate]   ; move to next bar
    movzx rbx, byte [bar_height_iterator]
    ret

pixel:
    
    mov rdi, [image_buffer_ptr]
    mov rsi, rax                ; x
    mov rdx, rbx                ; y
    call put_pixel

    inc byte [bar_height_iterator]

    movzx rax, byte [bar_height]     ;height relative to starting y coordinate
    add al, byte [start_y_coordinate]
    cmp rbx, rax
    jb continue_drawing_vertical_bar
    
    mov cl, byte [start_y_coordinate]  ; reset y to start_y_coordinate 
    mov byte [bar_height_iterator], cl
    
    inc word [start_x_coordinate] ; mov to next x

    inc byte [width_drawn]                 ; next x position
    
    mov al, byte [width_drawn]   ; move to next bar
    mov cl, byte [bar_width]
    cmp al, cl
    jb print_pixels

    mov byte [width_drawn], 0   ; reset bar_width

    inc qword [bar_printed_length]

continue_drawing_vertical_bar:
    jmp print_pixels


checker:
    mov dl, byte [quite_zone_bar_counter]
    mov al, byte [quite_zone_bar_length] 
    cmp dl, al
    je finished_quite_zone
quite_zone:


    movzx eax, word [start_x_coordinate]   ; move to next bar
    movzx ebx, byte [bar_height_iterator]

    mov rdi, [image_buffer_ptr]
    mov rsi, rax                ; x
    mov rdx, rbx                ; y
    mov ecx, 0x00FFFFFF
    call put_pixel

    inc byte [bar_height_iterator]

    movzx rax, byte [bar_height]     ;height relative to starting y coordinate
    add al, byte [start_y_coordinate]
    cmp rbx, rax
    jb continue_drawing_quite_bar
    
    mov cl, byte [start_y_coordinate]  ; reset y to start_y_coordinate 
    mov byte [bar_height_iterator], cl
    
    inc word [start_x_coordinate] ; mov to next x

    inc byte [width_drawn]                 ; next x position
    
    mov al, byte [width_drawn]   ; move to next bar
    mov cl, byte [bar_width]
    cmp al, cl
    jb quite_zone

    mov byte [width_drawn], 0   ; reset bar_width

    inc byte [quite_zone_bar_counter]
    jmp checker

continue_drawing_quite_bar:
    jmp checker

finished_quite_zone:
    mov al, byte [is_first_quite_zone_done]
    cmp al, 0
    je print_pixels

exit_with_success:
    call save_bmp

    mov rax, 0
    ; jmp exit
        pop rdi
    pop rsi
    pop rbx

    mov rsp, rbp
    pop rbp

    ret

read_bmp:
    mov rax, 2     ; sys_open
    lea rdi, [rel fname]
    mov rsi, 0
    mov rdx, 0
    syscall

    cmp rax, 0
    jl file_open_error
    mov rbx, rax

    mov rax, 0    ; sys_read
    mov rdi, rbx
    mov rsi, [image_buffer_ptr]
    mov rdx, BMP_FILE_SIZE
    syscall

    mov rax, 3      ; sys_close
    mov rdi, rbx           
    syscall

    ; parse header
    mov rbx, [image_buffer_ptr]

    mov eax, [rbx + 10]    ;DataOffset
    mov [pixel_offset], rax

    mov eax, [rbx + 18]  ; Bitmap width
    mov [img_width], rax

    mov eax, [rbx + 22] ; Bitmap height
    mov [img_height], rax

    ret

file_open_error:
    mov rax, 2
    jmp exit

save_bmp:
    mov rax, 2
    lea rdi, [rel fname]
    mov rsi, 1
    mov rdx, 0
    syscall

    cmp rax, 0
    jl file_save_error
    mov rbx, rax

    mov rax, 1  ; sys_write
    mov rdi, rbx 
    mov rsi, [image_buffer_ptr]
    mov rdx, BMP_FILE_SIZE
    syscall

    mov rax, 3   ; sys_close
    mov rdi, rbx
    syscall

    ret

file_save_error:
    mov rax, 3
    jmp exit

put_pixel:
    push rbp
    mov rbp, rsp

    mov rax, [img_width]
    cmp rsi, rax
    jae invalid_pixel_offset

    mov rax, [img_height]
    cmp rdx, rax
    jae invalid_pixel_offset

    mov rax, [pixel_offset]
    imul rdx, BYTES_PER_ROW
    add rax, rdx          ; rax += y * BYTES_PER_ROW
    imul rsi, 3           ; x * 3
    add rax, rsi          ; rax += x * 3
    add rax, rdi          ; image_buffer_ptr + pixel_offset + ( y * BYTES_PER_ROW ) + ( x * 3 )


    mov byte [rax], cl       ; blue

    shr rcx, 8
    mov byte [rax + 1], cl    ; green

    shr rcx, 8
    mov byte [rax + 2], cl   ; red

    pop rbp
    ret

invalid_pixel_offset:
    
    mov rax, 4
    leave 

exit:
    pop rdi
    pop rsi
    pop rbx

    mov rsp, rbp
    pop rbp

    ret