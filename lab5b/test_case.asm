main:       
    add $t0, $zero, $zero   # $t0 = 0
    addi $t1, $zero, 5      # $t1 = 5
    addu $t2, $t1, $t1      # $t2 = $t1 + $t1
    and $t3, $t2, $t1       # $t3 = $t2 AND $t1
    lui $t4, 0x1001         # $t4 = 0x10010000, base address of .data
    jal save                # jump and link to save label

    
    lw $t5, 0($t4)    # load word from address in $t4
    sw $t5, 4($t4)          # store word in $t5 to address 4 + $t4
    beq $t1, $t2, end       # if $t1 == $t2, jump to label end
    beq $t1, $zero, main    # if $t1 != 0, jump to label main
    lbu $t6, 7($t4)         # load byte unsigned from address 7 + $t4
    lhu $t7, 8($t4)         # load half-word unsigned from address 8 + $t4

    addi $t8, $t7, -1       # $t8 = $t7 - 1
    addiu $t9, $t8, 1       # $t9 = $t8 + 1
    andi $t0, $t9, 0x7F     # $t0 = $t9 AND 0x7F
    j finish                # jump to finish label

save:       
    add $s0, $t0, $zero     # $s0 = $t0
    add $s1, $s0, $zero     # $s1 = $s0
    sw $s1, 0($t4)        # store word from $s1 at address 0
    jr $ra                  # return from 'save'

finish:
    add $ra, $zero, $zero   # dummy instruction to represent end of logic
end:        
    and $s2, $s1, $zero     # $s2 = $s1 AND 0
    add $s3, $s2, $s1       # $s3 = $s2 + $s1
    jr $ra                  # return to caller
#Giải thích tại sao lui $t4, 0x1001 lại có thể load được địa chỉ mà không cần dùng lệnh "la"
#lui $t4, 0x1001 nghĩa là "load upper immediate" vào thanh ghi $t4.
#Lệnh này sẽ sẽ đặt giá trị 0x1001 vào 16 bit cao của thanh ghi $t4 và 16 bit thấp sẽ được đặt là 0x0000.
#Kết quả là $t4 sẽ có giá trị là 0x10010000, và đây sẽ là địa chỉ khởi đầu của vùng nhớ .data
#Các bạn có thể kiểm chứng bằng việc check Data Segment khi compile và chạy chương trình