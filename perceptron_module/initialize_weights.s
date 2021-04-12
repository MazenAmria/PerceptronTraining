  .globl initialize_weights
initialize_weights:
  # Initializes the weights matrix with features weights vector
  # $a0: address of the destination matrix (jxk size)
  # $a1: address of the soruce vector (j size)
  # $a2: k (4-bytes integer)
  # $a3: j (4-bytes integer)

  addiu $sp, $sp, -28
  sw $ra, 4($sp)                            # save $ra
  sw $fp, 8($sp)                            # save $fp
  move $fp, $sp
  sw $a0, 12($fp)                           # save dest
  sw $a1, 16($fp)                           # save src
  sw $a2, 20($fp)                           # save k
  sw $a3, 24($fp)                           # save j
  sw $zero, 0($fp)                          # unsigned int _i = 0
 
  j initialize_weights_i_check

initialize_weights_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load dest
  addu $t0, $t1, $t0                        # calculate the address 
  lw $a0, 0($t0)                            # pass dest[_i]

  lw $a1, 16($fp)                           # pass src

  lw $a2, 24($fp)                           # pass j
  jal assign_vector

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

initialize_weights_i_check:
  
  lw $t0, 20($fp)                           # load i 
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, initialize_weights_i_body # continue
  # else
  move $sp, $fp
  lw $ra, 4($sp)                            # pop $ra
  lw $fp, 8($sp)                            # pop $fp
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return

