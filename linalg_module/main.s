# ONLY FOR TESTING PURPOSES
  .data
    A: .word 0
    B: .word 0
    C: .word 0
    D: .word 0
    i: .word 5
    _j: .word 3
    c1: .float 5.0
    c2: .float 8.2
    c12: .float 13.2
    c21: .float -8.2
    c3: .float 6.0
    c13: .float -49.2
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

  # B += A
  lw $a0, B
  lw $a1, A
  lw $a2, i
  lw $a3, _j
  jal add_matrix

  # A -= B
  lw $a0, A
  lw $a1, B
  lw $a2, i
  lw $a3, _j
  jal sub_matrix

  # C = clone(A)
  lw $a0, A
  lw $a1, i
  lw $a2, _j
  jal copy_matrix
  la $t0, C
  sw $v0, 0($t0)

  # Allocate D
  lw $a0, i
  lw $a1, _j
  jal allocate_matrix
  la $t0, D
  sw $v0, 0($t0)

  # D = B
  lw $a0, D
  lw $a1, B
  lw $a2, i
  lw $a3, _j
  jal assign_matrix

  # scale C by 6.0
  lw $a0, C
  lw $a1, c3
  lw $a2, i
  lw $a3, _j
  jal scale_matrix

  # exit
  addiu $v0, $zero, 10
  syscall
