  .globl print_hr
print_hr:
  # Prints a horizontal rule
    
  addiu $sp, $sp, -8
  sw $fp, 4($sp)
  move $fp, $sp
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j print_hr_i_check

print_hr_i_body:

  addiu $a0, $zero, '#'                     # load '#'
  addiu $v0, $zero, 11    
  syscall                                   # print '#' 

  lw $t0, 0($fp)           
  addiu $t0, $t0, 1           
  sw $t0, 0($fp)                            # _i++

print_hr_i_check:             

  lw $t0, 0($fp)                            # load _i
  sltiu $t0, $t0, 50                        # if _i < 50
  bne $t0, $zero, print_hr_i_body           # continue
  # else              
  addiu $a0, $zero, 10                      # load '\n'
  addiu $v0, $zero, 11                  
  syscall                                   # print '\n'
  move $sp, $fp
  lw $fp, 4($sp)
  addiu $sp, $sp, 8
  jr $ra
