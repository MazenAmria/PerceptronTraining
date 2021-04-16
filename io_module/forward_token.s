  .globl forward_token
forward_token:
  # Forwards the pointer to the next token in a tokenized string.
  # $a0 = pointer of the tokenized string
  # Returns:
  # $v0 = pointer to the next token

  addiu $sp, $sp, -12
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save str
  sw $zero, 0($fp)                          # unsigned int _i = 0

  j forward_token_i_check

forward_token_i_body:

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

forward_token_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 8($fp)                            # load str
  addu $t0, $t0, $t1                        # calculate the address
  lb $t2, 0($t0)                            # load str[_i]
  bne $t2, $zero, forward_token_i_body      # if str[_i] != '\0' continue
  # else
  move $sp, $fp
  addu $v0, $t0, 1                          # return (str + _i + 1)
  lw $fp, 4($sp)
  addiu $sp, $sp, 12                        # free the stack
  jr $ra                                    # return

