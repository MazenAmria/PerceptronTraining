  .globl square_matrix
square_matrix:
  # Squares a matrix (element wise)
  # Aij = Aij^2
  # $a0: address of the matrix (ixj size)
  # $a1: i (4-bytes integer)
  # $a2: j (4-bytes integer)
    
  addiu $sp, $sp, -24
  sw $ra, 8($sp)
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save A
  sw $a1, 16($fp)                           # save i
  sw $a2, 20($fp)                           # save j
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j square_matrix_i_check

square_matrix_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 12($fp)                           # load A
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass A[_i]

  lw $a1, 20($fp)                           # pass j

  jal square_vector

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

square_matrix_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 16($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, square_matrix_i_body      # continue
  # else
  move $sp, $fp
  lw $ra, 8($sp)
  lw $fp, 4($sp)
  addiu $sp, $sp, 24                        # free the stack
  jr $ra                                    # return

