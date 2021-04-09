  .globl debug_vector
debug_vector:
  # Debugs a vector of floats
  # $a0 = address of the vector
  # $a1 = size of the vector
  # $a2 = address of the message
    
  addiu $sp, $sp, -20
  sw $ra, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save vec
  sw $a1, 12($fp)                           # save i
  sw $a2, 16($fp)                           # save msg

  jal print_hr                  

  lw $a0, 16($fp)                           # load msg
  addiu $v0, $zero, 4                 
  syscall                                   # print msg

  jal print_hr                  

  lw $a0, 8($fp)                            # load vec
  lw $a1, 12($fp)                           # load i
  jal print_vector                  

  jal print_hr                  

  addiu $a0, $zero, 10                      # load '\n'
  addiu $v0, $zero, 11                  
  syscall                                   # print '\n'

  move $sp, $fp                 
  lw $fp, 0($sp)                  
  lw $ra, 4($sp)                            # pop the return address
  addiu $sp, $sp, 20                        # free the stack
  jr $ra                                    # return

