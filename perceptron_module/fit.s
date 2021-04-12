  .globl fit
fit:
  # Fits a Neural Network Transformer with the training data
  # All needed data must be in the .data:
  # W: address to the matrix of the weights (kxj matrix)
  # Wi: the initial value of the weights (float)
  # T: address to the vector of thresholds (k vector)
  # Ti: the initial value of the thresholds (float)
  # X: address to the matrix of the inputs (ixj matrix)
  # Y: address to the matrix of the desired outputs (ixk matrix)
  # i: number of instances (4-bytes integer)
  # _j: number of features (4-bytes integer)
  # k: number of classes (4-bytes integer)
  # EP: number of epochs (4-bytes integer)
  # LR: learning rate (float)
  # B: momentum (float)
  # activation: the address of the activation function
  # ONE: constant (1.0 as float)
  # debugging messages
  # Result:
  # W and T are trained properly to fit the data

  addiu $sp, $sp, -36
  sw $ra, 32($sp)                           # save $ra
  sw $fp, 28($sp)               
  move $fp, $sp               

  lw $a0, k                                 # load k
  lw $a1, _j                                # load j
  jal allocate_matrix               

  sw $v0, 24($fp)                           # save dW
  move $a0, $v0                             # pass dW
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass _j
  move $a3, $zero                           # pass 0
  jal fill_matrix               

  lw $a0, k                                 # load k
  lw $a1, _j                                # load j
  jal allocate_matrix               

  sw $v0, 20($fp)                           # save dC

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 16($fp)                           # save dT
  move $a0, $v0                             # pass dT
  lw $a1, k                                 # pass k
  move $a3, $zero                           # pass 0
  jal fill_vector               

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 12($fp)                           # save Y

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 8($fp)                            # save E

  sw $zero, 4($fp)                          # unsigned int e = 0

  j fit_e_check               

fit_e_body:               

  sw $zero, 0($fp)                          # unsigned int _i = 0
  j	fit_i_check               

fit_i_body:               

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, X                                 # load the inputs matrix (X)
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass X[_i]
  lw $a1, _j                                # pass j
  la $a2, INPUT                             # pass the message
  jal debug_vector                

  lw $a0, W                                 # pass W
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass j
  la $a3, WEIGHTS_BEFORE                    # pass the message
  jal debug_matrix                

  lw $a0, T                                 # pass T
  lw $a1, k                                 # pass k
  la $a2, THRESHOLDS_BEFORE                 # pass the message
  jal debug_vector                

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, X                                 # load the inputs matrix (X)
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass X[_i]
  lw $a1, 12($fp)                           # pass Y
  jal transform               

  lw $a0, 12($fp)                           # pass Y
  lw $a1, k                                 # pass k
  la $a2, POST_ACTV                         # pass the message
  jal debug_vector                

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, Yd                                # load the desired output matrix (Yd)
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass Yd[_i]
  lw $a1, k                                 # pass k
  la $a2, DESIRED                           # pass the message
  jal debug_vector                

  lw $a0, 8($fp)                            # pass E
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, Yd                                # load the desired output matrix (Yd)
  addu $t0, $t1, $t0                        # calculate the address
  lw $a1, 0($t0)                            # pass Yd[_i]
  lw $a2, k                                 # pass k
  jal assign_vector               

  lw $a0, 8($fp)                            # pass E (= Yd) 
  lw $a1, 12($fp)                           # pass Y
  jal sub_vector                            # E = Yd - Y

  lw $a0, 8($fp)                            # pass E
  lw $a1, k                                 # pass k
  la $a2, ERROR                             # pass the message
  jal debug_vector                

  lw $a0, 8($fp)                            # pass E
  lw $a1, LR                                # pass LR
  lw $a2, k                                 # pass k
  jal scale_vector                
               
  lw $a0, 8($fp)                            # pass E (scaled) (k size)
  lw $a1, 12($fp)                           # pass Y (j size)
  lw $a2, 20($fp)                           # pass dC (kxj size)
  lw $a3, k                                 # pass k
  lw $t0, _j               
  sw $t0, -4($sp)                           # pass j
  jal vector_cross                

  lw $a0, 20($fp)                           # pass dC
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass j
  la $a3, WABS_CHANGE                       # pass the message
  jal debug_matrix                

  lw $a0, 24($fp)                           # pass dW
  lw $a1, B                                 # pass B
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal scale_matrix                

  lw $a0, 24($fp)                           # pass dW
  lw $a1, 20($fp)                           # pass dC
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal add_matrix                

  lw $a0, 24($fp)                           # pass dW
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass j
  la $a3, WCHANGE                           # pass the message
  jal debug_matrix                

  lw $a0, W                                 # pass W
  lw $a1, 24($fp)                           # pass dW
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal add_matrix                

  lw $a0, W                                 # pass W
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass j
  la $a3, WEIGHTS_AFTER                     # pass the message
  jal debug_matrix                

  lw $a0, 16($fp)                           # pass dT
  lw $a1, B                                 # pass B
  lw $a2, k                                 # pass k
  jal scale_vector                

  lw $a0, 16($fp)                           # pass dT
  lw $a1, 8($fp)                            # pass E (scaled)
  lw $a2, k                                 # pass k
  jal sub_vector                

  lw $a0, 16($fp)                           # pass dT
  lw $a1, k                                 # pass k
  la $a2, TH_CHANGE                         # pass the message
  jal debug_vector                

  lw $a0, T                                 # pass T
  lw $a1, 16($fp)                           # pass dT
  lw $a2, k                                 # pass k
  jal add_vector                

  lw $a0, T                                 # pass T
  lw $a1, k                                 # pass k
  la $a2, THRESHOLDS_AFTER                  # pass the message
  jal debug_vector                

  lw $t0, 0($fp)                
  addiu $t0, $t0, 1               
  sw $t0, 0($fp)                            # _i++                

fit_i_check:   

  lw $t1, i                                 # load i
  lw $t0, 0($fp)                            # load _i
  sltu $t0, $t0, $t1                        # if _i < i
  bne $t0, $zero, fit_i_body                # continue
  # else                
  lw $t0, 4($fp)               
  addiu $t0, $t0, 1               
  sw $t0, 4($fp)                            # e++

fit_e_check:  

  lw $t1, EP                                # load EP
  lw $t0, 4($fp)                            # load e
  sltu $t0, $t0, $t1                        # if e < EP
  bne $t0, $zero, fit_e_body                # continue
  # else                
  move $sp, $fp               
  lw $fp, 28($sp)               
  lw $ra, 32($sp)                           # pop the return address
  addiu $sp, $sp, 36                        # free the stack
  jr $ra                                    # return

