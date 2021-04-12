  .globl allocate_matrix
allocate_matrix:
  # Alocates a matrix
  # returns $v0 = Aij
  # $a0: i (4-bytes integer)
  # $a1: j (4-bytes integer)
    
  addiu $sp, $sp, -28
  sw $ra, 16($sp)
  sw $fp, 12($sp)
  move $fp, $sp
  sw $a0, 24($fp)                           # save i
  sw $a1, 20($fp)                           # save j
      
  lw $a0, 24($fp)                           # load i
  jal allocate_vector                       # T = allocate_vector(i) 
      
  sw $v0, 4($fp)                            # float ** matrix = T
      
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j allocate_i_check      
      
allocate_i_body:      
      
  lw $a0, 20($fp)                           # load j
  jal allocate_vector                       # T = allocate_vector(j)
        
  sw $v0, 8($fp)                            # float * temp = T
        
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 4($fp)                            # load matrix
  addu $t0, $t1, $t0                        # calculate the address
  lw $t1, 8($fp)                            # load temp
  sw $t1, 0($t0)                            # matrix[_i] = temp
      
  lw $t0, 0($fp)      
  addiu $t0, $t0, 1     
  sw $t0, 0($fp)                            # _i++
      
allocate_i_check:     
      
  lw $t1, 0($fp)                            # load _i
  lw $t0, 24($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, allocate_i_body           # continue
  # else      
  move $sp, $fp     
  lw $v0, 4($sp)                            # return matrix
  lw $fp, 12($sp)     
  lw $ra, 16($sp)                           # reset the return address
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return

