  .globl allocate_vector
allocate_vector:
  # Alocates a vector
  # returns $v0 = Ai
  # $a0: i (4-bytes integer)
  
  sll $a0, $a0, 2     # convert to bytes size

  li $v0, 9          # sbrk()
  syscall

  jr $ra
