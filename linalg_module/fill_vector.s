	.globl fill_vector
fill_vector:
  # Fills a vector with a value
  # $a0: address of the destination vector (i size)
  # $a1: i (4-bytes integer)
  # $a2: value (4-bytes float)

	addiu $sp, $sp, -20
	sw $fp, 4($sp)
	move $fp, $sp

	sw $a0, 8($fp)           # save vec
	sw $a1, 12($fp)          # save i
	sw $a2, 16($fp)          # save val
	sw $zero, 0($fp)           # unsigned int _i = 0

	j fill_vector_i_check

fill_vector_i_body:
	lw $t0, 0($fp)           # load _i
	sll $t0, $t0, 2           # convert to bytes offset
	lw $t1, 8($fp)           # load vec     
	addu $t0, $t1, $t0         # calculate the address  
	l.s $f0, 16($fp)       # T = val
	s.s $f0, 0($t0)         # vec[_i] = val
	
  lw $t0, 0($fp)
	addiu $t0, $t0, 1
	sw $t0, 0($fp)           # _i++

fill_vector_i_check:
	lw $t0, 12($fp)          # load i
	lw $t1, 0($fp)           # load _i
	sltu $t0, $t1, $t0         # if _i < i
  bne $t0, $zero, fill_vector_i_body  # continue
  # else
	move $sp, $fp
	lw $fp, 4($sp)
	addiu	$sp, $sp, 20      # free the stack
	jr $ra                  # return
