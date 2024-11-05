.data
	#Input
	str1: .asciiz "Nhap so nguyen 1:"
	str2: .asciiz "Nhap so nguyen 2:"
	#Output
	str3: .asciiz "Tong 2 so nguyen: "

.text 
	main:
		li $v0, 4
		la $a0, str1
		syscall
		
		li $v0, 5
		syscall
		move $t1, $v0
		
		li $v0, 4
		la $a0, str2
		syscall
		
		li $v0, 5
		syscall
		move $t2, $v0
		
		
	sum: 	add $t3, $t1, $t2
	out:	
		li $v0, 4
		la $a0, str3
		syscall
		
		li $v0, 1
		move $a0, $t3
		syscall
	
	
		