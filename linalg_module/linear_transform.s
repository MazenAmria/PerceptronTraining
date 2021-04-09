  .globl	linear_transform
linear_transform:
  # Linear Transformation of a vector (Change Basis)
  # Wij * Xj = Yi
  # $a0: address of the input vector (j size)
  # $a1: address of the change of basis matrix (ixj size)
  # $a2: address of the output vector (i size)
  # $a3: i (4-bytes integer)
  # 0($sp): j (4-bytes integer)
  
	addiu	$sp, $sp, -28
	sw $fp, 8($sp)
	move $fp, $sp
	sw $a0, 12($fp)	  # save X
	sw $a1, 16($fp)	  # save W
	sw $a2, 20($fp)	  # save Y
	sw $a3, 24($fp)	  # save i
	sw $zero, 0($fp)	    # unsigned int _i = 0
	j linear_transform_i_check

linear_transform_i_body:
	lw $t0, 0($fp)     # load _i
	sll $t0, $t0, 2     # convert to byte offset
	lw $t1, 20($fp)    # load Y
	addu $t0, $t1, $t0   # calculate the address
	sw $zero, 0($t0)      # Y[_i] = 0

	sw $zero, 4($fp)     # unsigned int _j = 0
	j	linear_transform_j_check

linear_transform_j_body:
	lw $t0, 0($fp)		  # load _i
	sll $t0, $t0, 2	    # convert to byte offset
	lw $t1, 20($fp)		# load Y
	addu $t0, $t1, $t0	  # calculate the address
	l.s $f2, 0($t0)	  # load Y[_i]

	lw $t0, 0($fp)		  # load _i
	sll $t0, $t0, 2	    # convert to byte offset
	lw $t1, 16($fp)		# load W
	addu $t0, $t1, $t0	  # calculate the address of the row
	lw $t1, 0($t0)		  # load W[_i]

	lw $t0, 4($fp)		  # load _j
	sll $t0, $t0, 2	    # convert to byte offset
	addu $t0, $t1, $t0	  # calculate the address
	l.s $f4, 0($t0)	  # load W[_i][_j]

	lw $t0, 4($fp)		  # load _j
	sll $t0, $t0, 2	    # convert to byte offset
	lw $t1, 16($fp)		# load X
	addu $t0, $t1, $t0	  # calculate the address
	l.s $f0, 0($t0)	  # load X[_j]

	mul.s $f0, $f4, $f0	 # T = W[_i][_j] * X[_j]

	lw $t0, 0($fp)		  # load _i
	sll $t0, $t0, 2	    # convert to byte offset
	lw $t1, 20($fp)		# load Y
	addu $t0, $t1, $t0	  # calculate the address
	add.s $f0, $f2, $f0	 # Y[_i] += T
	s.s $f0, 0($t0)	  # save Y[_i]

	lw $t0, 4($fp)
	addiu $t0, $t0, 1
	sw $t0, 4($fp)	    # _j++

linear_transform_j_check:
  lw $t1, 4($fp)		      # load _j
	lw $t0, 28($fp)		    # load j
	sltu $t0, $t1, $t0	      # if _j < j
	bne $t0, $zero, linear_transform_j_body  # continue
  # else 
	lw $t0, 0($fp)
	addiu $t0, $t0, 1
	sw $t0, 0($fp)	        # _i++

linear_transform_i_check:
	lw $t1, 0($fp)		      # load _i
	lw $t0, 24($fp)		    # load i
	sltu $t0, $t1, $t0	      # if _i < i
	bne $t0, $zero, linear_transform_i_body  # continue
  # else
	move $sp, $fp
	lw $fp, 8($sp)
	addiu $sp, $sp, 28	  # free the stack
	jr $ra                # return