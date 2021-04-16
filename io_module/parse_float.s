  .globl parse_float
parse_float:
  # Parses a float from a null terminated string
  # $a0 = pointer to the string
  # Returns:
  # $v0 = the parsed float

  addiu $sp, $sp, -28
  sw $ra, 20($sp)
  sw $fp, 16($sp)
  move $fp, $sp
  sw $a0, 24($fp)                           # save str
  sw $zero, 12($fp)                         # float res = 0

  lw $a0, 24($fp)                           # pass str
  li $a1, 46                                # pass '.'
  jal tokenize                              # separate the integer part and the fraction part

  lw $a0, 24($fp)                           # pass str
  jal parse_int                             # parse the integer part
  mtc1 $v0, $f0
  cvt.s.w $f0, $f0                          # convert it to float
  s.s $f0, 12($fp)                          # res = integer part of the float

  lw $a0, 24($fp)                           # pass str
  jal forward_token
  sw $v0, 24($fp)                           # str = next_token (fraction part)

  lw $a0, 24($fp)                           # pass str
  jal strlen
  sw $v0, 8($fp)                            # save len

  lw $a0, 24($fp)                           # pass str
  jal parse_int                             # parse the fraction part
  mtc1 $v0, $f0
  cvt.s.w $f0, $f0                          # convert it to float
  s.s $f0, 4($fp)                           # save fraction

  lw $t0, 12($fp)                           # load res
  lui $t1, 0x8000                           # bitmask to check the sign bit
  and $t0, $t0, $t1
  beq $t0, $zero, parse_float_positive      # if res is positive continue
  # else
  lw $t0, 4($fp)                            # load fraction
  or $t0, $t0, $t1                          # set the sign bit
  sw $t0, 4($fp)

parse_float_positive:

  li $a0, 10                                # pass 10
  lw $a1, 8($fp)                            # pass len
  jal pow_int                               # calculate 10^len
  mtc1 $v0, $f0
  cvt.s.w $f0, $f0                          # convert it to float
  s.s $f0, 0($fp)                           # save denominator

  l.s $f0, 12($fp)                          # load res
  l.s $f2, 4($fp)                           # load fraction
  l.s $f4, 0($fp)                           # load denominator
  div.s $f2, $f2, $f4                       # fraction /= denominator
  add.s $f0, $f0, $f2                       # res += fraction
  s.s $f0, 12($fp)                          # save res

  move $sp, $fp
  lw $ra, 20($sp)
  lw $fp, 16($sp)
  lw $v0, 12($sp)                           # return res
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return 

