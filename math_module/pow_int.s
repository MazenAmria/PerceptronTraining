  .globl pow_int
pow_int:
  # Raises an integer number to another integer number
  # using Binary Exponentiation Algorithm
  # res = x^y
  # $a0 = x
  # $a1 = y
  # Returns:
  # $v0 = res

  addiu $sp, $sp, -12
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save x
  sw $a1, 8($fp)                            # save y

  li $t0, 1
  sw $t0, 0($fp)                            # int res = 1

  j pow_int_i_check

pow_int_i_body:

  lw $t0, 8($sp)                            # load y
  andi $t0, 1
  beq $t0, $zero, pow_int_i_forward         # if !(y & 1) continue
  # else
  lw $t0, 0($fp)                            # load res
  lw $t1, 12($fp)                           # load x
  mul $t0, $t0, $t1
  sw $t0, 0($fp)                            # res *= x

pow_int_i_forward:

  lw $t0, 12($fp)                           # load x
  mul $t0, $t0, $t0
  sw $t0, 12($fp)                           # x *= x
  lw $t0, 8($fp)                            # load y
  sra $t0, $t0, 1
  sw $t0, 8($fp)                            # y /= 2

pow_int_i_check:

  lw $t0, 8($fp)                            # load y
  bne $t0, $zero, pow_int_i_body            # if y != 0 continue
  # else
  move $sp, $fp
  lw $fp, 4($sp)
  lw $v0, 0($sp)                            # return res
  addiu $sp, $sp, 12                        # free the stack
  jr $ra                                    # return

