	.globl print_hr
print_hr:
  # Prints a horizontal rule
  
	addiu $sp, $sp, -8
	sw $fp, 4($sp)
	move $fp, $sp
	sw $0, 0($fp)             # unsigned int _i = 0
	j print_hr_i_check

print_hr_i_body:

  addiu $4, $0, '#'         # load '#'
  addiu $2, $0, 11
  syscall                   # print '#' 

	lw $2, 0($fp)
	addiu $2, $2, 1
	sw $2, 0($fp)             # _i++

print_hr_i_check:
	lw $2, 0($fp)             # load _i
	sltu $2, $2, 20           # if _i < 20
	bne $2, $0, print_hr_i_body # continue
  
  # else
	
  addiu $4, $0, 10        # load '\n'
  addiu $2, $0, 11
  syscall                 # print '\n'

  move $sp, $fp
	lw $fp, 4($sp)
	addiu $sp, $sp, 8
	jr $31
