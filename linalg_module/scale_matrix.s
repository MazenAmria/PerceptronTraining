  .globl  scale_matrix
scale_matrix:
  # Scales a matrix by constant value
  # Aij *= K
  # $a0: address of the destination matrix (ixj size)
  # $a1: value of the scalar
  # $a2: i (4-bytes integer)
  # $a3: j (4-bytes integer)
  
	addiu	$sp, $sp, -28
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	move $fp, $sp
	sw $a0, 12($fp)	  # save A
	sw $a1, 16($fp)	  # save K
	sw $a2, 20($fp)	  # save i
  sw $a3, 24($fp)    # save j
	sw $zero, 0($fp)	    # unsigned int _i = 0
	j scale_matrix_i_check

scale_matrix_i_body:
	lw $t0, 0($fp)		  # load _i
	sll $t0, $t0, 2	    # convert to byte offset
	lw $t1, 12($fp)		# load A
	addu $t0, $t1, $t0	  # calculate the address
  lw $a0, 0($t0)        # pass A[_i]

	lw $a1, 16($fp)		# pass K

  lw $a2, 24($fp)    # pass j
  jal scale_vector

	lw $t0, 0($fp)
	addiu $t0, $t0, 1
	sw $t0, 0($fp)	        # _i++

scale_matrix_i_check:
	lw $t1, 0($fp)		      # load _i
	lw $t0, 20($fp)		    # load i
	sltu $t0, $t1, $t0	      # if _i < i
	bne $t0, $zero, scale_matrix_i_body  # continue
  # else
	move $sp, $fp
	lw $ra, 4($sp)
	lw $fp, 8($sp)
	addiu $sp, $sp, 28	  # free the stack
	jr $ra                # return