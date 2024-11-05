.data
	#Inout 
	str: .asciiz "Nhap: "
	buffer: .space 50
	#Output
	str1: .asciiz "Chao ban! Ban la sinh vien nam thu may?\n"
	str2: .asciiz "Hihi, minh la sinh vien nam thu 1 ^-^\n"
.text
	main:
		#Nhap
		li $v0, 4
		la $a0, str
		syscall
		
		li $v0, 8
		la $a0, buffer
		la $a1, 50
		move $t1, $a0
		syscall
		
		#Xuat
		li $v0, 4
		la $a0, str1
		syscall
		
		li $v0, 4
		la $a0, str2
		syscall
		
	out_input: 
		li $v0, 4
		move $a0, $t1
		syscall
	end:
		li $v0, 10
		syscall