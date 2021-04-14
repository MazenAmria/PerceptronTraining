  .globl sqrt
sqrt:
  # Calculates the square root of a float
  # $a0: float number n
  # Returns:
  # $v0: square root of n

  addiu $sp, $sp, -8
  sw $fp, 0($sp)
  move $fp, $sp
  sw $a0, 4($sp)                            # save n

  lw $t0, 4($sp)                            # load n
  li $t1, 0xFF
  sll $t1, $t1, 23                          # bitmask to extract the exponent
  and $t2, $t0, $t1                         # $t2 = extracted exponent
  li $t3, 127
  sll $t3, $t3, 23
  subu $t2, $t2, $t3                        # unbias the exponent
  srl $t2, $t2, 1                           # exponent /= 2
  addu $t2, $t2, $t3                        # rebias the exponent
  and $t2, $t2, $t1                         # mask the unwanted bits
  lui $t1, 0x807F
  ori $t1, 0xFFFF
  and $t0, $t0, $t1                         # mask the old exponent
  addu $v0, $t0, $t2                        # add the new exponent

  move $sp, $fp
  lw $fp, 0($sp)
  addiu $sp, $sp, 8                         # free the stack
  jr  $ra                                   # return

