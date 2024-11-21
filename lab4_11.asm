.data
prompt:	.asciiz "Enter one number: "
out:	.asciiz "Gia tri cua so int nhap: "
.text
main:
	jal getInt
	move $s0, $v0
	j exit
	jal showInt
	j exit
	
getInt:
	li $v0, 4
	la $a0, prompt
	syscall
	
	li $v0, 5
	syscall
	
	jr $ra
	
showInt:
	li $v0, 4
	la $a0, out
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	jr $ra
	
exit:
