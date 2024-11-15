.data
# Input
msg_input:		.asciiz "Nhap n(n>0): "
msg_error_input: 	.asciiz "Nhap sai, nhap lai: "
# Output
msg_out1:		.asciiz "Fibonanci of "
msg_out2:		.asciiz " is: "
# Data
data_in_1:	.space 10000
data_in_2:	.space 10000
# Size
size2:		.word 1

.text
main:	
	# Goi thong bao nhap n
	jal input
	move $a0, $v0
	# Tinh fibo
	jal fibo
	move $s0, $a0
	move $s1, $v0
	# In gia tri fibo
	jal print
	# Thoat
	j exit
#-------------------------------------------
input:
	# Thong bao nhap n
	li $v0, 4
	la $a0, msg_input
	syscall
input_again:
	# Nhap n
	li $v0, 5
	syscall
	
	bgt $v0, 0, input_out
	# Thong bao nhap lai
	li $v0, 4
	la $a0, msg_error_input
	syscall
	
	j input_again
input_out:
	jr $ra
#-----------------------------------------
exit: 
	li $v0, 10
	syscall
#-------------------------------------------
fibo:
	# push stack
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	# Gan 1 cho f(1)
	la $t0, data_in_2
	li $a0, 1
	sb $a0, 0($t0)
	
	lw $a0, 4($sp)
	subi $a0, $a0, 1
	# f(n) = f(n-1) + f(n-2)
	jal CongFibo
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
#------------------------------------------------
CongFibo:
	# Load thong tin
	la $t0, data_in_1
	la $t1, data_in_2
	
	la $a2, size2
	lw $s0, 0($a2)
	
	
CongFibo_loop:
	beq $s0, $zero, out_CongFibo
	
	lb $s1, 0($t0)
	lb $s2, 0($t1)
	add $a1, $s1, $s2 # C[i] = A[i] + B[i]
	
	# if C[i]< 10 => Giu nguyen
	blt $a1, 10, GiuNguyen
	# if >= 10, a1/10
	li $v0, 10
	div $a1, $v0
	
	mfhi $a1	# Du
	mflo $v0	# Thuong
	
	# Them phan /10 vao data_temp[i+1]
	lb $s3, 1($t0)
	add $s3, $s3, $v0
	sb $s3, 1($t0)
	
	
	bne $s0, 1, GiuNguyen 	# if s0 != 1 => Giu nguyen
	# if s0 == 1 => size2++
	la $a3, size2
	lb $s3, 0($a3)
	addi $s3, $s3, 1
	sb $s3, 0($a3)
	# s0++ (Dem them 1 lan)
	addi $s0, $s0, 1
	
GiuNguyen:
	sb $a1, 0($t1)	# A[i] = B[i]
	sb $s2, 0($t0)	# B[i] = C[i]%10
	
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $t2, $t2, 1
	
	subi $s0, $s0, 1
	j CongFibo_loop
	
out_CongFibo:
	ble $a0, 1, out_CongFibo_loop
	subi $a0, $a0, 1
	j CongFibo
out_CongFibo_loop:
	jr $ra
#-----------------------------------------------------
print: 
	# Fibonanci of
	li $v0, 4
	la $a0, msg_out1
	syscall
	# N
	li $v0, 1
	move $a0, $s0
	syscall
	# is: 
	li $v0, 4
	la $a0, msg_out2
	syscall
	# value fibo(n)
	move $s0, $ra
	la $a1, data_in_2
	la $a2, size2
	jal print_data
	move $ra, $s0
	
	jr $ra
#-------------------------------------------------
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
	
