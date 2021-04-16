  .globl set_in_matrix
set_in_matrix:
  # Sets an element in a matrix with a value
  # mat[_i] = val
  # $a0: address of the destination matrix
  # $a1: _i (4-bytes integer)
  # $a2: _j (4-bytes integer)
  # $a3: value (4-bytes float)

  addiu $sp, $sp, -24
  sw $ra, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp

  sw $a0, 8($fp)                            # save mat
  sw $a1, 12($fp)                           # save _i
  sw $a2, 16($fp)                           # save _j
  sw $a3, 20($fp)                           # save val
                  
  lw $t0, 12($fp)                           # load _i
  sll $t0, $t0, 2                           # converts to bytes offset
  lw $t1, 8($fp)                            # load mat
  addu $t0, $t1, $t0                        # calculate the address
                  
  lw $a0, 0($t0)                            # pass mat[_i]
  lw $a1, 16($fp)                           # pass _j
  lw $a2, 20($fp)                           # pass val
  jal set_in_vector                         # mat[_i][_j] = val
                  
  move $sp, $fp                 
  lw $ra, 4($sp)                  
  lw $fp, 0($sp)                  
  addiu $sp, $sp, 24                        # free the stack
  jr $ra                                    # return

