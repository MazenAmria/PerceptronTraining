  .globl print_matrix
print_matrix:
  # Prints a matrix of floats
  # $a0 = address of the matrix
  # $a1 = number of rows (i)
  # $a2 = number of columns (j)

  addiu $sp, $sp, -24
  sw $fp, 4($sp)
  sw $ra, 8($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save mat
  sw $a1, 16($fp)                           # save i
  sw $a2, 20($fp)                           # save j
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j	print_matrix_i_check                
          
print_matrix_i_body:                
          
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load mat
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass mat[_i]
  lw $a1, 20($fp)                           # pass j
  jal print_vector                          # prints the row
          
  lw $t0, 0($fp)               
  addiu $t0, $t0, 1               
  sw $t0, 0($fp)                            # _i++
          
print_matrix_i_check:    

  lw $t1, 0($fp)                            # load _i
  lw $t0, 16($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, print_matrix_i_body       # continue
  # else          
  move $sp, $fp         
  lw $fp, 4($sp)          
  lw $ra, 8($sp)                            # pop the return address
  addiu $sp, $sp, 24                        # free the stack
  jr $ra                                    # return
