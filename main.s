.text
.globl main

main:
  li $a0, 4
  li $a1, 5
  jal allocate_matrix

  addiu $sp, $sp, -4
  sw $v0, 0($sp)

  move $a0, $v0
  li $a1, 5
  mtc1 $a1, $f2
  cvt.s.w $f2, $f2
  mfc1 $a1, $f2
  jal fill

  move $a0, $v0
  li $a1, 1
  li $a2, 4
  mtc1 $a2, $f2
  cvt.s.w $f2, $f2
  mfc1 $a2, $f2
  jal fill_row

  move $a0, $v0
  li $a1, 3
  li $a2, 3
  mtc1 $a2, $f2
  cvt.s.w $f2, $f2
  mfc1 $a2, $f2
  jal fill_col

  move $a0, $v0
  jal print_matrix

  # print new line
  li $a0, 10
  li $v0, 11
  syscall

  li $a0, 5
  li $a1, 4
  jal allocate_matrix

  addiu $sp, $sp, -4
  sw $v0, 0($sp)

  move $a0, $v0
  li $a1, 5
  mtc1 $a1, $f2
  cvt.s.w $f2, $f2
  mfc1 $a1, $f2
  jal fill

  move $a0, $v0
  li $a1, 1
  li $a2, 4
  mtc1 $a2, $f2
  cvt.s.w $f2, $f2
  mfc1 $a2, $f2
  jal fill_col

  move $a0, $v0
  li $a1, 3
  li $a2, 3
  mtc1 $a2, $f2
  cvt.s.w $f2, $f2
  mfc1 $a2, $f2
  jal fill_row

  move $a0, $v0
  jal print_matrix


  # print new line
  li $a0, 10
  li $v0, 11
  syscall

  li $a0, 4
  li $a1, 4
  jal allocate_matrix

  move $a2, $v0

  lw $a1, 0($sp)
  lw $a0, 4($sp)
  addiu $sp, $sp, 4

  sw $a2, 0($sp)
  jal matrix_mult

  lw $a0, 0($sp)
  addiu $sp, $sp, 4
  jal print_matrix

  li $v1, 0
  jal exit
