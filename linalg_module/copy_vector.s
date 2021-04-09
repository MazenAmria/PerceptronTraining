  .globl copy_vector
copy_vector:
  # Copies a vector to another
  # returns $v0 = address of clone(src)
  # $a0: address of the soruce vector (i size)
  # $a1: i (4-bytes integer)

  addiu $sp, $sp, -24
  sw $ra, 12($sp)                           # save $ra
  sw $fp, 8($sp)                            # save $fp
  move $fp, $sp               
  sw $a0, 16($fp)                           # save src
  sw $a1, 20($fp)                           # save i

  lw $a0, 20($fp)                           # pass i to allocate_vector
  jal allocate_vector               

  sw $v0, 4($fp)                            # save dest
  sw $zero, 0($fp)                          # unsigned int _i = 0
    
  j	copy_vector_i_check

copy_vector_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 16($fp)                           # load src
  addu $t1, $t1, $t0                        # calculate the address

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t2, 4($fp)                            # load dest
  addu $t0, $t2, $t0                        # calculate the address

  lw $t2, 0($t1)                            # T = src[_i]
  sw $t2, 0($t0)                            # dest[_i] = T

  lw $t0, 0($fp)                
  addiu $t0, $t0, 1               
  sw $t0, 0($fp)                            # _i++

copy_vector_i_check:

  lw $t0, 20($fp)                           # load i 
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i

  bne	$t0, $zero, copy_vector_i_body        # continue

  move $sp, $fp
  lw $v0, 4($fp)                            # return dest
  lw $ra, 12($sp)                           # pop $ra
  lw $fp, 8($sp)                            # pop $fp
  addiu	$sp, $sp, 24                        # free the stack
  jr $ra                                    # return

