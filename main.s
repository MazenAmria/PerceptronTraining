.text
.globl main

main:
  li $a0, 4
  li $a1, 5
  jal allocate_matrix

  move $a0, $v0
  li $a1, 5
  jal fill

  move $a0, $v0
  li $a1, 1
  li $a2, 4
  jal fill_row

  move $a0, $v0
  li $a1, 3
  li $a2, 3
  jal fill_col

  li $v1, 0
  jal exit
