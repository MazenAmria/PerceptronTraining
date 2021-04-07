	.globl one_hot_encoding
one_hot_encoding:
	addiu $sp, $sp, -20
	sw $31, 4($sp)        # save $ra
	sw $fp, 0($sp)        # save $fp
	move $fp, $sp       
	sw $4, 8($fp)         # save y
	sw $5, 12($fp)        # save dest
	sw $6, 16($fp)        # save i

	move $6, $0           # pass 0
	lw $5, 16($fp)        # pass i
	lw $4, 12($fp)        # pass dest
	jal fill_vector       # (dest, i, 0)

  lw $2, 8($fp)         # load y
	sll $2, $2, 2         # convert to bytes offset
	lw $3, 12($fp)        # load dest        
	addu $2, $3, $2       # calculate the address
	addiu $4, $0, 1       # $4 = int(1)
  mtc1 $4, $f0
  cvt.s.w $f0, $f0      # $f0 = float(1.0)
  swc1 $f0, 0($2)       # dest[y] = 1.0
	
  move $sp, $fp
	lw $31, 4($sp)
	lw $fp, 0($sp)
	addiu $sp, $sp, 20
	jr $31                # return
