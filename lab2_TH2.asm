#V?i giá tr? c?a i, N, Sum l?n l??t ch?a trong các thanh ghi $s0, $s1, $s2

#int Sum = 0
#for (int i = 1; i <=N; ++i){
 #Sum = Sum + i;
#}




.text
	or $s1, $s1,0
	addi $s1, $s1, 5
	
	
	or $s2, $s2,0
	addi $s2, $s2, 0
	
	or $s0, $s0, 0
	addi $s0, $s0, 1
	
SoSanh:
	bgt $s0, $s1, Out
	add $s2, $s2, $s0
	addi $s0, $s0, 1
	j SoSanh
Out: 
