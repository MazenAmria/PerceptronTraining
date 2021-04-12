  .globl hard_limiter
hard_limiter:
  # Applies the hard limiting activation function to a vector
  # $a0 = destination vector (4-bytes address)
  # $a1 = size of the vector (4-bytes unsigned integer)
    
  addiu $sp, $sp, -16
  sw $fp, 4($sp)
  move $fp, $sp     
  sw $a0, 8($fp)                            # save vec
  sw $a1, 12($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
    
  j hard_limiter_i_check                  
    
hard_limiter_i_body:  
                
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, 8($fp)                            # load vec
  addu $t0, $t1, $t0                        # claculate the address
  l.s $f0, 0($t0)                           # load vec[_i]
  mtc1 $zero, $f2                           # load the 0
  c.le.s $f2, $f0                           # if 0 <= vec[_i]
  bc1f hard_limiter_else                    # else              
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, 8($fp)                            # load vec
  addu $t0, $t1, $t0                        # caldulate the address
  l.s $f0, ONE                  
  s.s $f0, 0($t0)                           # dest[y] = 1.0
  j hard_limiter_i_increment                

hard_limiter_else:      

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, 8($fp)                            # load vec[_i]
  addu $t0, $t1, $t0                        # calculate the address
  sw $zero, 0($t0)                          # vec[_i] = 0

hard_limiter_i_increment: 

  lw $t0, 0($fp) 
  addiu $t0, $t0, 1 
  sw $t0, 0($fp)                            # _i++

hard_limiter_i_check: 

  lw $t1, 0($fp)                            # load i
  lw $t0, 12($fp)                           # load _i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, hard_limiter_i_body       # continue
  # else          
  move $sp, $fp         
  lw $fp, 4($sp)          
  addiu $sp, $sp, 16                        # free the stack
  jr $ra                                    # return

