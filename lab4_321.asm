.data
msg_input:		.asciiz "Nhap n(n>0): "
msg_error_input: 	.asciiz "Nhap sai, nhap lai: "

msg_out1:		.asciiz "Fibonanci of "
msg_out2:		.asciiz " is: "

data_in_1:	.space 1000
data_in_2:	.space 1000

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
	# n<= 1 return n
	ble $a0, 1, fibo_out
	
	# push stack
	addi $sp, $sp, -16	# 2 stacks
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	
	# fibo(n-1)
	lw $a0, 0($sp)
	addi $a0, $a0, -1 # n = n-1
	jal fibo
	move $t2, $v0
	sw $t2, 8($sp)
	
	# fibo(n-2)
	lw $a0, 0($sp)
	addi $a0, $a0, -2
	jal fibo
	
	# v0 = fibo(n-1) + fibo(n-2)
	lw $t2, 8($sp)
	add $v0, $v0, $t2
	sw $v0, 12($sp)
	
	lw $a0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 16
	
	jr $ra
fibo_out:
	move $v0, $a0
	jr $ra
#------------------------------------------------
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
	li $v0, 1
	move $a0, $s1
	syscall
	
	jr $ra
#_------------------------------------------------
	
	
