	.globl  sub_vector
sub_vector:
  # Subtracts a vector from another
  # Ai -= Bi
  # $a0: address of the destination vector (i size)
  # $a1: address of the source vector (i size)
  # $a2: i (4-bytes integer)
  
	addiu	$sp, $sp, -20
	sw $fp, 4($sp)
	move $fp, $sp
	sw $a0, 8($fp)	      # save A
	sw $a1, 12($fp)	    # save B
	sw $a2, 16($fp)	    # save i
	sw $zero, 0($fp)	      # unsigned int _i = 0
	j sub_vector_i_check

sub_vector_i_body:
	lw	$t0, 0($fp)		  # load _i
	sll	$t0, $t0, 2	      # convert to bytes offset
	lw	$t1, 8($fp)		  # load A
	addu $t0, $t1, $t0	    # calculate the address
	lwc1 $f2, 0($t0)	    # load A[_i]

	lw	$t0, 0($fp)		  # load _i
	sll	$t0, $t0, 2	      # convert to bytes offset
	lw	$t1, 12($fp)		  # load B
	addu $t0, $t1, $t0	    # calculate the address
	lwc1 $f0, 0($t0)	    # load B[_i]

	lw	$t0, 0($fp)		  # load _i
	sll	$t0, $t0, 2	      # convert to bytes offset
	lw	$t1, 8($fp)		  # load A
	addu $t0, $t1, $t0	    # calculate the address
	sub.s $f0, $f2, $f0	# T = A[_i] - B[_i]
	swc1 $f0, 0($t0)	    # A[_i] = T

	lw $t0, 0($fp)
	addiu $t0, $t0, 1
	sw $t0, 0($fp)	      # _i++

sub_vector_i_check:
	lw $t1, 4($fp)		    # load _i
	lw $t0, 16($fp)		  # load i
	sltu $t0, $t1, $t0	    # if _i < i
	bne	$t0, $zero, sub_vector_i_body
  # else
	move $sp, $fp
	lw $fp, 4($sp)
	addiu	$sp, $sp, 20  # free the stack
	jr  $ra             # return