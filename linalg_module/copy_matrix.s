	.globl copy_matrix
copy_matrix:
  # Copies a matrix to another
  # returns $v0 = address of clone(src)
  # $a0: address of the soruce matrix (ixj size)
  # $a1: i (4-bytes integer)
  # $a2: j (4-bytes integer)

	addiu $sp, $sp, -28
	sw $ra, 12($sp)         # save $ra
	sw $fp, 8($sp)          # save $fp
	move $fp, $sp
	sw $a0, 16($fp)          # save src
	sw $a1, 20($fp)          # save i
	sw $a2, 24($fp)          # save j

	lw $a0, 20($fp)          # pass i to allocate_vector
  jal allocate_vector
  
	sw $v0, 4($fp)           # save dest
	sw $zero, 0($fp)           # unsigned int _i = 0
	
  j	copy_matrix_i_check

copy_matrix_i_body:
	lw $t0, 0($fp)           # load _i
	sll $t0, $t0, 2           # convert to bytes offset
	lw $t1, 16($fp)          # load src
	addu $t0, $t1, $t0         # calculate the address
  lw $a0, 0($t0)              # pass src[_i]

  lw $a1, 24($fp)          # pass j
  jal copy_vector         # $t0 = copy_vector(src[_i], j)

	lw $t1, 0($fp)           # load _i
	sll $t1, $t1, 2           # convert to bytes offset
	lw $t0, 4($fp)           # load dest
	addu $t1, $t0, $t1         # calculate the address

  sw $v0, 0($t1)            # dest[_i] = $t0

	lw $t0, 0($fp)
	addiu $t0, $t0, 1
	sw $t0, 0($fp)           # _i++

copy_matrix_i_check:
	lw $t0, 20($fp)          # load i 
	lw $t1, 0($fp)           # load _i
	sltu $t0, $t1, $t0         # if _i < i

	bne	$t0, $zero, copy_matrix_i_body  # continue

	move $sp, $fp
	lw $v0, 4($fp)           # return dest
  lw $ra, 12($sp)         # pop $ra
	lw $fp, 8($sp)          # pop $fp
	addiu	$sp, $sp, 28      # free the stack
	jr $ra                  # return