.data
array1: .word 5,6,7,8,1,2,3,9,10,4
size1: 	.word 10

array2: .byte 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
size2: 	.word 16

array3: .space 8
size3: 	.word 8

msg_array1: 		.asciiz "\Phan tu mang 1:\n"
msg_array2: 		.asciiz "\nPhan tu mang 2:\n"
msg_select_array: 	.asciiz "\nMang bao nhieu (1 = array1, 2 = array2, 3 = array3): "
msg_select_index: 	.asciiz "Chi so phan tu: "
msg_error:		.asciiz "Nhap sai, vui long nhap lai\n"
msg_space:		.asciiz " "

.text
main: 
#In phan tu mang 1	
	la $t0, array1
	lw $t1, size1 # Siae array1 = 40 bytes
	
	li $v0, 4
	la $a0, msg_array1 # In thong bao array1
	syscall

print_array1_loop:
	beq $t1, $zero, print_array2 # Neu t1=0, nhay toi in mang 2
	lw $a0, 0($t0)
	li $v0, 1
	syscall
	
	#In khoang cach
	li $v0, 4
	la $a0, msg_space
	syscall 
	
	#Tang dia chi t0
	addi $t0, $t0, 4
	subi $t1, $t1, 1
	j print_array1_loop

#In phan tu mang 2
print_array2: 
	la $t0, array2
	lw $t1, size2 # Siae array2 = 16 bytes
	
	li $v0, 4
	la $a0, msg_array2 # In thong bao array2
	syscall
	
print_array2_loop:
	beq $t1, $zero, calc_array3 # Neu t1=0, nhay toi in mang 2
	lb $a0, 0($t0)
	li $v0, 1
	syscall
	
	#In khoang cach
	li $v0, 4
	la $a0, msg_space
	syscall 
	
	#Tang dia chi t0
	addi $t0, $t0, 1
	subi $t1, $t1, 1
	j print_array2_loop

calc_array3:
	la $t0, array2
	la $t2, array3
	lw $t1, size3
	lw $t3, size2
	
	sub $t3, $t3, 1

calc_array3_loop:
	beq $t1, $zero, print_array3 # Neu t1=0, nhay toi next step
	
	add $t9, $t0, $t8
	lb $t4, 0($t9)		# $t4 = array2[i]
	
	add $t5, $t0, $t3	
	sub $t5, $t5, $t8
	lb $t6, 0($t5)		# $t6 = array2[$t5 - 1]
	
	add $t7, $t4, $t6	# $t7 = $t4 + $t6
	sb $t7, 0($t2)		# array3[i] = $t7 
	addi $t2, $t2, 1
	subi $t1, $t1, 1
	addi $t8, $t8, 1
	j calc_array3_loop
	
print_array3:
	# In thong bao chon mang nao
	li $v0, 4
	la $a0, msg_select_array
	syscall
	
	li $s0, 3 
	li $s1, 1
	
	j user_input

input_elements:
	li $v0, 4
	li $s1, 0
	la $a0, msg_select_index
	syscall
	
user_input_elements:
	li $s2, 1
	move $s4, $s3
	beq $s3, 1, check_array1
	beq $s3, 2, check_array2

check_array3:		
	lw $s0, size3
	subi $s0, $s0, 1
	j user_input
	
check_array1:
	lw $s0, size1
	subi $s0, $s0, 1
	j user_input
	
check_array2:
	lw $s0, size2
	subi $s0, $s0, 1
	j user_input

# User nhap N
user_input:
	li $v0, 5
	syscall
	move $t0, $v0 # Luu v0 = t0
	
# Kiem tra N thuoc tu 1 den 3, nhap khac se bao nhap lai
check_N:
	bgt $t0, $s0, print_loop
	blt $t0, $s1, print_loop
	
	move $s3, $t0
	beq $s2, $zero, input_elements
	j continue_elements
	
print_loop:
	li $v0, 4
	la $a0, msg_error
	syscall
	
	j user_input #Nhay ve nhap gia tri array

continue_elements:
	li $v0, 1
	beq $s4, 1, output_array1
	beq $s4, 2, output_array2
	
output_array3:
	la $t2, array3
	j bytes
	
output_array1:
	la $t2, array1
	sll $s3, $s3, 2
	add $t2, $t2, $s3
	lw $a0, 0($t2)
	syscall
	
	j exit

output_array2:
	la $t2, array2
	
bytes: 
	add $t2, $t2, $s3
	lb $a0, 0($t2)
	syscall 

exit:

