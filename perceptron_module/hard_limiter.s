  .globl hard_limiter
hard_limiter:
  # Applies the hard limiting activation function to a vector
  # $a0 = destination vector (4-bytes address)
  # $a1 = size of the vector (4-bytes unsigned integer)
  
  addiu $sp, $sp, -16
	sw $fp, 4($sp)
	move $fp, $sp     
	sw $4, 8($fp)           # save vec
	sw $5, 12($fp)          # save i
	sw $0, 0($fp)           # unsigned int _i = 0
	
  j hard_limiter_i_check

hard_limiter_i_body:
	lw $2, 0($fp)           # load _i
	sll $2, $2, 2           # convert to bytes address
	lw $3, 8($fp)           # load vec
	addu $2, $3, $2         # claculate the address
	lwc1 $f0, 0($2)         # load vec[_i]
	mtc1 $0, $f2            # load the 0
	c.le.s $f2, $f0         # if 0 <= vec[_i]
	bc1f hard_limiter_i_false # else              
	lw $2, 0($fp)           # load _i
	sll $2, $2, 2           # convert to bytes address
	lw $3, 8($fp)           # load vec
	addu $2, $3, $2         # caldulate the address
	l.s $f0, ONE
  s.s $f0, 0($2)       # dest[y] = 1.0
	j hard_limiter_i_increment

hard_limiter_else:
	lw $2, 0($fp)           # load _i
	sll $2, $2, 2           # convert to bytes address
	lw $3, 8($fp)           # load vec[_i]
	addu $2, $3, $2         # calculate the address
	sw $0, 0($2)            # vec[_i] = 0

hard_limiter_i_increment:
	lw $2, 8($fp)
	addiu $2, $2, 1
	sw $2, 8($fp)

hard_limiter_i_check:
	lw $3, 0($fp)           # load i
	lw $2, 12($fp)          # load _i
	sltu $2, $3, $2         # if _i < i
	bne $2, $0, hard_limiter_i_body # continue
	# else
  move $sp, $fp
	lw $fp, 4($sp)
	addiu $sp, $sp, 16      # free the stack
	jr $31                  # return
