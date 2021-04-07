	.globl copy_vector
copy_vector:
  # Copies a vector to another
  # returns $v0 = address of clone(src)
  # $a0: address of the soruce vector (i size)
  # $a1: i (4-bytes integer)

	addiu $sp, $sp, -24
	sw $31, 12($sp)         # save $ra
	sw $fp, 8($sp)          # save $fp
	move $fp, $sp
	sw $4, 16($fp)          # save src
	sw $5, 20($fp)          # save i

	lw $4, 20($fp)          # pass i to allocate_vector
  jal allocate_vector
  
	sw $2, 4($fp)           # save dest
	sw $0, 0($fp)           # unsigned int _i = 0
	
  j	copy_vector_i_check

copy_vector_i_body:
	lw $2, 0($fp)           # load _i
	sll $2, $2, 2           # convert to bytes offset
	lw $3, 16($fp)          # load src
	addu $3, $3, $2         # calculate the address

	lw $2, 0($fp)           # load _i
	sll $2, $2, 2           # convert to bytes offset
	lw $4, 4($fp)           # load dest
	addu $2, $4, $2         # calculate the address

	lwc1 $f0, 0($3)         # T = src[_i]
	swc1 $f0, 0($2)         # dest[_i] = T

	lw $2, 0($fp)
	addiu $2, $2, 1
	sw $2, 0($fp)           # _i++

copy_vector_i_check:
	lw $2, 20($fp)          # load i 
	lw $3, 0($fp)           # load _i
	sltu $2, $3, $2         # if _i < i

	bne	$2, $0, copy_vector_i_body  # continue

	move $sp, $fp
	lw $2, 4($fp)           # return dest
  lw $31, 12($sp)         # pop $ra
	lw $fp, 8($sp)          # pop $fp
	addiu	$sp, $sp, 24      # free the stack
	jr $31                  # return