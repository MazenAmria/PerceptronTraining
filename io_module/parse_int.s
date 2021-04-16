  .globl parse_int
parse_int:
  # Parses an integer from a null terminated string
  # $a0 = pointer to the string
  # Returns:
  # $v0 = the parsed integer

  addiu $sp, $sp, -16
  sw $fp, 8($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save str
  sw $zero, 4($fp)                          # int res = 0
  sw $zero, 0($fp)                          # unsigned int _i = 0

  lw $t0, 12($fp)                           # load str
  lb $t0, 0($t0)                            # load str[0]
  li $t1, 45                                # load '-'
  bne $t0, $t1, parse_int_i_check           # if str[0] != '-' start parsing
  # else
  li $t0, 1
  sw $t0, 0($fp)
  j parse_int_i_check                       # start from str[1]

parse_int_i_body:

  lw $t0, 4($fp)                            # load res
  mul $t0, $t0, 10                          # res *= 10
  sw $t0, 4($fp)

  lw $t1, 0($fp)                            # load _i
  lw $t0, 12($fp)                           # load str
  addu $t0, $t0, $t1                        # calculate the address
  lb $t0, 0($t0)                            # load str[_i]
  addiu $t0, $t0, -48                       # T = str[_i] - '0'
  lw $t1, 4($fp)                            # load res
  addu $t1, $t1, $t0                        # res += T
  sw $t1, 4($fp)

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

parse_int_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 12($fp)                           # load str
  addu $t0, $t0, $t1                        # calculate the address
  lb $t0, 0($t0)                            # load str[_i]
  bne $t0, $zero, parse_int_i_body          # if str[_i] != '\0' continue
  # else
  lw $t0, 12($fp)                           # load str
  lb $t0, 0($t0)                            # load str[0]
  li $t1, 0x2D                              # load '-'
  bne $t0, $t1, parse_int_return            # if str[0] != '-' parsing done
  # else
  lw $t0, 4($fp)
  li $t1, -1
  mul $t0, $t0, $t1
  sw $t0, 4($fp)                            # res *= -1

parse_int_return:

  move $sp, $fp
  lw $fp, 8($sp)
  lw $v0, 4($sp)                            # return res
  addiu $sp, $sp, 16                        # free the stack
  jr $ra                                    # return

