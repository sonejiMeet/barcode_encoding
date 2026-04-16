#-------------------------------------------------------------------------------
#author: Zbigniew Szymanski
#data : 2021.07.02
#description : example RISC V program for reading, modifying and writing a BMP file
#-------------------------------------------------------------------------------
#https://github.com/TheThirdOne/rars/wiki
#only 24-bits 600x50 pixels BMP files are supported
.eqv BMP_FILE_SIZE 90122
.eqv BYTES_PER_ROW 1800

.eqv sys_ReadString 8
.eqv sys_ReadInt 5
.eqv sys_Exit 10
.eqv sys_PrintChar 11
.eqv sys_PrintString 4

	.data


# output externs
.extern bmp_success 0


# data externs
.extern sequence_of_bits 0
# input:
# 	.byte 1,1,0,1,0,0,1,1,1,0,0 , 1,1,0,0,1,0,0,1,1,1,0 , 1,1,0,0,1,1,1,0,0,1,0 , 1,1,1,0,1,1,0,0,0,1,0 , 1,1,0,0,0,1,1,1,0,1,0,1,1
.extern lenght_of_sequence_of_bits 0
# input_len:
# 	.word 57

.extern bar_width 0
# bar_width:
# 	.word 1

bar_height:
	.word 20
start_x_coordinate:
	.word 50
start_y_coordinate:
	.word 15

#space for the 600x50px 24-bits bmp image
.align 4
res:	.space 2
image:	.space BMP_FILE_SIZE

fname:	.asciz "source.bmp"
	.text

main3:
    jal read_bmp

	la s0, sequence_of_bits
	lb s1, lenght_of_sequence_of_bits

	lw t0, start_x_coordinate
    li s3, 0 				#  for keeping count of how many 1's and 0's are printed to bmp file

    lb s2, bar_width
    lw s4, start_y_coordinate

    lw t5, bar_height
    li t6, 0                 # counter for every bar width drawn

	# for quitezones
	li s7, 10                 # Number of bars to print

	li s6, 0	# number of bars printed in quitezone
	li s8, 0
    li a2, 0x0033cccc

	j print_quitezone

print_pixels:

	li s6, 0
	li s8, 1
    bge s3, s1, print_quitezone
    # bge s3, s1, done_pixels

	# bit value
    lb t4, (s0)

    beqz t4, white_pixel
    li a2, 0x00000000
    j draw_pixel

white_pixel:
    li a2, 0x0033cccc

draw_pixel:
    mv a0, t0
    mv a1, s4
    jal put_pixel

    addi s4, s4, 1 # move up on same y

    lw s5, start_y_coordinate
    add s5, s5, t5	# height relative to starting y coordinate
    blt s4, s5, continue_drawing_vertical_bar

    lw s4, start_y_coordinate # reset for next bar
    addi t0, t0, 1


    addi t6, t6, 1 # counter for widths drawn
    blt t6, s2, print_pixels

    li t6, 0 # reset when moving to next bit
    addi s0, s0, 1
    addi s3, s3, 1
    j print_pixels

continue_drawing_vertical_bar:
    j print_pixels

done_pixels:

	jal save_bmp

	li a7, sys_PrintString
    la a0, bmp_success
	ecall

end:
    li a7, sys_Exit
    ecall


# quite zone printing

print_quitezone:

	beq s6, s7, finished_white_bar

	mv a0, t0
    mv a1, s4
	li a2, 0x0033cccc
    jal put_pixel

    addi s4, s4, 1

    lw s5, start_y_coordinate
    add s5, s5, t5            # start_y + bar_height
    blt s4, s5, continue

    lw s4, start_y_coordinate
    addi t0, t0, 1

	addi t6, t6, 1 # counter for widths drawn
    blt t6, s2, go_next

    li t6, 0 # reset when moving to next bit

	j go_next

continue:
	j print_quitezone

go_next:
	addi s6, s6, 1
	j print_quitezone

finished_white_bar:
	beqz s8, print_pixels
	j done_pixels




# ============================================================================
read_bmp:
#description:
#	reads the contents of a bmp file into memory
#arguments:
#	none
#return value: none
	addi sp, sp, -4		#push $s1
	sw s1, 0(sp)
#open file
	li a7, 1024
        la a0, fname		#file name
        li a1, 0		#flags: 0-read file
        ecall
	mv s1, a0      # save the file descriptor

#check for errors - if the file was opened
#...



#read file
	li a7, 63
	mv a0, s1
	la a1, image
	li a2, BMP_FILE_SIZE
	ecall

#close file
	li a7, 57
	mv a0, s1
        ecall

	lw s1, 0(sp)		#restore (pop) s1
	addi sp, sp, 4
	jr ra

# ============================================================================
save_bmp:
#description:
#	saves bmp file stored in memory to a file
#arguments:
#	none
#return value: none
	addi sp, sp, -4		#push s1
	sw s1, (sp)
#open file
	li a7, 1024
        la a0, fname		#file name
        li a1, 1		#flags: 1-write file
        ecall
	mv s1, a0      # save the file descriptor

#check for errors - if the file was opened
#...

#save file
	li a7, 64
	mv a0, s1
	la a1, image
	li a2, BMP_FILE_SIZE
	ecall

#close file
	li a7, 57
	mv a0, s1
        ecall

	lw s1, (sp)		#restore (pop) $s1
	addi sp, sp, 4
	jr ra


# ============================================================================
put_pixel:
#description:
#	sets the color of specified pixel
#arguments:
#	a0 - x coordinate
#	a1 - y coordinate - (0,0) - bottom left corner
#	a2 - 0RGB - pixel color
#return value: none

	la t1, image	#adress of file offset to pixel array
	addi t1,t1,10
	lw t2, (t1)		#file offset to pixel array in $t2
	la t1, image		#adress of bitmap
	add t2, t1, t2	#adress of pixel array in $t2

	#pixel address calculation
	li t4,BYTES_PER_ROW
	mul t1, a1, t4 #t1= y*BYTES_PER_ROW
	mv t3, a0
	slli a0, a0, 1
	add t3, t3, a0	#$t3= 3*x
	add t1, t1, t3	#$t1 = 3x + y*BYTES_PER_ROW
	add t2, t2, t1	#pixel address

	#set new color
	sb a2,(t2)		#store B
	srli a2,a2,8
	sb a2,1(t2)		#store G
	srli a2,a2,8
	sb a2,2(t2)		#store R

	jr ra
# ============================================================================
get_pixel:
#description:
#	returns color of specified pixel
#arguments:
#	a0 - x coordinate
#	a1 - y coordinate - (0,0) - bottom left corner
#return value:
#	a0 - 0RGB - pixel color

	la t1, image		#adress of file offset to pixel array
	addi t1,t1,10
	lw t2, (t1)		#file offset to pixel array in $t2
	la t1, image		#adress of bitmap
	add t2, t1, t2		#adress of pixel array in $t2

	#pixel address calculation
	li t4,BYTES_PER_ROW
	mul t1, a1, t4 		#t1= y*BYTES_PER_ROW
	mv t3, a0
	slli a0, a0, 1
	add t3, t3, a0		#$t3= 3*x
	add t1, t1, t3		#$t1 = 3x + y*BYTES_PER_ROW
	add t2, t2, t1	#pixel address

	#get color
	lbu a0,(t2)		#load B
	lbu t1,1(t2)		#load G
	slli t1,t1,8
	or a0, a0, t1
	lbu t1,2(t2)		#load R
        slli t1,t1,16
	or a0, a0, t1

	jr ra

# ============================================================================
