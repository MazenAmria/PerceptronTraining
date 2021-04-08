	.globl assign_vector
assign_vector:
  # Assigns a vector to another
  # $a0: address of the destination vector (i size)
  # $a1: address of the soruce vector (i size)
  # $a2: i (4-bytes integer)

	addiu $sp, $sp, -20
	sw $fp, 4($sp)          # save $fp
	move $fp, $sp
	sw $4, 8($fp)           # save dest
	sw $5, 12($fp)          # save src
	sw $6, 16($fp)          # save i
	sw $0, 0($fp)           # unsigned int _i = 0
	
  j	assign_vector_i_check

assign_vector_i_body:
	lw $2, 0($fp)           # load _i
	sll $2, $2, 2           # convert to bytes offset
	lw $3, 12($fp)          # load src
	addu $3, $3, $2         # calculate the address

	lw $2, 0($fp)           # load _i
	sll $2, $2, 2           # convert to bytes offset
	lw $4, 8($fp)           # load dest
	addu $2, $4, $2         # calculate the address

	lwc1 $f0, 0($3)         # T = src[_i]
	swc1 $f0, 0($2)         # dest[_i] = T

	lw $2, 0($fp)
	addiu $2, $2, 1
	sw $2, 0($fp)           # _i++

assign_vector_i_check:
	lw $2, 16($fp)          # load i 
	lw $3, 0($fp)           # load _i
	sltu $2, $3, $2         # if _i < i
	bne	$2, $0, assign_vector_i_body  # continue
  # else
	move $sp, $fp
	lw $fp, 4($sp)          # pop $fp
	addiu	$sp, $sp, 20      # free the stack
	jr $31                  # return