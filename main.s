.text
.globl main

main:
  li $a0, 4
  jal allocate_vector

  li $v1, 0
  jal exit
