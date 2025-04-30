section .bss
    img_width resd 1         
    img_height resd 1       
    pixel_offset resd 1

    bar_width resb 1 
    bar_height resb 1

    start_x_coordinate resw 1
    start_y_coordinate resb 1
section .data
    BMP_FILE_SIZE equ 90122
    BYTES_PER_ROW equ 1800
    fname db "output.bmp", 0

    bar_printed_length dd 1
    width_drawn db 1

    bar_height_iterator db 1

    quite_zone_bar_counter db 1
    quite_zone_bar_length db 1

    is_first_quite_zone_done db 1
section .text
global bmp, save_bmp, bar_width
global start_x_coordinate, start_y_coordinate, bar_height

extern input, image_buffer_ptr, ones_and_zeros_data, ones_and_zeros_length


bmp:
    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edi


    call read_bmp
    
    mov byte [bar_height], 20

    mov dword [bar_printed_length], 0

    xor eax,eax
    mov al, byte [start_y_coordinate]
    mov byte [bar_height_iterator], al
    
    mov byte [width_drawn], 0

    mov byte [quite_zone_bar_counter], 0
    mov byte [quite_zone_bar_length], 15

    mov byte [is_first_quite_zone_done], 0    
    xor cl, cl
    jmp checker

print_pixels:

    mov byte [quite_zone_bar_counter], 0
    mov byte [is_first_quite_zone_done], 1
    

    mov ax, [ones_and_zeros_length]
    mov cx, [bar_printed_length]
    cmp cx, ax
    je quite_zone
    
    mov edx, ones_and_zeros_data   ; load base address
    movzx eax, cx               ; length of bar printed so far
    add edx, eax               ; offset

    mov al, [edx]               ; load it from edx 
    cmp al, 0                  ; if its 0 then white otherwise black
    je white_pixel


black_pixel:
    call init_pixel
    push dword 0x0
    jmp pixel

white_pixel:
    call init_pixel
    push dword 0x00FFFFFF
    jmp pixel
    

init_pixel:
    
    movzx eax, word [start_x_coordinate]   ; move to next bar
    movzx ebx, byte [bar_height_iterator]
    ret

pixel:
    
    push dword ebx              ; y
    push dword eax              ; x
    mov esi, [image_buffer_ptr]
    push dword esi            ; image buffer ptr
    call put_pixel
    add esp, 16

    inc byte [bar_height_iterator]  ; move up on same y

    movzx eax, byte [bar_height]     ;height relative to starting y coordinate
    add al, byte [start_y_coordinate]
    cmp ebx, eax
    jb continue_drawing_vertical_bar
    
    mov cl, byte [start_y_coordinate]  ; reset y to start_y_coordinate 
    mov byte [bar_height_iterator], cl
    
    inc word [start_x_coordinate] ; mov to next x

    inc byte [width_drawn]                 ; next x position
    mov al, byte [width_drawn]   ; move to next bar
    mov cl, byte [bar_width]
    cmp al, cl
    jb print_pixels

    mov byte [width_drawn], 0  ; reset bar_width

    inc dword [bar_printed_length] 

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

    push dword 0x00FFFFFF
    push dword ebx              ; y
    push dword eax              ; x
    mov esi, [image_buffer_ptr]
    push dword esi            ; image buffer ptr
    call put_pixel
    add esp, 16

    inc byte [bar_height_iterator]  ; move up on same y

    movzx eax, byte [bar_height]     ;height relative to starting y coordinate
    add al, byte [start_y_coordinate]
    cmp ebx, eax
    jb continue_drawing_quite_bar
    
    mov cl, byte [start_y_coordinate]  ; reset y to start_y_coordinate 
    mov byte [bar_height_iterator], cl
    
    inc word [start_x_coordinate] ; mov to next x

    inc byte [width_drawn]                 ; next x position
    mov al, byte [width_drawn]   ; move to next bar
    mov cl, byte [bar_width]
    cmp al, cl
    jb quite_zone

    mov byte [width_drawn], 0  ; reset bar_width

    inc byte [quite_zone_bar_counter]
    jmp checker

continue_drawing_quite_bar:
    jmp checker

finished_quite_zone:
    mov al, byte [is_first_quite_zone_done]
    cmp al, 0
    je print_pixels


_exit:
    call save_bmp

    pop edi
    pop esi
    pop ebx

    ; epilogue
    mov esp, ebp
    pop ebp

    mov eax, 0
    ret

read_bmp:

    ; open
    mov eax, 5         ; open syscall
    mov ebx, fname
    xor ecx, ecx         ; read-only mode
    int 0x80

    cmp eax, 0
    jl file_open_error
    mov esi, eax        ; store file descriptor

    ; read
    mov eax, 3         ; read syscall
    mov ebx, esi       ; file descriptor
    
    mov esi, [image_buffer_ptr]
    lea ecx, [esi]
    mov edx, BMP_FILE_SIZE  ; size
    int 0x80

    mov eax, 6              ; close syscall
    mov ebx, esi            ; file descriptor
    int 0x80

    ; parse  header
    lea ebx, [esi]
    mov eax, [ebx + 10]     ; Read pixel array offset
    mov [pixel_offset], eax

    mov eax, [ebx + 18]
    mov [img_width], eax

    mov eax, [ebx + 22]
    mov [img_height], eax

    ret

file_open_error:
  
    add esp, 4
    mov eax, 2

    jmp exit

save_bmp:
    mov eax, 5      ; open
    mov ebx, fname
    mov ecx, 1     ; write only
    int 0x80

    cmp eax, 0
    jl file_save_error

    mov esi, eax            ; store file descriptor

    mov eax, 4   ; write syscall
    mov ebx, esi
    
    mov esi, [image_buffer_ptr]
    lea ecx, [esi]
    mov edx, BMP_FILE_SIZE
    int 0x80

    mov eax, 6    ; close syscall
    mov ebx, esi
    int 0x80


    ret

file_save_error:

    add esp, 4
    mov eax, 3
    jmp exit

put_pixel:
    push ebp
    mov ebp, esp

    mov esi, [ebp + 8]        ; img buffer
    mov eax, [ebp + 12]       ; starting x
    mov ebx, [ebp + 16]       ; starting y
    mov ecx, [ebp + 20]       ; color

    mov edx, [img_width]
    cmp eax, edx
    jae invalid_pixel_offset

    mov edx, [img_height]
    cmp ebx, edx
    jae invalid_pixel_offset


    mov edx, [pixel_offset]
    add esi, edx

    mov edx, ebx
    imul edx, BYTES_PER_ROW ; y * bytes per row
    add esi, edx

    mov edx, eax
    imul edx, 3      ; x * 3 (3 bytes per pixel)
    add esi, edx

    mov al, cl       ; blue
    mov [esi], al
    shr ecx, 8
    mov al, cl       ; green
    mov [esi + 1], al
    shr ecx, 8
    mov al, cl       ; red
    mov [esi + 2], al

    pop ebp
    ret

invalid_pixel_offset:

    add esp, 24
    pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    
    mov eax, 4
    leave
    ret
    
exit:
    pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    
    ret