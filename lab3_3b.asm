.data
# if (i<j) A[i]= i; 
# else A[i] = j;

msg_input: 		.asciiz "Nhap n(n>0): "
msg_error: 		.asciiz "Nhap sai, vui long nhap lai! \n"
msg_input_value:	.asciiz "a["
msg_input_v:		.asciiz "]: "

msg_error_i:		.asciiz "Gia tri i sai, nhap lai: "
msg_error_j:		.asciiz "Gia tri j sai, nhap lai: "
msg_enter:		.asciiz "\n"

array: .word 0:250 # 1000 bytes = 250 words
.text
main:
	li $v0, 4
	la $a0, msg_input
	syscall
	
input_n_loop:
	li $v0, 5
	syscall
	move $t0, $v0
	
	bgt $t0, 0, input_value
	 
input_msg_loop:
	li $v0, 4
	la $a0, msg_error
	syscall
	
	j input_n_loop
	
input_value:
	la $s3, array
	la $t1, array
	li $t2, 0
	xor $t6, $t6, $t6
	
input_loop:
	beq $t2, $t0, check_ij
	
	# A[
	li $v0, 4
	la $a0, msg_input_value
	syscall
	
	# i
	li $v0, 1
	move $a0, $t2
	syscall
	
	# ]: 
	li $v0, 4
	la $a0, msg_input_v
	syscall
	
	# Nhap gia tri
	li $v0, 5
	syscall
	sw $v0, 0($t1)
	
	addi $t1, $t1, 4
	addi $t2, $t2, 1
	j input_loop

check_ij:
	# Check i
	bgt $s0, $t0, i_again
	blt $s0, 0, i_again
	
	# Check j
	bgt $s1, $t0, j_again
	blt $s1, 0, j_again
	
	j so_sanh
	
i_again:
	li $v0, 4
	la $a0, msg_error_i
	syscall 
	
	li $v0, 5
	syscall 
	move $s0, $v0
	
	j check_ij
	
j_again:
	li $v0, 4
	la $a0, msg_error_j
	syscall 
	
	li $v0, 5
	syscall 
	move $s1, $v0
	
	j check_ij
	
so_sanh:	
	la $t1, array
	sll $s2, $s0, 2
	add $t1, $t1, $s2
	
	blt $s0, $s1, update_Ai
	
update_Aj:
	sw $s1, 0($t1)
	
	j print
update_Ai:
	sw $s0, 0($t1)
	
print: 
	# \n
	li $v0, 4
	la $a0, msg_enter
	syscall
	
	# A[
	li $v0, 4
	la $a0, msg_input_value
	syscall
	
	# i
	li $v0, 1
	move $a0, $s0
	syscall
	
	# ]:
	li $v0, 4
	la $a0, msg_input_v
	syscall
	
	la $t1, array
	sll $s2, $s0, 2
	add $t1, $t1, $s2
	lw $t2, 0($t1)
	
	li $v0, 1
	move $a0, $t2
	syscall

	