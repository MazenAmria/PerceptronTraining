  .globl parse_tuple
parse_tuple:
  # Parses a tuple of data with the format 
  # (float,float,float,float,...,int)
  # $a0 = pointer to the tuple
  # $a1 = address of the feature vector
  # $a2 = number of features (j)
  # Returns:
  # $v0 = class number

  addiu $sp, $sp, -28
  sw $ra, 12($sp)
  sw $fp, 8($sp)
  move $fp, $sp
  sw $a0, 24($fp)                           # save str
  sw $a1, 20($fp)                           # save X[_i]
  sw $a2, 16($fp)                           # save j
  sw $zero, 4($fp)                          # unsigned int _j = 0

  lw $a0, 24($fp)                           # pass str
  li $a1, 44                                # pass ','
  jal tokenize                              # split

  j parse_tuple_j_check

parse_tuple_j_body:

  lw $a0, 24($fp)                           # pass str
  jal forward_token
  lw $a0, 24($fp)                           # pass str
  sw $v0, 24($fp)                           # str <-- next token
  jal parse_float

  lw $t1, 4($fp)                            # load _j
  sll $t1, $t1, 2                           # convert to bytes address
  lw $t0, 20($fp)                           # load X[_i]
  addu $t0, $t0, $t1                        # calculate the address
  sw $v0, 0($t0)                            # X[_i][_j] = parsed float

  lw $t0, 4($fp)
  addiu $t0, $t0, 1
  sw $t0, 4($fp)                            # _j++

parse_tuple_j_check:

  lw $t1, 4($fp)                            # load _j
  lw $t0, 16($fp)                           # load j
  sltu $t0, $t1, $t0                        # if _j < j
  bne $t0, $zero, parse_tuple_j_body        # continue
  # else
  lw $a0, 24($fp)                           # pass str
  jal parse_int                             # parse the class number
  sw $v0, 0($fp)

  move $sp, $fp
  lw $ra, 12($sp)
  lw $fp, 8($sp)
  lw $v0, 0($sp)                            # return class number
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return 

