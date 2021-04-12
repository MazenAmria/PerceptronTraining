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
    r1: .float 3.0, 0.0
    r2: .float 2.0, 1.0
    r3: .float -1.0, -2.0
    W: .word 0, 0, 0
    XY: .word 0
    X: .float 2.0, -1.0
    Y: .float 6.0, 3.0, 0.0
    msg1: .asciiz "A\n"
    msg2: .asciiz "B\n"
    msg3: .asciiz "B += A\n"
    msg4: .asciiz "A -= B\n"
    msg5: .asciiz "C = clone(A)\n"
    msg6: .asciiz "D = B\n"
    msg7: .asciiz "Scale C by 6.0\n"
    msg8: .asciiz "W\n"
    msg9: .asciiz "X\n"
    msg10: .asciiz "Y\n"
    msg11: .asciiz "XY\n"
  .text
  .globl main
main:

  move $fp, $sp

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

  # debug A
  lw $a0, A
  lw $a1, i
  lw $a2, _j
  la $a3, msg1
  jal debug_matrix

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

  # debug B
  lw $a0, B
  lw $a1, i
  lw $a2, _j
  la $a3, msg2
  jal debug_matrix

  # B += A
  lw $a0, B
  lw $a1, A
  lw $a2, i
  lw $a3, _j
  jal add_matrix

  # debug B
  lw $a0, B
  lw $a1, i
  lw $a2, _j
  la $a3, msg3
  jal debug_matrix

  # A -= B
  lw $a0, A
  lw $a1, B
  lw $a2, i
  lw $a3, _j
  jal sub_matrix

  # debug A
  lw $a0, A
  lw $a1, i
  lw $a2, _j
  la $a3, msg4
  jal debug_matrix

  # C = clone(A)
  lw $a0, A
  lw $a1, i
  lw $a2, _j
  jal copy_matrix
  la $t0, C
  sw $v0, 0($t0)

  # debug C
  lw $a0, C
  lw $a1, i
  lw $a2, _j
  la $a3, msg5
  jal debug_matrix

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

  # debug D
  lw $a0, D
  lw $a1, i
  lw $a2, _j
  la $a3, msg6
  jal debug_matrix

  # scale C by 6.0
  lw $a0, C
  lw $a1, c3
  lw $a2, i
  lw $a3, _j
  jal scale_matrix

  # debug C
  lw $a0, C
  lw $a1, i
  lw $a2, _j
  la $a3, msg7
  jal debug_matrix

  # create W
  la $t0, W
  la $t1, r1
  sw $t1, 0($t0)
  addiu $t0, $t0, 4
  la $t1, r2
  sw $t1, 0($t0)
  addiu $t0, $t0, 4
  la $t1, r3
  sw $t1, 0($t0)

  # debug W
  la $a0, W
  li $a1, 3
  li $a2, 2
  la $a3, msg8
  jal debug_matrix

  # debug X
  la $a0, X
  li $a1, 2
  la $a2, msg9
  jal debug_vector

  # transform X with W
  addiu $sp, $sp, -4
  la $a0, X
  la $a1, W
  la $a2, Y
  li $a3, 3
  li $t0, 2
  sw $t0, 0($sp)
  jal linear_transform

  # debug Y
  la $a0, Y
  li $a1, 3
  la $a2, msg10
  jal debug_vector

  # Allocate XY
  li $a0, 2
  li $a1, 3
  jal allocate_matrix
  la $t0, XY
  sw $v0, 0($t0)

  # cross X and Y
  addiu $sp, $sp, -4
  la $a0, X
  la $a1, Y
  lw $a2, XY
  li $a3, 2
  li $t0, 3
  sw $t0, 0($sp)
  jal vector_cross

  # debug XY
  lw $a0, XY
  li $a1, 2
  li $a2, 3
  la $a3, msg11
  jal debug_matrix

  # exit
  addiu $v0, $zero, 10
  syscall
