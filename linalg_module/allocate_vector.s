allocate_vector:
  # Alocates a vector
  # returns $v0 = Ai
  # $a0: i (4-bytes integer)
  
  sll $4, $4, 2     # convert to bytes size

  li $2, 9          # sbrk()
  syscall

  jr $31
