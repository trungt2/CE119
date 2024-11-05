.text
.data
	Input:		.asciiz "Nhap ky tu (chi mot ky tu): "
	KT_Hoa: 	.asciiz "Ky tu Hoa\n"
	KT_Thuong:  	.asciiz "Ky tu thuong\n"
	KT_So:		.asciiz "So\n"
	
	Truoc:		.asciiz "\nKy tu truoc: "
	Sau:		.asciiz "\nKy tu sau: "
	
	O_err:		.asciiz "invaild type\n"
	O_NoTruoc:	.asciiz "\nKhong co ky tu truoc"
	O_NoSau:	.asciiz "\nKhong co ky tu sau"
	
.text
main:
	#In thong bao
	li $v0, 4
	la $a0, Input
	syscall
	
	#Nhap ki tu	
	li $v0, 12
	syscall
	move $t1, $v0
	
check:
	li $t2, 97	#a
	li $t3, 122	#z

	bgt $t1, $t3, Out_err #Neu lon hon z bao "invaild type"
	blt $t1, $t2, check_HoaOrSo #Neu nho hon a kiem tra Hoa hoac So
	 	
check_TruocSau:
	beq $t1, $t2, NoTruoc #Neu = a; A; 0 thi bao khong co ky tu truoc
	beq $t1, $t3, NoSau  	#Neu = z; Z; 9 thi bao khong co ky tu sau
	j in_ky_tu

NoTruoc:
	li $v0, 4
	la $a0, O_NoTruoc
	syscall	
	j in_sau
NoSau:
	li $v0, 4
	la $a0, O_NoSau
	syscall	
	addi $t4, $t4, 1 
	j in_truoc

check_HoaOrSo:
	li $t2, 65 #A
	li $t3, 90 #Z
	
	bgt $t1, $t3, Out_err
	blt $t1, $t2, checkSo
	j check_TruocSau
	
checkSo:
	li $t2, 48 #0
	li $t3, 57 #9
	
	bgt $t1, $t3, Out_err
	blt $t1, $t2, Out_err
	j check_TruocSau

in_ky_tu:
	#in thong bao
in_truoc:
	li $v0, 4
	la $a0, Truoc
	syscall
	
	sub $s0, $t1, 1
	li $v0, 11
	move $a0, $s0
	syscall
	
	beq $t4, 0, in_sau
	j exit

in_sau:
	li $v0, 4
	la $a0, Sau
	syscall
	
	addi $t1, $t1, 1
	li $v0, 11
	move $a0, $t1
	syscall
	j exit

Out_err:
	#Bao loi
	li $v0, 4
	la $a0, O_err
	syscall
	
exit:
    	li $v0, 10            # syscall exit
    	syscall
	
	
	
