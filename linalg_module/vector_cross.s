	.globl vector_cross
vector_cross:
  # Obtain the matrix from multiplying two vectors
  # Mij = Ai * Bj
  # $a0: address of the first vector (i size)
  # $a1: address of the second vector (j size)
  # $a2: address of the destination matrix (ixj size)
  # $a3: i (4-bytes integer)
  # 0($sp): j (4-bytes integer)

	addiu $sp, $sp, -32
	sw $fp, 8($sp)
	move $fp, $sp
	sw $4, 12($fp)        # save A
	sw $5, 16($fp)        # save B
	sw $6, 20($fp)        # save M
	sw $7, 24($fp)        # save i
	sw $0, 0($fp)         # unsigned int _i = 0
	j	vector_cross_i_check

vector_cross_i_body:
	sw $0, 4($fp)         # unsigned int _j = 0
	j	vector_cross_j_check

vector_cross_j_body:
	lw $2, 0($fp)         # load _i
	sll $2, $2, 2         # convert to bytes offset
	lw $3, 12($fp)        # load A
	addu $2, $3, $2       # calculate the address
	lwc1 $f2, 0($2)       # T1 = A[_i]
	
  lw $2, 4($fp)         # load _j
	sll $2, $2, 2         # convert to bytes offset
	lw $3, 16($fp)        # load B
	addu $2, $3, $2       # calculate the address
	lwc1 $f0, 0($2)       # T2 = B[_j]
	
  lw $2, 0($fp)         # load _i
	sll $2, $2, 2         # convert to bytes offset
	lw $3, 20($fp)        # load M
	addu $2, $3, $2       # calculate the address
	lw $3, 0($2)          # load M[_i]     
	lw $2, 4($fp)         # load _j
	sll $2, $2, 2         # convert to bytes address
	addu $2, $3, $2       # calculate the address of M[_i][_j]
	
  mul.s $f0, $f2, $f0   # T = T1 * T2
	swc1 $f0, 0($2)       # M[_i][_j] = T

	lw $2, 4($fp)
	addiu $2, $2, 1
	sw $2, 4($fp)         # _j++

vector_cross_j_check:
	lw $2, 28($fp)        # load j
	lw $3, 4($fp)         # load _j
	sltu $2, $3, $2       # if _j < j
	bne	$2, $0, vector_cross_j_body
  # else
	lw $2, 0($fp)
	addiu $2, $2, 1
	sw $2, 0($fp)         # _i++

vector_cross_i_check:
	lw $2, 24($fp)        # load i
	lw $3, 0($fp)         # load _i
	sltu $2, $3, $2       # if _i < i
	bne $2, $0, vector_cross_i_body
  # else
	move $sp, $fp
	lw $fp, 8($sp)
	addiu	$sp, $sp, 32    # free the stack
	jr $31                # return
