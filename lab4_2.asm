.data
msg_input_n: 	.asciiz "Nhap n(n>0): "
msg_input_1: 	.asciiz "The factorial of "
msg_input_2: 	.asciiz " is : "
msg_input_error:.asciiz "Nhap sai, vui long nhap lai: "

data: 	.space 100

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
input:
	# In thong bao nhap N
	li $v0, 4
	la $a0, msg_input_n
	syscall

input_again:
	# Nhap n
	li $v0, 5
	syscall
	
	bgt $v0, $zero, out_input
	
	li $v0, 4
	la $a0, msg_input_error
	syscall
	
	j input_again
out_input:
	jr $ra
	
factorial:
	# Neu n<=1 thi den ham out cua giai thua
	ble $a0, 1, factorial_out 
	
	# Push 2 stack
	addi $sp, $sp, -12 # Khoi tao 2 stack 
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	
	# f(n-1)
	addi $a0, $a0, -1 
	jal factorial
	
	# pop $ra, n
	lw $a0, 0($sp)
	
	
	# n * f(n-1)
	mulu $v0, $v0, $a0
	
	lw $ra, 4($sp)
	sw $v0, 8($sp) # Save F(n) to stack
	addi $sp, $sp, 12
	
	jr $ra
	
factorial_out:
	li $v0, 1
	jr $ra

print:
	li $v0, 4
	la $a0, msg_input_1
	syscall
	
	li $v0, 1
	move $a0, $s1
	syscall
	
	li $v0, 4
	la $a0, msg_input_2
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	
