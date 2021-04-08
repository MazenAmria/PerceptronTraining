# ONLY FOR TESTING PURPOSES
  .data
    A: .word 0
    B: .word 0
    C: .word 0
    i: .word 5
    _j: .word 3
    c1: .float 5.0
    c2: .float 8.2
    c3: .float 6.0
    msgA: .asciiz "The First Matrix\n"
    msgB: .asciiz "The Second Matrix\n"
    addB: .asciiz "The Second Matrix After Addition\n"
    subA: .asciiz "The First Matrix After Subtraction\n"
    scaleA: .asciiz "The First Matrix After Scaling\n"
    msgC: .asciiz "The Third Matrix\n"
    assignC: .asciiz "The Third Matrix After Assignment\n"
  .text
  .globl main
main:

  # Allocate the first matrix
  lw $a0, i
  lw $a1, _j
  jal allocate_matrix
  la $t0, A
  sw $v0, 0($t0)

  # fill it with c1
  lw $a0, A
  lw $a1, i
  lw $a2, _j
  lw $a3, c1
  jal fill_matrix

  # Allocate the second matrix
  lw $a0, i
  lw $a1, _j
  jal allocate_matrix
  la $t0, B
  sw $v0, 0($t0)

  # fill it with c2
  lw $a0, B
  lw $a1, i
  lw $a2, _j
  lw $a3, c2
  jal fill_matrix

  # exit
  addiu $v0, $zero, 10
  syscall