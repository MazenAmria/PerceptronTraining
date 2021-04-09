	.globl print_vector
print_vector:
  # Prints a vector of floats
  # $a0 = address of the vector
  # $a1 = size of the vector
    
  addiu $sp, $sp, -16
  sw $fp, 4($sp)
  move $fp, $sp         
  sw $a0, 8($fp)                            # save vec
  sw $a1, 12($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j	print_vector_i_check                  
          
print_vector_i_body:                  

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 8($fp)                            # load vec
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f12, 0($t0)                          # load vec[_i]
  addiu $v0, $zero, 2                 
  syscall                                   # print vec[_i]

  addiu $a0, $zero, 9                       # load '\t'
  addiu $v0, $zero, 11                  
  syscall                                   # print '\t'      

  lw $t0, 0($fp)                 
  addiu $t0, $t0, 1                 
  sw $t0, 0($fp)                            # _i++

print_vector_i_check:                 

  lw $t1, 0($fp)                            # load _i
  lw $t0, 12($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, print_vector_i_body       # continue
  # else          
  addiu $a0, $zero, 10                      # load '\n'
  addiu $v0, $zero, 11                  
  syscall                                   # print '\n' 
  move $sp, $fp         
  lw $fp, 4($sp)          
  addiu $sp, $sp, 16                        # free the stack
  jr $ra                                    # return

