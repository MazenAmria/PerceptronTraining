  .globl max_wsum
max_wsum:
  # Assigns 1 to the maximum weighted sum in the neurons
  # and 0 for the others
  # $a0 = destination vector (4-bytes address)
  # $a1 = size of the vector (4-bytes unsigned integer)

  addiu $sp, $sp, -24
  sw $ra, 12($sp)
  sw $fp, 8($sp)
  move $fp, $sp
  sw $a0, 16($fp)                           # save vec
  sw $a1, 20($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int max_w = 0
  sw $zero, 4($fp)                          # unsigned int _i = 0
  
  j max_wsum_i_check

max_wsum_i_body:

  lw $t0, 4($fp)                            # load _i
  sll $t0, $t0, 2                           # converts to bytes offset
  lw $t1, 16($fp)                           # load vec
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f2, 0($t0)                           # load vec[_i]

  lw $t0, 0($fp)                            # load max_w
  sll $t0, $t0, 2                           # converts to bytes offset
  lw $t1, 16($fp)                           # load vec
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f0, 0($t0)                           # load vec[max_w]
  c.lt.s $f0, $f2                           # if vec[max_w] < vec[_i]
  bc1f max_wsum_else                        # else
  
  lw $t0, 4($fp)                            # load _i
  sw $t0, 0($fp)                            # store it in max_w

max_wsum_else:

  lw $t0, 4($fp)
  addiu $t0, $t0, 1
  sw $t0, 4($fp)                            # _i++

max_wsum_i_check:

  lw $t1, 4($fp)                            # load _i
  lw $t0, 20($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, max_wsum_i_body           # continue
  # else
  lw $a0, 0($fp)                            # pass max_w as class number
  lw $a1, 16($fp)                           # pass vec
  lw $a2, 20($fp)                           # pass i
  jal one_hot_encoding

  move $sp, $fp
  lw $ra, 12($sp)
  lw $fp, 8($sp)
  addiu $sp, $sp, 24
  jr $ra

