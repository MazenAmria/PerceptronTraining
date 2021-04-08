	.globl print_matrix
print_matrix:
  # Prints a matrix of floats
  # $a0 = address of the matrix
  # $a1 = number of rows (i)
  # $a2 = number of columns (j)

	addiu $sp, $sp, -24
	sw $fp, 4($sp)
	sw $31, 8($sp)
	move $fp, $sp
	sw $4, 12($fp)            # save mat
	sw $5, 16($fp)            # save i
	sw $6, 20($fp)            # save j
	sw $0, 0($fp)             # unsigned int _i = 0
	j	print_matrix_i_check

print_matrix_i_body:

  lw $2, 0($fp)             # load _i
  sll $2, $2, 2             # convert to bytes offset
  lw $3, 12($fp)            # load mat
  addu $2, $3, $2           # calculate the address
  lw $4, 0($2)              # pass mat[_i]
  lw $5, 20($fp)            # pass j
  jal print_vector          # prints the row

  lw $2, 8($fp)
	addiu $2, $2, 1
	sw $2, 8($fp)             # _i++

print_matrix_i_check:
	lw $3, 0($fp)             # load _i
	lw $2, 16($fp)            # load i
	sltu $2, $3, $2           # if _i < i
	bne $2, $0, print_matrix_i_body # continue
  # else
	move $sp, $fp
	lw $fp, 4($sp)
	lw $31, 8($sp)            # pop the return address
	addiu $sp, $sp, 24        # free the stack
	jr $31                    # return
