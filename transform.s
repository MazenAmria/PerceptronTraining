  .globl	transform
transform:
  # Transforms a vector (Change Basis)
  # Wij * Xj = Yi
  # $a0: address of the input vector (j size)
  # $a1: address of the change of basis matrix (ixj size)
  # $a2: address of the output vector (i size)
  # $a3: i (4-bytes integer)
  # 0($sp): j (4-bytes integer)
  
	addiu	$sp, $sp, -28
	sw $fp, 8($sp)
	move $fp, $sp
	sw $4, 12($fp)	  # save X
	sw $5, 16($fp)	  # save W
	sw $6, 20($fp)	  # save Y
	sw $7, 24($fp)	  # save i
	sw $0, 0($fp)	    # unsigned int _i = 0
	j transform_i_check

transform_i_body:
	lw $2, 0($fp)     # load _i
	sll $2, $2, 2     # convert to byte offset
	lw $3, 20($fp)    # load Y
	addu $2, $3, $2   # calculate the address
	sw $0, 0($2)      # Y[_i] = 0

	sw $0, 4($fp)     # unsigned int _j = 0
	j	transform_j_check

transform_j_body:
	lw $2, 0($fp)		  # load _i
	sll $2, $2, 2	    # convert to byte offset
	lw $3, 20($fp)		# load Y
	addu $2, $3, $2	  # calculate the address
	lwc1 $f2, 0($2)	  # load Y[_i]

	lw $2, 0($fp)		  # load _i
	sll $2, $2, 2	    # convert to byte offset
	lw $3, 16($fp)		# load W
	addu $2, $3, $2	  # calculate the address of the row
	lw $3, 0($2)		  # load W[_i]

	lw $2, 4($fp)		  # load _j
	sll $2, $2, 2	    # convert to byte offset
	addu $2, $3, $2	  # calculate the address
	lwc1 $f4, 0($2)	  # load W[_i][_j]

	lw $2, 4($fp)		  # load _j
	sll $2, $2, 2	    # convert to byte offset
	lw $3, 16($fp)		# load X
	addu $2, $3, $2	  # calculate the address
	lwc1 $f0, 0($2)	  # load X[_j]

	mul.s $f0, $f4, $f0	 # T = W[_i][_j] * X[_j]

	lw $2, 0($fp)		  # load _i
	sll $2, $2, 2	    # convert to byte offset
	lw $3, 20($fp)		# load Y
	addu $2, $3, $2	  # calculate the address
	add.s $f0, $f2, $f0	 # Y[_i] += T
	swc1 $f0, 0($2)	  # save Y[_i]

	lw $2, 4($fp)
	addiu $2, $2, 1
	sw $2, 4($fp)	    # _j++

transform_j_check:
  lw $3, 4($fp)		      # load _j
	lw $2, 28($fp)		    # load j
	sltu $2, $3, $2	      # if _j < j
	bne $2, $0, transform_j_body  # continue
  # else 
	lw $2, 0($fp)
	addiu $2, $2, 1
	sw $2, 0($fp)	        # _i++

transform_i_check:
	lw $3, 0($fp)		      # load _i
	lw $2, 24($fp)		    # load i
	sltu $2, $3, $2	      # if _i < i
	bne $2, $0, transform_i_body  # continue
  # else
	move $sp, $fp
	lw $fp, 8($sp)
	addiu $sp, $sp, 28	  # free the stack
	jr $31                # return