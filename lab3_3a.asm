.data
msg_input: 		.asciiz "Nhap n(n>0): "
msg_error: 		.asciiz "Nhap sai, vui long nhap lai! \n"
msg_input_value:	.asciiz "a["
msg_input_v:		.asciiz "]: "
msg_max:		.asciiz "Gia tri lon nhat: "
msg_min:		.asciiz "\nGia tri nho nhat: "
msg_sum:		.asciiz "\nTong gia tri cac phan tu trong mang: "
msg_out:		.asciiz "\nPhan tu n can xuat (a[n]): "

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
	la $t1, array
	li $t2, 0
	xor $t6, $t6, $t6
	
input_loop:
	beq $t2, $t0, max_min
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
	
max_min:
	la $t1, array
	lw $t3, 0($t1)  # t3 = a[0]
	move $t4, $t3	# max = t3
	move $t5, $t3	# min = t3
	li $t2, 1	# i= 1
	add $t1, $t1, 4
	
mm_loop:
	add $t6, $t6, $t3	# Tinh tong cac phan tu
	beq $t2, $t0, print_mms
	lw $t3, 0($t1)
	bgt $t3, $t4, update_max
	blt $t3, $t5, update_min
	
	j update_i
	
update_max:
	move $t4, $t3
	j update_i
	
update_min:
	move $t5, $t3
	
update_i:
	addi $t1, $t1, 4
	addi $t2, $t2, 1
	j mm_loop
	
print_mms:
	# In gia tri lon nhat
	li $v0, 4
	la $a0, msg_max
	syscall
	
	li $v0, 1
	move $a0, $t4
	syscall
	
	# In gia tri nho nhat
	li $v0, 4
	la $a0, msg_min
	syscall
	
	li $v0, 1
	move $a0, $t5
	syscall
	
	# In tong cac phan tu trong mang
	li $v0, 4
	la $a0, msg_sum
	syscall
	
	li $v0, 1
	move $a0, $t6
	syscall
	
print_n_check:
	# In thong bao
	li $v0, 4
	la $a0, msg_out
	syscall

loop:
	li $v0, 5
	syscall
	move $t0, $v0
	
check_loop:
	bgt $t0, -1, print_n
	
	li $v0, 4
	la $a0, msg_error
	syscall
	
	j loop
	
print_n:
	li $v0, 4
	la $a0, msg_input_value
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 4
	la $a0, msg_input_v
	syscall
	
	la $t1, array
	sll $t0, $t0, 2
	add $t1, $t1, $t0
	lw $t2, 0($t1)
	
	li $v0, 1
	move $a0, $t2
	syscall
	
exit:
	
	
	
	
	