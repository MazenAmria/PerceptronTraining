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
	sw $31, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp
	sw $4, 8($fp)             # save X
	sw $5, 16($fp)            # save Y

  addiu $sp, $sp, -4
	lw $4, 8($fp)             # pass X
  lw $5, W                  # pass W
  lw $6, 16($fp)            # pass Y
  lw $7, k                  # pass k
  lw $2, _j
  sw $2, 0($sp)             # pass j
  jal linear_transform      # Y = W * X (linear transformation)

	lw $4, 16($fp)            # pass Y
	lw $5, T                  # pass T
  lw $6, k                  # pass k
  jal sub_vector            # Y -= T

  lw $4, 16($fp)            # pass Y
  lw $5, k                  # pass k
  lw $6, PRE_ACTV           # pass the title
  jal debug_vector          # prints the output before the activation

	lw $4, 16($fp)            # pass Y
  lw $5, k                  # pass k
  lw $2, activation
  jalr $2                   # activation(Y)

	move $sp, $fp
	lw $31, 4($sp)
	lw $fp, 0($sp)
	addiu $sp, $sp, 20
	jr $31