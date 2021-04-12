  .globl set_in_vector
set_in_vector:
  # Sets an element in a vector with a value
  # vec[_i] = val
  # $a0: address of the destination vector
  # $a1: _i (4-bytes integer)
  # $a2: value (4-bytes float)

  addiu $sp, $sp, -16
  sw $fp, 0($sp)
  move $fp, $sp

  sw $a0, 4($fp)                            # save vec
  sw $a1, 8($fp)                            # save _i
  sw $a2, 12($fp)                           # save val
                  
  lw $t0, 8($fp)                            # load _i
  sll $t0, $t0, 2                           # converts to bytes offset
  lw $t1, 4($fp)                            # load vec
  addu $t0, $t1, $t0                        # calculate the address
                  
  lw $t1, 12($fp)                           # T = val
  sw $t1, 0($t0)                            # vec[_i] = val
                  
  move $sp, $fp                 
  lw $fp, 0($sp)                  
  addiu $sp, $sp, 16                        # free the stack
  jr $ra                                    # return

