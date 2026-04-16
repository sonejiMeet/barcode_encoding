# convert_to_bits.asm

.eqv sys_ReadString 8
.eqv sys_ReadInt 5
.eqv sys_Exit 10
.eqv sys_PrintChar 11
.eqv sys_PrintString 4 
# encoded_data:
    # .byte 2,1,1,2,3,2,2,2,1,2,3,1,2,2,3,2,1,1,3,1,2,3,1,1,2,3,3,1,1,1,2,0
    # .byte 2,1,1,1,4
    # .byte 0
# sequence_of_bits:
    # .space 200
.text

# data
.extern encoded_data 0
.extern sequence_of_bits 0

# output strings
.extern ones_and_zeros_pattern 0
.extern lenght_of_sequence_of_bits 0

main2:

    la s0, encoded_data
    la s1, sequence_of_bits
    li t1, 1        # index counter
    li t5, 0
loop:
    lb t0, (s0)
    beqz t0, print

    andi t2, t1, 1  # check if curent index counter is even or odd
    beqz t2, zeros  # if its even append 0's
    j ones

move_to_next_byte:
    addi t1, t1, 1 # current index counter
    addi s0, s0, 1 # move to next byte
    j loop

zeros:
    li t4, 0
    j init_append
ones:
    li t4, 1

init_append:
    mv t3, t0          
    li t2, 0           # reset counter for number of 1's or 0's have been appended

append:

    beq t2, t3, move_to_next_byte
    sb t4, 0(s1)
    addi s1, s1, 1
    addi t2, t2, 1
    addi t5, t5, 1
    j append

print:
    li a7, sys_PrintString
    la a0, ones_and_zeros_pattern
    ecall
    
    la s1, sequence_of_bits
    li t3, 0
print_loop1:
    lb t0, 0(s1)
    beq t3, t5, exit 

    li a7, sys_PrintChar
    addi a0, t0, 48
    ecall

    addi s1, s1, 1
    addi t3, t3, 1
    j print_loop1

.include "bmp.asm"
exit:

    la t0, lenght_of_sequence_of_bits
    sb t5, 0(t0) 
    # li a7, 1
    # la t0, lenght_of_sequence_of_bits
    # lb a0, 0(t0)
    # ecall
    # la t0, bar_width
    # lb a0, 0(t0)
    # li a7, 1
    # ecall

    # li a7, sys_Exit                 
    # ecall
    
    jal x0, main3


