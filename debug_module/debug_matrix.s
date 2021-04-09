  .globl debug_matrix
debug_matrix:
  # Debugs a matrix of floats
  # $a0 = address of the matrix
  # $a1 = number of rows (i)
  # $a2 = number of columns (j)
  # $a3 = address of the message
    
  addiu $sp, $sp, -20
  sw $ra, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save vec
  sw $a1, 12($fp)                           # save i
  sw $a2, 16($fp)                           # save i
  sw $a3, 20($fp)                           # save msg
                  
  jal print_hr                  
                  
  lw $a0, 20($fp)                           # load msg
  addiu $v0, $zero, 4                 
  syscall                                   # print msg
                  
  jal print_hr                  
                      
  lw $a0, 8($fp)                            # load vec
  lw $a1, 12($fp)                           # load i
  lw $a2, 16($fp)                           # load j
  jal print_matrix                 
                
  jal print_hr                 
                
  addiu $a0, $zero, 10                      # load '\n'
  addiu $v0, $zero, 11                  
  syscall                                   # print '\n'
                  
  move $sp, $fp                 
  lw $fp, 0($sp)                  
  lw $ra, 4($sp)                            # pop the return address
  addiu $sp, $sp, 20                        # free the stack
  jr $ra                                    # return