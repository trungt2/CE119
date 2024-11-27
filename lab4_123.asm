
	# Gan gia tri
	li $s0, 2
	li $s1, 3
	li $s2, 4
	li $s3, 5
	
	li $s4, 6
	li $s5, 7

main:
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	move $a3, $s3
	
	move $t2, $s4 #e
	move $t3, $s5 #f
	
	jal proc_example
	
	move $a0, $v0
	li $v0, 1
	syscall
	
	j exit

proc_example:
	# push stack
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	
	# x = (a + b) 
	add $t0, $a0, $a1
	# y = c + d
	add $t1, $a2, $a3
	# z = x - y
	sub $s0, $t0, $t1
	
	# s1 = e - f
	sub $s1, $t2, $t3
	
	# return global value
	move $v0, $s0
	move $v1, $s1
	
	# pop stack
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 4
	
	jr $ra	
	
exit:
