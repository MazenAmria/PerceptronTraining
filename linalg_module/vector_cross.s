  .globl vector_cross
vector_cross:
  # Obtain the matrix from multiplying two vectors
  # Mij = Ai * Bj
  # $a0: address of the first vector (i size)
  # $a1: address of the second vector (j size)
  # $a2: address of the destination matrix (ixj size)
  # $a3: i (4-bytes integer)
  # -4($sp): j (4-bytes integer)

  addiu $sp, $sp, -32
  sw $fp, 8($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save A
  sw $a1, 16($fp)                           # save B
  sw $a2, 20($fp)                           # save M
  sw $a3, 24($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j	vector_cross_i_check                

vector_cross_i_body:                

  sw $zero, 4($fp)                          # unsigned int _j = 0
  j	vector_cross_j_check                

vector_cross_j_body:                

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load A
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f2, 0($t0)                           # T1 = A[_i]

  lw $t0, 4($fp)                            # load _j
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 16($fp)                           # load B
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f0, 0($t0)                           # T2 = B[_j]

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 20($fp)                           # load M
  addu $t0, $t1, $t0                        # calculate the address
  lw $t1, 0($t0)                            # load M[_i]     
  lw $t0, 4($fp)                            # load _j
  sll $t0, $t0, 2                           # convert to bytes address
  addu $t0, $t1, $t0                        # calculate the address of M[_i][_j]

  mul.s $f0, $f2, $f0                       # T = T1 * T2
  s.s $f0, 0($t0)                           # M[_i][_j] = T

  lw $t0, 4($fp)
  addiu $t0, $t0, 1
  sw $t0, 4($fp)                            # _j++

vector_cross_j_check:

  lw $t0, 28($fp)                           # load j
  lw $t1, 4($fp)                            # load _j
  sltu $t0, $t1, $t0                        # if _j < j
  bne	$t0, $zero, vector_cross_j_body       # continue
  # else
  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

vector_cross_i_check:               

  lw $t0, 24($fp)                           # load i
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, vector_cross_i_body       # continue
  # else
  move $sp, $fp
  lw $fp, 8($sp)
  addiu	$sp, $sp, 32                        # free the stack
  jr $ra                                    # return

