.data
msg_input_n: 	.asciiz "Nhap n(n>0): "
msg_input_1: 	.asciiz "The factorial of "
msg_input_2: 	.asciiz " is : "
msg_error_input:.asciiz "Nhap sai, nhap lai\n"
msg_out3:	.asciiz "\nSize: "

data_in_1:	.space 10
data_in_2:	.space 10000
data_out: 	.space 10000

size1:		.word 1
size2: 		.word 1
size_out:	.word 1

.text
main:
	# Goi ham nhap
	jal input
	move $a0, $v0 # Luu n vao a0
	
	# Goi ham de quy tinh giai thua
	jal factorial
	move $s0, $v0
	move $s1, $a0
	
	# Goi ham in ket qua
	jal print
	
	j exit

	
#--------------------------------------
input:
	
	# In thong bao nhap N
	li $v0, 4
	la $a0, msg_input_n
	syscall

input_again:
	# Nhap n
	li $v0, 5
	syscall
	
	bgt $v0, 0, done_input
	
	li $v0, 4
	la $a0, msg_error_input
	syscall
	j input_again

done_input:	
	jr $ra
#---------------------------------------------------	
# t0: data 
# t2: size
# a2: value
TachN:
	li $a1, 10
	li $a3, 0 # count = 0
count:
	blt $a2, 10, out_Tach
	
	div $t1, $a2, $a1 # t1 = N/10
	
	# mflo: Phan thuong
	mflo $a2
	# mfhi: Phan du
	mfhi $t4
	
	# Luu tung phan vao data_in
	add $t1, $t0, $a3
	sb $t4, 0($t1)
	
	addi $a3, $a3, 1 # count++
	
	j count
	
out_Tach:
	add $t1, $t0, $a3
	sb $a2, 0($t1)
	
	addi $a3, $a3, 1
	sw $a3, 0($t2)
	
	jr $ra
##--------------------------------------------------	
OutTo2:
	la $t0, data_out
	la $t1, data_in_2
	
	la $t2, size_out
	lw $a2, 0($t2)
	la $t3, size2
	sw $a2, 0($t3) # Size2 = Size out
	
transfer_loop:
	beq $a2, $zero, out_OutTo2
	
	lb $a0, 0($t0)
	sb $a0, 0($t1)
	
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	
	subi $a2, $a2, 1
	
	j transfer_loop

out_OutTo2:
	jr $ra
##-----------------------------------------------
clearOut:
	la $t0, data_out
	la $t1, size_out
	lw $a1, 0($t1)
	
clear_loop:
	beq $a1, $zero, out_clearOut
	
	li $a0, 0
	sb $a0, 0($t0)
	
	addi $t0, $t0, 1
	subi $a1, $a1, 1

	j clear_loop

out_clearOut:
	jr $ra
##--------------------------------------------
calc_size:
	# t1 = size_x
	lw $t1, 0($a1)
	add $a2, $a2, $t1
calc_size_loop:
	subi $a2, $a2, 1
	subi $t1, $t1, 1
	
	# v0 = A[size_x -1]
	lb $v0, 0($a2)
	beq $v0, $zero, calc_size_loop
	
	addi $t1, $t1, 1
	sw $t1, 0($a1)
	jr $ra
#----------------------------------------------
factorial:
	# Neu n<=1 thi den ham out cua giai thua
	ble $a0, 1, factorial_out 
	
	# Push 2 stack
	addi $sp, $sp, -12 # Khoi tao 3 stack 
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	
	# f(n-1)
	addi $a0, $a0, -1 
	jal factorial
	
	# pop $ra, n
	lw $a0, 0($sp)
	
	# Tach data_in_1
	move $a2,$a0
	la $t0, data_in_1
	la $t2, size1
	move $s0, $ra
	jal TachN
	move $ra, $s0
	
	
	# n * f(n-1)
	jal Nhan
	
	# Calc size data_out
	la $a2, data_out
	la $a1, size_out
	move $s0, $ra
	jal calc_size
	move $ra, $s0
	
	# Data2 = Data_out
	jal OutTo2
	
	# set Data_out = 0
	jal clearOut
	
	# Done flag = 1
	xor $a0, $a0, $a0
	li $a0, 1
	sw $a0, 8($sp)
	
	# pop stack
	lw $a0, 0($sp)
	lw $ra, 4($sp)
	
	# return stack
	addi $sp, $sp, 12
	jr $ra
	
factorial_out:
	li $a0, 1
	
	# Luu 1 duoi dang tung phan tu
	move $a2,$a0
	la $t0, data_in_2
	la $t2, size2
	move $s0, $ra
	jal TachN
	move $ra, $s0
	
	jr $ra
#------------------------------------------------------------------
Nhan:
	# a1 = size1
	la $t1, size1
	lw $a1, 0($t1)
	li $s2, 0 # of A
	
loop_1:
	beq $a1, $zero, out_Nhan_1
	
	la $t2, data_in_2 # Luu dia chi data2 tai t2
	
	# a3 = size2
	la $t3, size2
	lw $a3, 0($t3) 
	
	# Vi tri hien tai
	li $s3, 0 # of B
	# Phan du cong them
	li $s1, 0

loop_2:
	beq $a3, $zero, out_Nhan_2
	
	# a0 = A[i]
	la $t0, data_in_1
	add $t0, $t0, $s2
	lb $a0, 0($t0)
	
	# a2 = B[j]
	lb $a2, 0($t2)
	mul $a2, $a2, $a0 # x = A[i] * B[j]
	
	# push gia tri data1 vao stack
	addi $sp, $sp, -2
	sb $a0, 0($sp)
	sb $t0, 1($sp)
	
	
	la $t0, data_out
	add $t0, $t0, $s2
	add $t0, $t0, $s3
	lb $a0, 0($t0)
	
	add $a2, $a2, $a0
	
	li $s1, 0 
	li $s4, 0
	blt $a2, 10 , Save_nhan
	
Chia:	
	# C[j]/10
	li $s0, 10
	div $a2, $s0 
	
	# Du
	mfhi $a2
	# Thuong
	mflo $s1
	
	# Luu phan thuong vao o ke tiep
	la $t4, data_out
	add $t4, $t4, $s2
	add $t4, $t4, $s3
	lb $s0, 1($t4)
	add $s1, $s1, $s0
	sb $s1, 1($t4) 

	
Save_nhan:
	# Luu phan du vao o hien tai
	la $t4, data_out
	add $t4, $t4, $s2
	add $t4, $t4, $s3
	sb $a2, 0($t4)
	
	# pop stack
	lb $a0, 0($sp)
	lb $t0, 1($sp)
	addi $sp, $sp, 2
	
	# j--, Dia chi data2++
	addi $t2, $t2, 1
	subi $a3, $a3, 1
	addi $s3, $s3, 1
	j loop_2
	
out_Nhan_2:
	addi $s2, $s2, 1 # count A++
	addi $t0, $t0, 1 # i++
	subi $a1, $a1, 1 
	j loop_1
	
out_Nhan_1:
	la $s0, size_out
	add $s2, $s2, $s3
	
	sw $s2, 0($s0)
	jr $ra
	
#--------------------------------------------
print:
	move $s0, $ra
	# The factorial of
	li $v0, 4
	la $a0, msg_input_1
	syscall
	
	# N
	la $a1, data_in_1
	la $a2, size1
	jal print_data
	
	# is: 
	li $v0, 4
	la $a0, msg_input_2
	syscall
	
	# Gia tri factorial cua N
	la $a1, data_in_2
	la $a2, size2
	jal print_data
	
	# print size
	li $v0, 4
	la $a0, msg_out3
	syscall
	
	li $v0, 1
	la $a1, size2
	lw $a0, 0($a1)
	syscall
	
	move $ra, $s0
	jr $ra
#----------------------------
# a1: data_x
# a2: size_x 
print_data:
	# Bat dau tu A[size -1]
	lw $t2, 0($a2)
	add $a1, $a1, $t2
	subi $a1, $a1, 1
	
print_data_loop:
	beq $t2, $zero, done_print_data
	
	# A[i]
	li $v0, 1
	lb $a0, 0($a1)
	syscall
	
	# i--; Address--
	subi $a1, $a1, 1
	subi $t2, $t2, 1
	
	j print_data_loop

done_print_data:
	jr $ra
	
#-------------------------------------	
exit:
	li $v0, 10
	syscall
	
