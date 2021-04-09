  .globl debug_vector
debug_vector:
  # Debugs a vector of floats
  # $a0 = address of the vector
  # $a1 = size of the vector
  # $a2 = address of the message
    
  addiu $sp, $sp, -16
  sw $31, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp
  sw $4, 8($fp)                             # save vec
  sw $5, 12($fp)                            # save i
  sw $6, 16($fp)                            # save msg

  jal print_hr                  

  lw $4, 16($fp)                            # load msg
  addiu $2, $0, 4                 
  syscall                                   # print msg

  jal print_hr                  

  lw $4, 8($fp)                             # load vec
  lw $5, 12($fp)                            # load i
  jal print_vector                  

  jal print_hr                  

  addiu $4, $0, 10                          # load '\n'
  addiu $2, $0, 11                  
  syscall                                   # print '\n'

  move $sp, $fp                 
  lw $fp, 0($sp)                  
  lw $31, 4($sp)                            # pop the return address
  addiu $sp, $sp, 16                        # free the stack
  jr $31                                    # return

