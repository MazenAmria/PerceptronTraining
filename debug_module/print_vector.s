	.globl print_vector
print_vector:
  # Prints a vector of floats
  # $a0 = address of the vector
  # $a1 = size of the vector
    
  addiu $sp, $sp, -16
  sw $fp, 4($sp)
  move $fp, $sp         
  sw $4, 8($fp)                             # save vec
  sw $5, 12($fp)                            # save i
  sw $0, 0($fp)                             # unsigned int _i = 0
  j	print_vector_i_check                  
          
print_vector_i_body:                  

  lw $2, 0($fp)                             # load _i
  sll $2, $2, 2                             # convert to bytes offset
  lw $3, 8($fp)                             # load vec
  addu $2, $3, $2                           # calculate the address
  l.s $f12, 0($2)                           # load vec[_i]
  addiu $2, $0, 2                 
  syscall                                   # print vec[_i]

  addiu $4, $0, 9                           # load '\t'
  addiu $2, $0, 11                  
  syscall                                   # print '\t'      

  lw $2, 0($fp)                 
  addiu $2, $2, 1                 
  sw $2, 0($fp)                             # _i++

print_vector_i_check:                 

  lw $3, 0($fp)                             # load _i
  lw $2, 12($fp)                            # load i
  sltu $2, $3, $2                           # if _i < i
  bne $2, $0, print_vector_i_body           # continue
  # else          
  addiu $4, $0, 10                          # load '\n'
  addiu $2, $0, 11                  
  syscall                                   # print '\n' 
  move $sp, $fp         
  lw $fp, 4($sp)          
  addiu $sp, $sp, 16                        # free the stack
  jr $31                                    # return

