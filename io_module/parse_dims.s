  .globl parse_dims
parse_dims:
  # Parses and save the dimensions of the inputs
  # with format (i,j,k)
  # $a0 = pointer to the string
  # Returns:
  # $v0 = i
  # $v1 = j
  # -4($fp) = k

  addiu $sp, $sp, -24
  sw $ra, 16($sp)
  sw $fp, 12($sp)
  move $fp, $sp
  sw $a0, 20($fp)                           # save str

  lw $a0, 20($fp)                           # pass str
  li $a1, 44                                # pass ','
  jal tokenize                              # split

  lw $a0, 20($fp)                           # pass str
  jal parse_int
  sw $v0, 8($fp)

  lw $a0, 20($fp)                           # pass str
  jal forward_token
  sw $v0, 20($fp)

  lw $a0, 20($fp)                           # pass str
  jal parse_int
  sw $v0, 4($fp)

  lw $a0, 20($fp)                           # pass str
  jal forward_token
  sw $v0, 20($fp)

  lw $a0, 20($fp)                           # pass str
  jal parse_int
  sw $v0, 0($fp)

  move $sp, $fp
  lw $ra, 16($sp)
  lw $fp, 12($sp)
  lw $v0, 8($sp)                            # return i
  lw $v1, 4($sp)                            # return j
  lw $t0, 0($sp)
  sw $t0, -4($fp)                           # return k
  addiu $sp, $sp, 24                        # free the stack
  jr $ra                                    # return 

