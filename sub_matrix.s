  .globl  sub_matrix
sub_matrix:
  # Subtracts a matrix from another
  # Aij -= Bij
  # $a0: address of the destination matrix (ixj size)
  # $a1: address of the source matrix (ixj size)
  # $a2: i (4-bytes integer)
  # $a3: j (4-bytes integer)
  
	addiu	$sp, $sp, -28
	sw $fp, 8($sp)
	move $fp, $sp
	sw $4, 12($fp)	  # save A
	sw $5, 16($fp)	  # save B
	sw $6, 20($fp)	  # save i
  sw $7, 24($fp)    # save j
	sw $0, 0($fp)	    # unsigned int _i = 0
	j sub_matrix_i_check

sub_matrix_i_body:
	sw $0, 4($fp)     # unsigned int _j = 0
	j	sub_matrix_j_check

sub_matrix_j_body:
	lw $2, 0($fp)		  # load _i
	sll $2, $2, 2	    # convert to byte offset
	lw $3, 16($fp)		# load B
	addu $2, $3, $2	  # calculate the address
	lw $3, 0($2)	    # load B[_i]
  lw $2, 4($fp)     # load _j
  sll $2, $2, 2	    # convert to byte offset
  addu $2, $3, $2	  # calculate the address
  lwc1 $f2, 0($2)   # load B[_i][_j]

  lw $2, 0($fp)		  # load _i
	sll $2, $2, 2	    # convert to byte offset
	lw $3, 12($fp)		# load A
	addu $2, $3, $2	  # calculate the address
	lw $3, 0($2)	    # load A[_i]
  lw $2, 4($fp)     # load _j
  sll $2, $2, 2	    # convert to byte offset
  addu $2, $3, $2	  # calculate the address
  lwc1 $f0, 0($2)   # load A[_i][_j]

	sub.s $f0, $f2, $f0	 # T = A[_i][_j] - B[_i][_j]
	swc1 $f0, 0($2)	  # A[_i][_j] = T

	lw $2, 4($fp)
	addiu $2, $2, 1
	sw $2, 4($fp)	    # _j++

sub_matrix_j_check:
  lw $3, 4($fp)		      # load _j
	lw $2, 24($fp)		    # load j
	sltu $2, $3, $2	      # if _j < j
	bne $2, $0, sub_matrix_j_body  # continue
  # else 
	lw $2, 0($fp)
	addiu $2, $2, 1
	sw $2, 0($fp)	        # _i++

sub_matrix_i_check:
	lw $3, 0($fp)		      # load _i
	lw $2, 20($fp)		    # load i
	sltu $2, $3, $2	      # if _i < i
	bne $2, $0, sub_matrix_i_body  # continue
  # else
	move $sp, $fp
	lw $fp, 8($sp)
	addiu $sp, $sp, 28	  # free the stack
	jr $31                # return