# ONLY FOR TESTING PURPOSES
  .data
    Wi: .float 0.5
    Ti: .float 1.0
    LR: .float 0.01
    B: .float 0.95
    EP: .word 3
    i: .word 4
    _j: .word 2
    k: .word 1
    X: .word 0
    Y: .word 0
    W: .word 0
    T: .word 0
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

  la $t0, hard_limiter

  # exit
  addiu $v0, $zero, 10
  syscall

