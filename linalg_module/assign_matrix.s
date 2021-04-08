	.globl assign_matrix
assign_matrix:
  # Assigns a matrix to another
  # $a0: address of the destination matrix (ixj size)
  # $a1: address of the soruce matrix (ixj size)
  # $a2: i (4-bytes integer)
  # $a3: j (4-bytes integer)

	addiu $sp, $sp, -28
	sw $31, 8($sp)          # save $ra
	sw $fp, 4($sp)          # save $fp
	move $fp, $sp
	sw $4, 12($fp)          # save dest
	sw $5, 16($fp)          # save src
	sw $6, 20($fp)          # save i
  sw $7, 24($fp)          # save j
	sw $0, 0($fp)           # unsigned int _i = 0
	
  j	assign_matrix_i_check

assign_matrix_i_body:
  lw $2, 0($fp)           # load _i
	sll $2, $2, 2           # convert to bytes offset
	lw $4, 12($fp)          # load dest
	addu $4, $4, $2         # pass dest[_i]

	lw $2, 0($fp)           # load _i
	sll $2, $2, 2           # convert to bytes offset
	lw $3, 16($fp)          # load src
	addu $5, $3, $2         # pass src[_i]

  lw $6, 24($fp)          # pass j
  jal assign_vector

	lw $2, 0($fp)
	addiu $2, $2, 1
	sw $2, 0($fp)           # _i++

assign_matrix_i_check:
	lw $2, 20($fp)          # load i 
	lw $3, 0($fp)           # load _i
	sltu $2, $3, $2         # if _i < i
	bne	$2, $0, assign_matrix_i_body  # continue
  # else
	move $sp, $fp
  lw $31, 8($sp)          # pop $ra
	lw $fp, 4($sp)          # pop $fp
	addiu	$sp, $sp, 28      # free the stack
	jr $31                  # return