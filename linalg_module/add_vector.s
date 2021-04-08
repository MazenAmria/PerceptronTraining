	.globl	add_vector
add_vector:
  # Adds a vector to another
  # Ai += Bi
  # $a0: address of the destination vector (i size)
  # $a1: address of the source vector (i size)
  # $a2: i (4-bytes integer)
  
	addiu	$sp, $sp, -20
	sw $fp, 4($sp)
	move $fp, $sp
	sw $4, 8($fp)	      # save A
	sw $5, 12($fp)	    # save B
	sw $6, 16($fp)	    # save i
	sw $0, 0($fp)	      # unsigned int _i = 0
	j add_vector_i_check

add_vector_i_body:
	lw	$2, 0($fp)		  # load _i
	sll	$2, $2, 2	      # convert to bytes offset
	lw	$3, 8($fp)		  # load A
	addu $2, $3, $2	    # calculate the address
	lwc1 $f2, 0($2)	    # load A[_i]

	lw	$2, 0($fp)		  # load _i
	sll	$2, $2, 2	      # convert to bytes offset
	lw	$3, 12($fp)		  # load B
	addu $2, $3, $2	    # calculate the address
	lwc1 $f0, 0($2)	    # load B[_i]

	lw	$2, 0($fp)		  # load _i
	sll	$2, $2, 2	      # convert to bytes offset
	lw	$3, 8($fp)		  # load A
	addu $2, $3, $2	    # calculate the address
	add.s $f0, $f2, $f0	# T = A[_i] + B[_i]
	swc1 $f0, 0($2)	    # A[_i] = T

	lw $2, 0($fp)
	addiu $2, $2, 1
	sw $2, 0($fp)	      # _i++

add_vector_i_check:
	lw $3, 4($fp)		    # load _i
	lw $2, 16($fp)		  # load i
	sltu $2, $3, $2	    # if _i < i
	bne	$2, $0, add_vector_i_body
  # else
	move $sp, $fp
	lw $fp, 4($sp)
	addiu	$sp, $sp, 20  # free the stack
	jr  $31             # return