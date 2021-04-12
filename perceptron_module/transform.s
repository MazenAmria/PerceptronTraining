	.globl transform
transform:
  # Transforms an input to the output using the neural network
  # $a0 = X the input vector (j size)
  # $a1 = Y the output vector (k size)
  # .data section:
  # W: the weights matrix (kxj size)
  # T: the thresholds vector (k size)
  # k: 4-bytes unsigned integer
  # _j: 4-bytes unsigned integer
  # activation: the address of the used activation function

  addiu $sp, $sp, -20
  sw $ra, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save X
  sw $a1, 16($fp)                           # save Y
                                
  lw $a0, 8($fp)                            # pass X
  lw $a1, W                                 # pass W
  lw $a2, 16($fp)                           # pass Y
  lw $a3, k                                 # pass k
  lw $t0, _j               
  sw $t0, -4($sp)                           # pass j
  jal linear_transform                      # Y = W * X (linear transformation)
                  
  lw $a0, 16($fp)                           # pass Y
  lw $a1, T                                 # pass T
  lw $a2, k                                 # pass k
  jal sub_vector                            # Y -= T
                  
  lw $a0, 16($fp)                           # pass Y
  lw $a1, k                                 # pass k
  la $a2, PRE_ACTV                          # pass the title
  jal debug_vector                          # prints the output before the activation
                  
  lw $a0, 16($fp)                           # pass Y
  lw $a1, k                                 # pass k
  lw $t0, activation               
  jalr $t0                                  # activation(Y)

  move $sp, $fp
  lw $ra, 4($sp)
  lw $fp, 0($sp)
  addiu $sp, $sp, 20
  jr $ra

