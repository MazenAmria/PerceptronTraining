	.globl copy_matrix
copy_matrix:
  # Copies a matrix to another
  # returns $v0 = address of clone(src)
  # $a0: address of the soruce matrix (ixj size)
  # $a1: i (4-bytes integer)
  # $a2: j (4-bytes integer)

	addiu $sp, $sp, -28
	sw $31, 12($sp)         # save $ra
	sw $fp, 8($sp)          # save $fp
	move $fp, $sp
	sw $4, 16($fp)          # save src
	sw $5, 20($fp)          # save i
	sw $5, 24($fp)          # save j

	lw $4, 20($fp)          # pass i to allocate_vector
  jal allocate_vector
  
	sw $2, 4($fp)           # save dest
	sw $0, 0($fp)           # unsigned int _i = 0
	
  j	copy_matrix_i_check

copy_matrix_i_body:
	lw $2, 0($fp)           # load _i
	sll $2, $2, 2           # convert to bytes offset
	lw $3, 16($fp)          # load src
	addu $4, $3, $2         # pass src[_i]

  lw $5, 24($fp)          # pass j
  jal copy_vector         # $2 = copy_vector(src[_i], j)

	lw $3, 0($fp)           # load _i
	sll $3, $3, 2           # convert to bytes offset
	lw $8, 4($fp)           # load dest
	addu $3, $8, $3         # calculate the address

  sw $2, 0($3)            # dest[_i] = $2

	lw $2, 0($fp)
	addiu $2, $2, 1
	sw $2, 0($fp)           # _i++

copy_matrix_i_check:
	lw $2, 20($fp)          # load i 
	lw $3, 0($fp)           # load _i
	sltu $2, $3, $2         # if _i < i

	bne	$2, $0, copy_matrix_i_body  # continue

	move $sp, $fp
	lw $2, 4($fp)           # return dest
  lw $31, 12($sp)         # pop $ra
	lw $fp, 8($sp)          # pop $fp
	addiu	$sp, $sp, 28      # free the stack
	jr $31                  # return