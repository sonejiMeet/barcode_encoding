
.include "set_c_encoding.asm"

.eqv sys_ReadString 8
.eqv sys_ReadInt 5
.eqv sys_Exit 10
.eqv sys_PrintChar 11
.eqv sys_PrintString 4 

.text
.globl _main

_main:
    li a7, sys_PrintString
    la a0, value_prompt
    ecall

    li a7, sys_ReadString
    la a0, data_to_encode
    li a1, bufferLen
    ecall

    li a7, sys_PrintString
    la a0, barWidth_prompt
    ecall
    
    li a7, sys_ReadInt
    ecall

    la t0, bar_width  
    sb a0, 0(t0)

    la s0, data_to_encode

    la s1, encoded_data

    li s2, 105            #  start code value of set c is 105
    li s3, 1               # i = 1
    
    # its the beginning so append (start symbol) to encoded_data 
    la t0, start_c_encoding
    li t1, 6
    jal append_bytes

    li s4, 48     # '0'
    li s5, 57     # '9'

    li s6, 10  # ascii value for linefeed 

loop_start:
    lb t0, 0(s0)
    beq t0, s6, append_checksum  # end of input data if linefeed

    blt t0, s4, invalid_input_data  # exit with error
    bgt t0, s5, invalid_input_data

    lb t1, 1(s0)

    blt t1, s4, invalid_input_data
    bgt t1, s5, invalid_input_data

    # to concatenate one's place to ten's place
    addi t0, t0, -48
    addi t1, t1, -48
    
    # concatenate
    li t2, 10
    mul t3, t0, t2
    add t3, t3, t1


    # checksum += (i * data_value[i])
    mul t4, s3, t3      # s3 = current multiplier, t3 = datavalue
    add s2, s2, t4 
    addi s3, s3, 1   # i+1

    la t0, set_c_encoding
    li t1, 6
    mul t2, t3, t1        # find the bytes to offset, t3 = current datavalue
    add t0, t0, t2          # offset by that many bytes to reach our encoding
    jal append_bytes

    addi s0, s0, 2        # offset to 2 byte forward
    j loop_start

append_checksum:
    
    # checksum = (value) mod 103
    li t0, 103
    rem s2, s2, t0

    la t0, set_c_encoding
    li t1, 6
    mul t2, s2, t1        # offset = checksum * 6
    add t0, t0, t2
    jal append_bytes

    la t0, stop_c_encoding
    li t1, 7                # because stop symbol has extra bar as final bar
    jal append_bytes


# debug purpses ##############
    la s0, encoded_data

    li a7, sys_PrintString
    la a0, width_pattern
    ecall

print_loop:
    lb t0, 0(s0)
    beqz t0, convert
    
    li a7, sys_PrintChar
    addi a0, t0, 48
    ecall
    
    addi s0, s0, 1
    j print_loop

## end debug ############


invalid_input_data:
    li a7, sys_PrintString
    la a0, not_setC_error
	ecall

    li a7, 10
    ecall

append_bytes:
    add t2, t0, t1        
append_loop:
    lbu t3, 0(t0)         
    sb t3, 0(s1)          
    addi t0, t0, 1        
    addi s1, s1, 1        
    bne t0, t2, append_loop
    
    ret


.include "convert_to_bits.asm"  

convert:
    # jal x0, main2
    j main2

