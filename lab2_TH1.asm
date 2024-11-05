#V?i giá tr? c?a i, j, f, g, h l?n l??t ch?a trong các thanh ghi $s0, $s1, $s2, $t0, $t1

.data


.text
KhongBang:
	bne $s0, $s1, Bang
	add $s2, $t0, $t1
	j Out
	
Bang:
	sub $s2, $t0, $t1

Out:
	
