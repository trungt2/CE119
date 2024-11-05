.data
	Input1:		.asciiz "Nhap so nguyen 1: "
	Input2:		.asciiz "Nhap so nguyen 2: "
	
	O_Tong:		.asciiz "\nTong 2 so: "
	O_Hieu:		.asciiz "\nHieu 2 so: "
	O_Tich:		.asciiz "\nTich 2 so: "
	O_Thuong:	.asciiz "\nThuong 2 so: "
	O_Lonhon:	.asciiz "\nSo lon hon: "
	O_NoLon:	.asciiz "\nKhong co so lon hon"
	O_err0:		.asciiz "\nKhong the chia 0"
	
	result_float: .float 0.0  # Bi?n l?u k?t qu? d?ng float

.text
main: 
	#in thong bao nhap
	li $v0, 4
	la $a0, Input1
	syscall
		
	li $v0, 5
	syscall
	move $t1, $v0
		
	li $v0, 4
	la $a0, Input2
	syscall
		
	li $v0, 5
	syscall
	move $t2, $v0
	
SoSanh:
	move $t3, $t1	#tao bien temp gan t1 vao temp
	bgt $t1, $t2, in_so_lon #neu t1 lon hon nhay toi in t1
NhoOrBang:
	beq $t1, $t2, in_bang
	move $t3, $t2 #gan t2 vao temp
	j in_so_lon
	
in_bang:	
	li $v0, 4
	la $a0, O_NoLon
	syscall
	j Tong
	
in_so_lon:	
	li $v0, 4
	la $a0, O_Lonhon
	syscall
	
	li $v0, 1
	move $a0, $t3
	syscall
	
Tong:
	add $t3, $t1, $t2
	
	#in tong
	li $v0, 4
	la $a0, O_Tong
	syscall
	
	li $v0, 1
	move $a0, $t3
	syscall
	
Hieu:
	sub $t3, $t1, $t2
	
	#in hieu
	li $v0, 4
	la $a0, O_Hieu
	syscall
	
	li $v0, 1
	move $a0, $t3
	syscall
	
Tich:
	mul $t3, $t1, $t2
	
	#in tich
	li $v0, 4
	la $a0, O_Tich
	syscall
	
	li $v0, 1
	move $a0, $t3
	syscall
	
Thuong:
	beq $t2, 0, in_loi1 #neu t2=0 thi xuat bao loi
	
	mtc1 $t1, $f0		#chuyen thanh ghi so nguyen sang thanh ghi float
	cvt.s.w $f0, $f0	#chuyen so nguyen sang float
	
	mtc1 $t2, $f1
	cvt.s.w $f1, $f1
	
	#in float
	li $v0, 4
	la $a0, O_Thuong
	syscall
	
	div.s $f2, $f0, $f1
	mov.s $f12, $f2
	li $v0, 2
	syscall
	j exit
	
in_loi1:
	li $v0, 4
	la $a0, O_err0
	syscall
	
exit:
    	li $v0, 10            # syscall exit
    	syscall
