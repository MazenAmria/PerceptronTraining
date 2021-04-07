	.globl	allocate_matrix
allocate_matrix:
  # Alocates a matrix
  # returns $v0 = Aij
  # $a0: i (4-bytes integer)
  # $a1: j (4-bytes integer)
  
	addiu $sp, $sp, -28
	sw $31, 16($sp)
	sw $fp, 12($sp)
	move $fp, $sp
  sw $4, 24($fp)	  # save i
	sw $5, 20($fp)	  # save j

	lw $4, 24($fp)		# load i
	jal allocate_vector # T = allocate_vector(i) 

  sw $2, 4($fp)     # float ** matrix = T

  sw $0, 0($fp)	    # unsigned int _i = 0
  j allocate_i_check

allocate_i_body:
  lw $4, 20($fp)		# load j
	jal allocate_vector # T = allocate_vector(j)
  
  sw $2, 8($fp)     # float * temp = T
  
  lw $2, 0($fp)     # load _i
	sll $2, $2, 2     # convert to byte offset
	lw $3, 4($fp)     # load matrix
	addu $2, $3, $2   # calculate the address
  lw $3, 8($fp)     # load temp
  sw $3, 0($2)      # matrix[_i] = temp

  lw $2, 0($fp)
	addiu $2, $2, 1
	sw $2, 0($fp)	        # _i++

allocate_i_check:
  lw $3, 0($fp)		      # load _i
	lw $2, 24($fp)		    # load i
	sltu $2, $3, $2	      # if _i < i
	bne $2, $0, allocate_i_body  # continue
  # else
	move $sp, $fp
  lw $2, 4($sp)         # return matrix
	lw $fp, 12($sp)
  lw $31, 16($sp)       # reset the return address
	addiu $sp, $sp, 28	  # free the stack
	jr $31                # return