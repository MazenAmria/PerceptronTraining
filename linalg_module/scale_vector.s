	.globl	scale_vector
scale_vector:
  # Scales a vector by constant value
  # Ai *= K
  # $a0: address of the destination vector (i size)
  # $a1: value of the scalar
  # $a2: i (4-bytes integer)
  
	addiu	$sp, $sp, -20
	sw $fp, 4($sp)
	move $fp, $sp
	sw $4, 8($fp)	      # save A
	sw $5, 12($fp)	    # save K
	sw $6, 16($fp)	    # save i
	sw $0, 0($fp)	      # unsigned int _i = 0
	j scale_vector_i_check

scale_vector_i_body:
	lw	$2, 0($fp)		  # load _i
	sll	$2, $2, 2	      # convert to bytes offset
	lw	$3, 8($fp)		  # load A
	addu $2, $3, $2	    # calculate the address
	lwc1 $f2, 0($2)	    # load A[_i]

	lwc1 $f0, 12($fp)	  # load K

	lw	$2, 0($fp)		  # load _i
	sll	$2, $2, 2	      # convert to bytes offset
	lw	$3, 8($fp)		  # load A
	addu $2, $3, $2	    # calculate the address
	mul.s $f0, $f2, $f0	# T = K * A[_i]
	swc1 $f0, 0($2)	    # A[_i] = T

	lw $2, 0($fp)
	addiu $2, $2, 1
	sw $2, 0($fp)	      # _i++

scale_vector_i_check:
	lw $3, 4($fp)		    # load _i
	lw $2, 16($fp)		  # load i
	sltu $2, $3, $2	    # if _i < i
	bne	$2, $0, scale_vector_i_body
  # else
	move $sp, $fp
	lw $fp, 4($sp)
	addiu	$sp, $sp, 20  # free the stack
	jr  $31             # return