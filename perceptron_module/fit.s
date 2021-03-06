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
  # EPS: constant (1e-6 as float)
  # debugging messages
  # Result:
  # W and T are trained properly to fit the data

  addiu $sp, $sp, -80
  sw $ra, 76($sp)                           # save $ra
  sw $fp, 72($sp)               
  move $fp, $sp

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 56($fp)                           # save Y

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 52($fp)                           # save E                  

  lw $a0, k                                 # load k
  lw $a1, _j                                # load j
  jal allocate_matrix               

  sw $v0, 48($fp)                           # save dC

  lw $t1, ONE
  sw $t1, 44($fp)                           # Bc = 1.0 for the first iteration

  lw $a0, k                                 # load k
  lw $a1, _j                                # load j
  jal allocate_matrix  

  sw $v0, 40($fp)                           # save dW
  move $a0, $v0                             # pass dW
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass _j
  move $a3, $zero                           # pass 0
  jal fill_matrix                           # dW = 0         

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 36($fp)                           # save dT
  move $a0, $v0                             # pass dT
  lw $a1, k                                 # pass k
  move $a2, $zero                           # pass 0
  jal fill_vector                           # dT = 0

  lw $a0, k                                 # pass k
  lw $a1, _j                                # pass j
  jal allocate_matrix  

  sw $v0, 32($fp)                           # save sdW2
  move $a0, $v0                             # pass sdW2
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass _j
  move $a3, $zero                           # pass 0
  jal fill_matrix                           # sdW2 = 0    

  lw $a0, k                                 # pass k
  lw $a1, _j                                # pass j
  jal allocate_matrix                

  sw $v0, 64($fp)                           # save epsW
  move $a0, $v0                             # pass epsW
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass k
  lw $a3, EPS                               # pass EPS
  jal fill_matrix                           # epsT = EPS 

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 28($fp)                           # save sdT2
  move $a0, $v0                             # pass sdT2
  lw $a1, k                                 # pass k
  move $a2, $zero                           # pass 0
  jal fill_vector                           # sdT2 = 0 

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 68($fp)                           # save epsT
  move $a0, $v0                             # pass epsT
  lw $a1, k                                 # pass k
  lw $a2, EPS                           	# pass EPS
  jal fill_vector                           # epsT = EPS 

  lw $a0, k                                 # load k
  lw $a1, _j                                # load j
  jal allocate_matrix  
  sw $v0, 20($fp)                           # save rmsW  

  lw $a0, k                                 # pass k
  jal allocate_vector               
  sw $v0, 16($fp)                           # save rmsT

  lw $a0, k                                 # load k
  lw $a1, _j                                # load j
  jal allocate_matrix  

  sw $v0, 12($fp)                           # save lrW   

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 8($fp)                            # save lrT

  sw $zero, 4($fp)                          # unsigned int e = 0

  lw $a0, k                                 # load k
  lw $a1, _j                                # load j
  jal allocate_matrix  
  sw $v0, 24($fp)                           # save dW2  

  lw $a0, k                                 # pass k
  jal allocate_vector               
  sw $v0, 60($fp)                           # save dT2

  j fit_e_check               

fit_e_body:               

  sw $zero, 0($fp)                          # unsigned int _i = 0
  j fit_i_check               

fit_i_body: 

  lw $a0, 12($fp)                           # pass lrW
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass _j
  lw $a3, LR                                # pass LR
  jal fill_matrix                           # lrW = LR 

  lw $a0, 8($fp)                            # pass lrT
  lw $a1, k                                 # pass k
  lw $a2, LR                                # pass LR
  jal fill_vector                           # lrT = LR                           

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, X                                 # load the inputs matrix (X)
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass X[_i]
  lw $a1, 56($fp)                           # pass Y
  jal transform                                           

  lw $a0, 52($fp)                           # pass E
  lw $a1, 56($fp)                           # pass Y
  lw $a2, k                                 # pass k
  jal assign_vector               

  lw $a0, 52($fp)                           # pass E (= Y) 
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, Yd                                # load the desired output matrix (Yd)
  addu $t0, $t1, $t0                        # calculate the address
  lw $a1, 0($t0)                            # pass Yd[_i]
  jal sub_vector                            # E = Y - Yd 

  lw $a0, 56($fp)                           # pass Y
  lw $a1, k                                 # pass k
  la $a2, PREDICTION                        # pass the message
  jal debug_vector 

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, Yd                                # load the desired output matrix (Yd)
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass Yd[_i]
  lw $a1, k                                 # pass k
  la $a2, DESIRED                           # pass the message
  jal debug_vector 

  lw $a0, 52($fp)                           # pass E
  lw $a1, k                                 # pass k
  la $a2, ERROR                             # pass the message
  jal debug_vector                              
               
  lw $a0, 52($fp)                           # pass E (k size)
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, X                                 # load the inputs matrix (X)
  addu $t0, $t1, $t0                        # calculate the address
  lw $a1, 0($t0)                            # pass X[_i] (j size)
  lw $a2, 48($fp)                           # pass dC (kxj size)
  lw $a3, k                                 # pass k
  lw $t0, _j               
  sw $t0, -4($sp)                           # pass j
  jal vector_cross                            

  lw $a0, 48($fp)                           # pass dC
  lw $a1, 44($fp)                           # pass (1 - B)
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal scale_matrix   

  lw $a0, 40($fp)                           # pass dW
  lw $a1, B                                 # pass B
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal scale_matrix                

  lw $a0, 40($fp)                           # pass dW
  lw $a1, 48($fp)                           # pass dC
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal add_matrix                

  lw $a0, 24($fp)                           # pass dW2
  lw $a1, 40($fp)                           # pass dW
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal assign_matrix

  lw $a0, 24($fp)                           # pass dW2
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass j
  jal square_matrix

  lw $a0, 24($fp)                           # pass dW2
  lw $a1, 44($fp)                           # pass Bc
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal scale_matrix  

  lw $a0, 32($fp)                           # pass dW2
  lw $a1, B                                 # pass B
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal scale_matrix  

  lw $a0, 32($fp)                           # pass sdW2
  lw $a1, 24($fp)                           # pass dW2
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal add_matrix

  lw $a0, 20($fp)                           # pass rmsW
  lw $a1, 32($fp)                           # pass sdW2
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal assign_matrix

  lw $a0, 20($fp)                           # pass rmsW
  lw $a1, 64($fp)                           # pass epsW
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal add_matrix

  lw $a0, 20($fp)                           # pass rmsW
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass j
  jal sqrt_matrix

  lw $a0, 12($fp)                           # pass lrW
  lw $a1, 20($fp)                           # pass rmsW
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal div_matrix

  lw $a0, 40($fp)                           # pass dW
  lw $a1, 12($fp)                           # pass lrW
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal mul_matrix                  

  lw $a0, W                                 # pass W
  lw $a1, 40($fp)                           # pass dW
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal sub_matrix                

  lw $a0, W                                 # pass W
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass j
  la $a3, WEIGHTS                           # pass the message
  jal debug_matrix  

  lw $a0, 12($fp)                           # pass lrW
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass j
  la $a3, WEIGHTS_LR                        # pass the message
  jal debug_matrix               

  lw $a0, 36($fp)                           # pass dT
  lw $a1, B                                 # pass B
  lw $a2, k                                 # pass k
  jal scale_vector

  lw $a0, 52($fp)                           # pass E
  lw $a1, 44($fp)                           # pass (1 - B)
  lw $a2, k                                 # pass k
  jal scale_vector                

  lw $a0, 36($fp)                           # pass dT
  lw $a1, 52($fp)                           # pass E
  lw $a2, k                                 # pass k
  jal sub_vector                

  lw $a0, 60($fp)                           # pass dT2
  lw $a1, 36($fp)                           # pass dT
  lw $a2, k                                 # pass k
  jal assign_vector

  lw $a0, 60($fp)                           # pass dT2
  lw $a1, k                                 # pass k
  jal square_vector

  lw $a0, 60($fp)                           # pass dT2
  lw $a1, 44($fp)                           # pass (1 - B)
  lw $a2, k                                 # pass k
  jal scale_vector 

  lw $a0, 28($fp)                           # pass sdT2
  lw $a1, B                                 # pass B
  lw $a2, k                                 # pass k
  jal scale_vector 

  lw $a0, 28($fp)                           # pass sdT2
  lw $a1, 60($fp)                           # pass dT2
  lw $a2, k                                 # pass k
  jal add_vector

  lw $a0, 16($fp)                           # pass rmsT
  lw $a1, 28($fp)                           # pass sdT2
  lw $a2, k                                 # pass k
  jal assign_vector

  lw $a0, 16($fp)                           # pass rmsT
  lw $a1, 68($fp)                           # pass epsT
  lw $a2, k                                 # pass k
  jal add_vector

  lw $a0, 16($fp)                           # pass rmsT
  lw $a1, k                                 # pass k
  jal sqrt_vector

  lw $a0, 8($fp)                            # pass lrT
  lw $a1, 16($fp)                           # pass rmsT
  lw $a2, k                                 # pass k
  jal div_vector         

  lw $a0, 36($fp)                           # pass dT
  lw $a1, 8($fp)                            # pass lrT
  lw $a2, k                                 # pass k
  jal mul_vector  

  lw $a0, T                                 # pass T
  lw $a1, 36($fp)                           # pass dT
  lw $a2, k                                 # pass k
  jal sub_vector                

  lw $a0, T                                 # pass T
  lw $a1, k                                 # pass k
  la $a2, THRESHOLDS                        # pass the message
  jal debug_vector

  lw $a0, 8($fp)                            # pass lrT
  lw $a1, k                                 # pass k
  la $a2, THRESHOLDS_LR                     # pass the message
  jal debug_vector           

  lw $t0, 0($fp)                
  addiu $t0, $t0, 1               
  sw $t0, 0($fp)                            # _i++

  l.s $f0, ONE
  l.s $f2, B
  sub.s $f0, $f0, $f2
  s.s $f0, 44($fp)                          # Bc = 1 - B              

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
  lw $fp, 72($sp)               
  lw $ra, 76($sp)                           # pop the return address
  addiu $sp, $sp, 80                        # free the stack
  jr $ra                                    # return

