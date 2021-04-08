	.globl fit
fit:
	addiu $sp, $sp, -36
  sw $31, 32($sp)           # save $ra
	sw $fp, 28($sp)
	move $fp, $sp
	
  lw $4, k                  # load k
  lw $5, _j                 # load j
  jal allocate_matrix

  sw $2, 24($fp)            # save dW
  move $4, $2               # pass dW
  lw $5, k                  # pass k
  lw $6, _j                 # pass _j
  lw $7, $0                 # pass 0
  jal fill_matrix

  lw $4, k                  # load k
  lw $5, _j                 # load j
  jal allocate_matrix

  sw $2, 20($fp)            # save dC

  lw $4, k                  # pass k
  jal allocate_vector

  sw $2, 16($fp)            # save dT
  move $4, $2               # pass dT
  lw $5, k                  # pass k
  lw $6, $0                 # pass 0
  jal fill_vector

  lw $4, k                  # pass k
  jal allocate_vector

  sw $2, 12($fp)            # save Y

  lw $4, k                  # pass k
  jal allocate_vector

  sw $2, 8($fp)             # save E

  sw $0, 4($fp)             # unsigned int e = 0
  
  j fit_e_check

fit_e_body:
	sw $0, 0($fp)             # unsigned int _i = 0
	j	fit_i_check

fit_i_body:

  lw $2, 0($fp)             # load _i
  sll $2, $2, 2             # convert to bytes address
  lw $3, X                  # load the inputs matrix (X)
  addiu $4, $3, $2          # pass X[_i]
  lw $5, _j                 # pass j
  lw $6, INPUT              # pass the message
  jal debug_vector

  lw $4, W                  # pass W
  lw $5, k                  # pass k
  lw $6, _j                 # pass j
  lw $7, WEIGHTS_BEFORE     # pass the message
  jal debug_matrix

  lw $4, T                  # pass T
  lw $5, k                  # pass k
  lw $6, THRESHOLDS_BEFORE  # pass the message
  jal debug_vector

  lw $2, 0($fp)             # load _i
  sll $2, $2, 2             # convert to bytes address
  lw $3, X                  # load the inputs matrix (X)
  addiu $4, $3, $2          # pass X[_i]
  lw $5, 12($fp)            # pass Y
  jal transform

  lw $4, 12($fp)            # pass Y
  lw $5, k                  # pass k
  lw $6, POST_ACTV          # pass the message
  jal debug_vector

  lw $2, 0($fp)             # load _i
  sll $2, $2, 2             # convert to bytes address
  lw $3, Yd                 # load the desired output matrix (Yd)
  addiu $4, $3, $2          # pass Yd[_i]
  lw $5, k                  # pass k
  lw $6, DESIRED            # pass the message
  jal debug_vector

  lw $4, 8($fp)             # pass E
  lw $2, 0($fp)             # load _i
  sll $2, $2, 2             # convert to bytes address
  lw $3, Yd                 # load the desired output matrix (Yd)
  addiu $5, $3, $2          # pass Yd[_i]
  lw $6, k                  # pass k
  jal assign_vector

  lw $4, 8($fp)             # pass E (= Yd) 
  lw $5, 12($fp)            # pass Y
  jal sub_vector            # E = Yd - Y

  lw $4, 8($fp)             # pass E
  lw $5, k                  # pass k
  lw $6, ERROR              # pass the message
  jal debug_vector

  lw $4, 8($fp)             # pass E
  lw $5, LR                 # pass LR
  lw $6, k                  # pass k
  jal scale_vector

  addiu $sp, $sp, -4
  lw $4, 8($fp)             # pass E (scaled) (k size)
  lw $5, 12($fp)            # pass Y (j size)
  lw $6, 20($fp)            # pass dC (kxj size)
  lw $7, k                  # pass k
  lw $2, _j
  sw $2, 0($sp)             # pass j
  jal vector_cross

  lw $4, 20($fp)            # pass dC
  lw $5, k                  # pass k
  lw $6, _j                 # pass j
  lw $7, WABS_CHANGE        # pass the message
  jal debug_matrix

  lw $4, 24($fp)            # pass dW
  lw $5, B                  # pass B
  lw $6, k                  # pass k
  lw $7, _j                 # pass j
  jal scale_matrix

  lw $4, 24($fp)            # pass dW
  lw $5, 20($fp)            # pass dC
  lw $6, k                  # pass k
  lw $7, _j                 # pass j
  jal add_matrix

  lw $4, 24($fp)            # pass dW
  lw $5, k                  # pass k
  lw $6, _j                 # pass j
  lw $7, WCHANGE            # pass the message
  jal debug_matrix

  lw $4, W                  # pass W
  lw $5, 24($fp)            # pass dW
  lw $6, k                  # pass k
  lw $7, _j                 # pass j
  jal add_matrix

  lw $4, W                  # pass W
  lw $5, k                  # pass k
  lw $6, _j                 # pass j
  lw $7, WEIGHTS_AFTER      # pass the message
  jal debug_matrix

  lw $4, 16($fp)            # pass dT
  lw $5, B                  # pass B
  lw $6, k                  # pass k
  jal scale_vector

  lw $4, 16($fp)            # pass dT
  lw $5, 8($fp)             # pass E (scaled)
  lw $6, k                  # pass k
  jal add_vector

  lw $4, 16($fp)            # pass dT
  lw $5, k                  # pass k
  lw $6, TH_CHANGE          # pass the message
  jal debug_vector
  
  lw $4, T                  # pass T
  lw $5, 16($fp)            # pass dT
  lw $6, k                  # pass k
  jal add_vector

  lw $4, T                  # pass T
  lw $5, k                  # pass k
  lw $6, THRESHOLDS_AFTER   # pass the message
  jal debug_vector

	lw $2, 12($fp)
	addiu $2, $2, 1
	sw $2, 12($fp)

fit_i_check:
	lw $3, i                  # load i
	lw $2, 0($fp)             # load _i
  sltu $2, $2, $3           # if _i < i
	bne $2, $0, fit_i_body    # continue
  # else
  lw $2, 4($fp)
	addiu $2, $2, 1
	sw $2, 4($fp)             # e++

fit_e_check:
	lw $3, EP                 # load EP
	lw $2, 4($fp)             # load e
  sltu $2, $2, $3           # if e < EP
	bne $2, $0, fit_e_body    # continue
  # else
	move $sp, $fp
	lw $fp, 28($sp)
  lw $31, 32($sp)           # pop the return address
	addiu $sp, $sp, 36        # free the stack
	jr $31                    # return
