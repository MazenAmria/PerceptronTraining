  .globl debug_matrix
debug_matrix:
  # Debugs a matrix of floats
  # $a0 = address of the matrix
  # $a1 = number of rows (i)
  # $a2 = number of columns (j)
  # $a3 = address of the message
    
  addiu $sp, $sp, -20
  sw $31, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp
  sw $4, 8($fp)                             # save vec
  sw $5, 12($fp)                            # save i
  sw $6, 16($fp)                            # save i
  sw $7, 20($fp)                            # save msg
                  
  jal print_hr                  
                  
  lw $4, 20($fp)                            # load msg
  addiu $2, $0, 4                 
  syscall                                   # print msg
                  
  jal print_hr                  
                      
  lw $4, 8($fp)                             # load vec
  lw $5, 12($fp)                            # load i
  lw $6, 16($fp)                            # load j
  jal print_matrix                  
                  
  jal print_hr                  
                  
  addiu $4, $0, 10                          # load '\n'
  addiu $2, $0, 11                  
  syscall                                   # print '\n'
                  
  move $sp, $fp                 
  lw $fp, 0($sp)                  
  lw $31, 4($sp)                            # pop the return address
  addiu $sp, $sp, 20                        # free the stack
  jr $31                                    # return