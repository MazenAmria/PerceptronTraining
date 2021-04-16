  .globl parse_input
parse_input:
  # Parses a list of tuples of data with the format 
  # (float,float,float,float,...,int)
  # $a0 = pointer to the input
  # $a1 = address of the features matrix
  # $a2 = address of classes matrix
  # $a3 = number of tuples (i)
  # -8($sp) = number of features (j)
  # -4($sp) = number of features (k)

  addiu $sp, $sp, -36
  sw $ra, 8($sp)
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save buff
  sw $a1, 16($fp)                           # save X
  sw $a2, 20($fp)                           # save Yd
  sw $a3, 24($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0

  lw $a0, 12($fp)                           # pass buff
  li $a1, 10                                # pass '\n'
  jal tokenize                              # split

  j parse_input_i_check

parse_input_i_body:

  lw $a0, 12($fp)                           # pass buff
  jal forward_token
  lw $a0, 12($fp)                           # pass buff
  sw $v0, 12($fp)                           # buff <-- next token

  lw $t1, 0($fp)                            # load _i
  sll $t1, $t1, 2                           # convert to bytes address
  lw $t0, 16($fp)                           # load X
  addu $t0, $t0, $t1                        # calculate the address
  lw $a1, 0($t0)                            # pass X[_i]

  lw $a2, 28($fp)                           # pass j

  jal parse_tuple

  lw $t0, 32($fp)                           # load k
  li $t1, 2                                 # load 2
  sltu $t0, $t0, $t1                        # if k < 2
  bne $t0, $zero, parse_input_encoded       # already encoded
  # else
  move $a0, $v0                             # pass class number

  lw $t1, 0($fp)                            # load _i
  sll $t1, $t1, 2                           # convert to bytes offset
  lw $t0, 20($fp)                           # load Yd
  addu $t0, $t0, $t1                        # calculate the address
  lw $a1, 0($t0)                            # pass Yd[_i]

  lw $a2, 32($fp)                           # pass k
  
  jal one_hot_encoding
  
  j parse_input_i_forward

parse_input_encoded:

  lw $a0, 20($fp)                           # pass Yd
  lw $a1, 0($fp)                            # pass _i
  move $a2, $zero                           # pass _j = 0
  mtc1 $v0, $f0
  cvt.s.w $f0, $f0
  mfc1 $a3, $f0                             # pass class number
  jal set_in_matrix

parse_input_i_forward:

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

parse_input_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 24($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, parse_input_i_body        # continue
  # else
  move $sp, $fp
  lw $ra, 8($sp)
  lw $fp, 4($sp)
  addiu $sp, $sp, 36                        # free the stack
  jr $ra                                    # return 

