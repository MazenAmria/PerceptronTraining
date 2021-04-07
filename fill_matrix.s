	.globl fill_matrix
fill_matrix:
  # Fills a matrix with a value
  # $a0: address of the destination matrix (ixj size)
  # $a1: i (4-bytes integer)
  # $a2: j (4-bytes integer)
  # $a3: value (4-bytes float)

  addiu $sp, $sp, -24
	sw $fp, 4($sp)
	move $fp, $sp

	sw $4, 8($fp)           # save mat
	sw $5, 12($fp)          # save i
	sw $6, 16($fp)          # save j
	sw $7, 20($fp)          # save val
	sw $0, 0($fp)           # unsigned int _i = 0

	j fill_matrix_i_check

fill_matrix_i_body:
	lw $2, 0($fp)           # load _i
	sll $2, $2, 2           # convert to bytes offset
	lw $3, 8($fp)           # load mat     
	addu $4, $3, $2         # pass $a0 = mat[_i]  
	
  lw $5, 16($fp)          # pass $a1 = j
	lw $6, 20($fp)          # pass $a2 = val
  jal fill_vector         # fill the row

  lw $2, 0($fp)
	addiu $2, $2, 1
	sw $2, 0($fp)           # _i++

fill_matrix_i_check:
	lw $2, 12($fp)          # load i
	lw $3, 0($fp)           # load _i
	sltu $2, $3, $2         # if _i < i
  bne $2, $0, fill_matrix_i_body  # continue
  # else
	move $sp, $fp
	lw $fp, 4($sp)
	addiu	$sp, $sp, 24      # free the stack
	jr $31                  # return