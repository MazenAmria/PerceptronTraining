  .globl strlen
strlen:
  # Returns the length of a null terminated string.
  # $a0 = pointer of the string
  # Returns:
  # $v0 = length of the string

  addiu $sp, $sp, -12
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save str
  sw $zero, 0($fp)                          # unsigned int _i = 0

  j strlen_i_check

strlen_i_body:

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

strlen_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 8($fp)                            # load str
  addu $t0, $t0, $t1                        # calculate the address
  lb $t2, 0($t0)                            # load str[_i]
  bne $t2, $zero, strlen_i_body             # if str[_i] != '\0' continue
  # else
  move $sp, $fp
  lw $v0, 0($fp)                            # return _i
  lw $fp, 4($sp)
  addiu $sp, $sp, 12                        # free the stack
  jr $ra                                    # return

