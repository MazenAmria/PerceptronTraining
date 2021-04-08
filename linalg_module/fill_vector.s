	.globl fill_vector
fill_vector:
  # Fills a vector with a value
  # $a0: address of the destination vector (i size)
  # $a1: i (4-bytes integer)
  # $a2: value (4-bytes float)

	addiu $sp, $sp, -20
	sw $fp, 4($sp)
	move $fp, $sp

	sw $4, 8($fp)           # save vec
	sw $5, 12($fp)          # save i
	sw $6, 16($fp)          # save val
	sw $0, 0($fp)           # unsigned int _i = 0

	j fill_vector_i_check

fill_vector_i_body:
	lw $2, 0($fp)           # load _i
	sll $2, $2, 2           # convert to bytes offset
	lw $3, 8($fp)           # load vec     
	addu $2, $3, $2         # calculate the address  
	l.s $f0, 16($fp)       # T = val
	s.s $f0, 0($2)         # vec[_i] = val
	
  lw $2, 0($fp)
	addiu $2, $2, 1
	sw $2, 0($fp)           # _i++

fill_vector_i_check:
	lw $2, 12($fp)          # load i
	lw $3, 0($fp)           # load _i
	sltu $2, $3, $2         # if _i < i
  bne $2, $0, fill_vector_i_body  # continue
  # else
	move $sp, $fp
	lw $fp, 4($sp)
	addiu	$sp, $sp, 20      # free the stack
	jr $31                  # return
