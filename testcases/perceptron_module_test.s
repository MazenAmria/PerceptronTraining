# ONLY FOR TESTING PURPOSES
  .data
    Wi: .float 0.5 0.5
    Ti: .float 0.0
    LR: .float 0.5
    B: .float 0.5
    Bc: .float 1.0
    EP: .word 3
    i: .word 4
    _j: .word 2
    k: .word 1
    X: .word 0
    Yd: .word 0
    W: .word 0
    T: .word 0
    activation: .word 0
    ONE: .float 1.0
    PRE_ACTV: .asciiz "Before Applying the activation function\n"
    INPUT: .asciiz "The input vector\n"
    POST_ACTV: .asciiz "After Applying the activation function\n"
    DESIRED: .asciiz "The desired output\n"
    ERROR: .asciiz"The error in the prediction\n"
    WABS_CHANGE: .asciiz "The absolute change in the weights\n"
    WCHANGE: .asciiz "The change in the weights\n"
    WEIGHTS_BEFORE: .asciiz "The weights at the beginning of the iteration\n"
    WEIGHTS_AFTER: .asciiz "The weights at the end of the iteration\n"
    TH_CHANGE: .asciiz "Change in thresholds\n"
    THRESHOLDS_BEFORE: .asciiz "The thresholds at the beginning of the iteration\n"
    THRESHOLDS_AFTER: .asciiz "The thresholds at the end of the iteration\n"
  .text
  .globl main
main:

  move $fp, $sp

  # Allocate W matrix
  lw $a0, k
  lw $a1, _j
  jal allocate_matrix
  la $t0, W
  sw $v0, 0($t0)

  # initialize it with Wi
  lw $a0, W
  la $a1, Wi
  lw $a2, k
  lw $a3, _j
  jal initialize_weights

  # Allocate T vector
  lw $a0, k
  jal allocate_vector
  la $t0, T
  sw $v0, 0($t0)

  # initialize it with Ti
  lw $a0, T
  lw $a1, k
  lw $a2, Ti
  jal fill_vector

  # Allocate X matrix
  lw $a0, i
  lw $a1, _j
  jal allocate_matrix
  la $t0, X
  sw $v0, 0($t0)

  # fill X
  lw $a0, X
  li $a1, 0
  li $a2, 0
  move $a3, $0
  jal set_in_matrix

  lw $a0, X
  li $a1, 0
  li $a2, 1
  move $a3, $0
  jal set_in_matrix

  lw $a0, X
  li $a1, 1
  li $a2, 0
  move $a3, $0
  jal set_in_matrix

  lw $a0, X
  li $a1, 1
  li $a2, 1
  lw $a3, ONE
  jal set_in_matrix

  lw $a0, X
  li $a1, 2
  li $a2, 0
  lw $a3, ONE
  jal set_in_matrix

  lw $a0, X
  li $a1, 2
  li $a2, 1
  move $a3, $0
  jal set_in_matrix

  lw $a0, X
  li $a1, 3
  li $a2, 0
  lw $a3, ONE
  jal set_in_matrix

  lw $a0, X
  li $a1, 3
  li $a2, 1
  lw $a3, ONE
  jal set_in_matrix

  # Allocate Yd matrix
  lw $a0, i
  lw $a1, k
  jal allocate_matrix
  la $t0, Yd
  sw $v0, 0($t0)
  
  # fill Yd
  lw $a0, Yd
  li $a1, 0
  li $a2, 0
  move $a3, $0
  jal set_in_matrix

  lw $a0, Yd
  li $a1, 1
  li $a2, 0
  move $a3, $0
  jal set_in_matrix

  lw $a0, Yd
  li $a1, 2
  li $a2, 0
  move $a3, $0
  jal set_in_matrix

  lw $a0, Yd
  li $a1, 3
  li $a2, 0
  lw $a3, ONE
  jal set_in_matrix

  # pass the activation function
  la $t0, hard_limiter
  la $t1, activation
  sw $t0, 0($t1)

  jal fit

  # exit
  addiu $v0, $zero, 10
  syscall

