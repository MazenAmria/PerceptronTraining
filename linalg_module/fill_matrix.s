  .globl fill_matrix
fill_matrix:
  # Fills a matrix with a value
  # $a0: address of the destination matrix (ixj size)
  # $a1: i (4-bytes integer)
  # $a2: j (4-bytes integer)
  # $a3: value (4-bytes float)

  addiu $sp, $sp, -28
  sw $ra, 8($sp)
  sw $fp, 4($sp)
  move $fp, $sp

  sw $a0, 12($fp)                           # save mat
  sw $a1, 16($fp)                           # save i
  sw $a2, 20($fp)                           # save j
  sw $a3, 24($fp)                           # save val
  sw $zero, 0($fp)                          # unsigned int _i = 0

  j fill_matrix_i_check             

fill_matrix_i_body:             

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load mat     
  addu $t0, $t1, $t0                        # calculate the address  

  lw $a0, 0($t0)                            # pass $a0 = mat[_i]
  lw $a1, 20($fp)                           # pass $a1 = j
  lw $a2, 24($fp)                           # pass $a2 = val
  jal fill_vector                           # fill the row

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

fill_matrix_i_check:

  lw $t0, 16($fp)                           # load i
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, fill_matrix_i_body        # continue
  # else
  move $sp, $fp
  lw $ra, 8($sp)
  lw $fp, 4($sp)
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return

