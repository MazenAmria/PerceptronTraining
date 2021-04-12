  .globl one_hot_encoding
one_hot_encoding:
  # Fills a vector with the one hot encoding of the class
  # $a0 = class number (4-bytes unsigned integer)
  # $a1 = destination vector (4-bytes address)
  # $a2 = size of the vector (4-bytes unsigned integer)
    
  addiu $sp, $sp, -20
  sw $ra, 4($sp)                            # save $ra
  sw $fp, 0($sp)                            # save $fp
  move $fp, $sp                           
  sw $a0, 8($fp)                            # save y
  sw $a1, 12($fp)                           # save dest
  sw $a2, 16($fp)                           # save i
                    
  move $a2, $zero                           # pass 0
  lw $a1, 16($fp)                           # pass i
  lw $a0, 12($fp)                           # pass dest
  jal fill_vector                           # (dest, i, 0)
                    
  lw $t0, 8($fp)                            # load y
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load dest        
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f0, ONE                    
  s.s $f0, 0($t0)                           # dest[y] = 1.0
                        
  move $sp, $fp                   
  lw $ra, 4($sp)                    
  lw $fp, 0($sp)                    
  addiu $sp, $sp, 20                    
  jr $ra                                    # return

