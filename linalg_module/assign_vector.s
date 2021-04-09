	.globl assign_vector
assign_vector:
  # Assigns a vector to another
  # $a0: address of the destination vector (i size)
  # $a1: address of the soruce vector (i size)
  # $a2: i (4-bytes integer)

	addiu $sp, $sp, -20
	sw $fp, 4($sp)          # save $fp
	move $fp, $sp
	sw $a0, 8($fp)           # save dest
	sw $a1, 12($fp)          # save src
	sw $a2, 16($fp)          # save i
	sw $zero, 0($fp)           # unsigned int _i = 0
	
  j	assign_vector_i_check

assign_vector_i_body:
	lw $t0, 0($fp)           # load _i
	sll $t0, $t0, 2           # convert to bytes offset
	lw $t1, 12($fp)          # load src
	addu $t1, $t1, $t0         # calculate the address

	lw $t0, 0($fp)           # load _i
	sll $t0, $t0, 2           # convert to bytes offset
	lw $a0, 8($fp)           # load dest
	addu $t0, $a0, $t0         # calculate the address

	l.s $f0, 0($t1)         # T = src[_i]
	s.s $f0, 0($t0)         # dest[_i] = T

	lw $t0, 0($fp)
	addiu $t0, $t0, 1
	sw $t0, 0($fp)           # _i++

assign_vector_i_check:
	lw $t0, 16($fp)          # load i 
	lw $t1, 0($fp)           # load _i
	sltu $t0, $t1, $t0         # if _i < i
	bne	$t0, $zero, assign_vector_i_body  # continue
  # else
	move $sp, $fp
	lw $fp, 4($sp)          # pop $fp
	addiu	$sp, $sp, 20      # free the stack
	jr $ra                  # return