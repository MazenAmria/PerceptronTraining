  .globl tokenize
tokenize:
  # Tokenizes a string by a certain delimiter
  # $a0 = pointer to the string
  # $a1 = the delimiter

  addiu $sp, $sp, -16
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save str
  sw $a1, 8($fp)                            # save deli
  sw $zero, 0($fp)                          # unsigned int _i = 0

  j tokenize_i_check

tokenize_i_body:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 12($fp)                           # load str
  addu $t0, $t0, $t1                        # calculate the address
  lb $t0, 0($t0)                            # load str[_i]
  lw $t1, 8($fp)                            # load deli
  bne $t0, $t1, tokenize_i_forward          # if str[_i] != deli continue
  # else
  lw $t1, 0($fp)                            # load _i
  lw $t0, 12($fp)                           # load str
  addu $t0, $t0, $t1                        # calculate the address
  sb $zero, 0($t0)                          # str[_i] = '\0' 

tokenize_i_forward:

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

tokenize_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 12($fp)                           # load str
  addu $t0, $t0, $t1                        # calculate the address
  lb $t0, 0($t0)                            # load str[_i]
  bne $t0, $zero, tokenize_i_body           # if str[_i] != '\0' continue
  # else
  move $sp, $fp
  lw $fp, 4($sp)
  addiu $sp, $sp, 16                        # free the stack
  jr $ra                                    # return

