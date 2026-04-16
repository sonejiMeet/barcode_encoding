    .eqv    bufferLen,   100
    
    .data 
value_prompt:
    .asciz "Enter the numeric value to be encoded: \n"
barWidth_prompt:
    .asciz "Enter the bar width in pixels of the narrowest bar: \n"

width_pattern:
    .asciz "\nThe width pattern of data is: \n"
ones_and_zeros_pattern:
    .asciz "\n\nThe ones_and_zeros_pattern of data is: \n"

bmp_success:
    .asciz "\n\nSuccess: output in source.bmp\n"

not_setC_error:
    .asciz "\n\nERROR: Input data is either invalid lenght or has non numeric values.\nExiting...\n"
    
bar_width:
    .byte 0
data_to_encode:
	.space bufferLen
encoded_data:
    .space bufferLen

sequence_of_bits:
    .space bufferLen

lenght_of_sequence_of_bits:
    .byte 0


start_c_encoding:
	.byte 2,1,1,2,3,2

stop_c_encoding:
	.byte 2,3,3,1,1,1,2

set_c_encoding:		# only the 100 codes that are needed. start and stop are explicitly defined above
	.byte 2,1,2,2,2,2
    .byte 2,2,2,1,2,2
    .byte 2,2,2,2,2,1
    .byte 1,2,1,2,2,3
    .byte 1,2,1,3,2,2
    .byte 1,3,1,2,2,2
    .byte 1,2,2,2,1,3
    .byte 1,2,2,3,1,2
    .byte 1,3,2,2,1,2
    .byte 2,2,1,2,1,3
    .byte 2,2,1,3,1,2
    .byte 2,3,1,2,1,2
    .byte 1,1,2,2,3,2
    .byte 1,2,2,1,3,2
    .byte 1,2,2,2,3,1
    .byte 1,1,3,2,2,2
    .byte 1,2,3,1,2,2
    .byte 1,2,3,2,2,1
    .byte 2,2,3,2,1,1
    .byte 2,2,1,1,3,2
    .byte 2,2,1,2,3,1
    .byte 2,1,3,2,1,2
    .byte 2,2,3,1,1,2
    .byte 3,1,2,1,3,1
    .byte 3,1,1,2,2,2
    .byte 3,2,1,1,2,2
    .byte 3,2,1,2,2,1
    .byte 3,1,2,2,1,2
    .byte 3,2,2,1,1,2
    .byte 3,2,2,2,1,1
    .byte 2,1,2,1,2,3
    .byte 2,1,2,3,2,1
    .byte 2,3,2,1,2,1
    .byte 1,1,1,3,2,3
    .byte 1,3,1,1,2,3
    .byte 1,3,1,3,2,1
    .byte 1,1,2,3,1,3
    .byte 1,3,2,1,1,3
    .byte 1,3,2,3,1,1
    .byte 2,1,1,3,1,3
    .byte 2,3,1,1,1,3
    .byte 2,3,1,3,1,1
    .byte 1,1,2,1,3,3
    .byte 1,1,2,3,3,1
    .byte 1,3,2,1,3,1
    .byte 1,1,3,1,2,3
    .byte 1,1,3,3,2,1
    .byte 1,3,3,1,2,1
    .byte 3,1,3,1,2,1
    .byte 2,1,1,3,3,1
    .byte 2,3,1,1,3,1
    .byte 2,1,3,1,1,3
    .byte 2,1,3,3,1,1
    .byte 2,1,3,1,3,1
    .byte 3,1,1,1,2,3
    .byte 3,1,1,3,2,1
    .byte 3,3,1,1,2,1
    .byte 3,1,2,1,1,3
    .byte 3,1,2,3,1,1
    .byte 3,3,2,1,1,1
    .byte 3,1,4,1,1,1
    .byte 2,2,1,4,1,1
    .byte 4,3,1,1,1,1
    .byte 1,1,1,2,2,4
    .byte 1,1,1,4,2,2
    .byte 1,2,1,1,2,4
    .byte 1,2,1,4,2,1
    .byte 1,4,1,1,2,2
    .byte 1,4,1,2,2,1
    .byte 1,1,2,2,1,4
    .byte 1,1,2,4,1,2
    .byte 1,2,2,1,1,4
    .byte 1,2,2,4,1,1
    .byte 1,4,2,1,1,2
    .byte 1,4,2,2,1,1
    .byte 2,4,1,2,1,1
    .byte 2,2,1,1,1,4
    .byte 4,1,3,1,1,1
    .byte 2,4,1,1,1,2
    .byte 1,3,4,1,1,1
    .byte 1,1,1,2,4,2
    .byte 1,2,1,1,4,2
    .byte 1,2,1,2,4,1
    .byte 1,1,4,2,1,2
    .byte 1,2,4,1,1,2
    .byte 1,2,4,2,1,1
    .byte 4,1,1,2,1,2
    .byte 4,2,1,1,1,2
    .byte 4,2,1,2,1,1
    .byte 2,1,2,1,4,1
    .byte 2,1,4,1,2,1
    .byte 4,1,2,1,2,1
    .byte 1,1,1,1,4,3
    .byte 1,1,1,3,4,1
    .byte 1,3,1,1,4,1
    .byte 1,1,4,1,1,3
    .byte 1,1,4,3,1,1
    .byte 4,1,1,1,1,3
    .byte 4,1,1,3,1,1
    .byte 1,1,3,1,4,1
    # .byte 1,1,4,1,3,1
    # .byte 3,1,1,1,4,1
    # .byte 4,1,1,1,3,1
    # .byte 2,1,1,4,1,2
    # .byte 2,1,1,2,1,4
    # .byte 2,1,1,2,3,2
    # .byte 2,3,3,1,1,1,2
