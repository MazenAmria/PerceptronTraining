  .globl sqrt_vector
sqrt_vector:
  # Sqaure root of a vector
  # Ai = sqrt(Ai)
  # $a0: address of the vector (i size)
  # $a1: i (4-bytes integer)

  addiu $sp, $sp, -16
  sw $fp, 4($sp)                            # save $fp
  move $fp, $sp
  sw $a0, 8($fp)                            # save A
  sw $a2, 12($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  
  j sqrt_vector_i_check

sqrt_vector_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 8($fp)                            # load A
  addu $t0, $t1, $t0                        # calculate the address

  lw $a0, 0($t0)                            # pass A[_i]
  jal sqrt

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $a0, 8($fp)                            # load A
  addu $t0, $a0, $t0                        # calculate the address

  sw $v0, 0($t0)                            # A[_i] = $v0

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

sqrt_vector_i_check:

  lw $t0, 12($fp)                           # load i 
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, sqrt_vector_i_body        # continue
  # else
  move $sp, $fp
  lw $fp, 4($sp)                            # pop $fp
  addiu $sp, $sp, 16                        # free the stack
  jr $ra                                    # return

